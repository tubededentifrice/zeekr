import Foundation
import Observation
import VehicleCore

struct ActivityEvent: Identifiable, Codable {
    let id: UUID
    let date: Date
    let command: String
    let stage: CommandStage
    let demo: Bool
    let detail: String
}

@MainActor @Observable
final class AppModel {
    var demo = false
    var tab = 0
    var selectedControl: Capability? {
        didSet { notice = nil }
    }
    var showSetup = false
    var demoOutcome: DemoOutcome = .observed
    private(set) var busy = false
    private(set) var simulatedLock: Bool?
    private(set) var lastObservation: Date?
    private(set) var events: [ActivityEvent] = []
    var notice: String?
    var proximity = ProximityPolicy()
    var demoRSSI = -86.0
    var entryThreshold = -58.0
    var exitThreshold = -74.0
    var dwell = 3.0
    private var commandTask: Task<Void, Never>?
    private var generation = UUID()
    private let activityURL: URL?

    init(persist: Bool = true) {
        if persist, let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            activityURL = directory.appendingPathComponent("activity.json")
            if let data = try? Data(contentsOf: activityURL!),
               let saved = try? JSONDecoder().decode([ActivityEvent].self, from: data) {
                events = Array(saved.prefix(200))
            }
        } else {
            activityURL = nil
        }
    }

    var lockTitle: String {
        guard demo else { return "State unknown" }
        guard let simulatedLock else { return "Demo state unknown" }
        return simulatedLock ? "Locked in demo" : "Unlocked in demo"
    }

    func setDemo(_ enabled: Bool) {
        cancelTest()
        demo = enabled
        simulatedLock = nil
        lastObservation = nil
        proximity.disable()
        notice = nil
    }

    func cancelTest() {
        generation = UUID()
        commandTask?.cancel()
        commandTask = nil
        if busy {
            record("Test interrupted", .uncertain, "The app left the active test. No vehicle command was sent.")
        }
        busy = false
    }

    func background() {
        cancelTest()
        proximity.disable()
    }

    func run(_ capability: Capability, proximityAction: ProximityPolicy.Action? = nil) {
        if let reason = CommandGate.reason(for: capability, demo: demo, busy: busy) {
            notice = reason
            record(capability.title, .blocked, reason)
            return
        }
        if proximityAction == nil { proximity.disable() }
        busy = true
        notice = nil
        let token = generation
        let outcome = demoOutcome
        if capability.id == "lock" || capability.id == "unlock" {
            simulatedLock = nil
            lastObservation = nil
        }
        commandTask = Task { [weak self] in
            guard let self else { return }
            for stage in outcome.stages {
                do { try await Task.sleep(for: .milliseconds(350)) } catch { return }
                guard !Task.isCancelled, generation == token, demo else { return }
                record(capability.title, stage, Self.detail(stage))
                if stage == .observed {
                    if capability.id == "lock" { simulatedLock = true }
                    if capability.id == "unlock" { simulatedLock = false }
                    lastObservation = Date()
                }
            }
            busy = false
            if selectedControl?.id == capability.id {
                notice = outcome == .observed ? "Demo complete." : "Demo: \(outcome.rawValue.lowercased()). State unknown."
            }
            if let proximityAction {
                proximity.complete(proximityAction, observed: outcome == .observed, time: ProcessInfo.processInfo.systemUptime)
            }
        }
    }

    func armProximity() {
        guard demo, !busy else { return }
        proximity = ProximityPolicy(entry: entryThreshold, exit: exitThreshold, dwell: dwell)
        proximity.arm()
        record("Proximity demo", .result, "Policy armed with synthetic signal values. No radio commands are used.")
    }

    func tick() {
        guard demo else { return }
        if let action = proximity.observe(rssi: demoRSSI, time: ProcessInfo.processInfo.systemUptime, authenticated: true),
           let capability = Capability.find(action.rawValue) {
            run(capability, proximityAction: action)
        }
    }

    func loseSignal() {
        cancelTest()
        proximity.signalLost()
        simulatedLock = nil
        lastObservation = nil
        record("Proximity demo", .uncertain, "Signal lost. A lost signal does not prove that the car is locked.")
    }

    func clearHistory() {
        events.removeAll()
        persist()
    }

    var report: String {
        let header = "ZEEKR phone test report\nNo target-car commands have been sent by this app.\nDemo records use synthetic outcomes. No identifiers or credentials are included.\n"
        return header + events.reversed().map {
            "\($0.date.ISO8601Format()) | \($0.demo ? "DEMO" : "SETUP") | \($0.command) | \($0.stage.rawValue) | \($0.detail)"
        }.joined(separator: "\n")
    }

    private func record(_ title: String, _ stage: CommandStage, _ detail: String) {
        events.insert(ActivityEvent(id: UUID(), date: Date(), command: title, stage: stage, demo: demo, detail: detail), at: 0)
        events = Array(events.prefix(200))
        persist()
    }

    private func persist() {
        guard let activityURL, let data = try? JSONEncoder().encode(events) else { return }
        do {
            try data.write(to: activityURL, options: [.atomic, .completeFileProtection])
        } catch {
            notice = "The app could not save test history. The current records remain in memory."
        }
    }

    private static func detail(_ stage: CommandStage) -> String {
        switch stage {
        case .sent: "Synthetic radio write. No vehicle command was sent."
        case .received: "Synthetic receipt. A receipt does not prove a physical effect."
        case .result: "Synthetic command result. Vehicle state is a separate observation."
        case .observed: "Synthetic state observation. This is not a target-car test."
        case .rejected: "Synthetic rejection. State remains unknown."
        case .timedOut: "Synthetic timeout. State remains unknown."
        case .uncertain: "No state observation. Do not assume that the vehicle is locked."
        case .blocked: "The command was blocked before send."
        }
    }
}
