import Foundation

public struct ProximityPolicy: Sendable {
    public enum State: String, Sendable {
        case disabled = "Off"
        case far = "Waiting for approach"
        case nearCandidate = "Checking approach"
        case unlockRequested = "Unlock requested"
        case unlocked = "Unlocked in demo"
        case exitCandidate = "Checking departure"
        case lockRequested = "Lock requested"
        case unconfirmed = "State unconfirmed"
    }

    public enum Action: String, Sendable { case unlock, lock }
    public private(set) var state: State = .disabled
    public private(set) var smoothedRSSI: Double?
    public let entry: Double
    public let exit: Double
    public let dwell: TimeInterval
    private var candidateSince: TimeInterval?
    private var lastSample: TimeInterval?
    private var cooldownUntil: TimeInterval = 0

    public init(entry: Double = -58, exit: Double = -74, dwell: TimeInterval = 3) {
        self.entry = entry
        self.exit = exit
        self.dwell = dwell
    }

    public mutating func arm() {
        disable()
        guard entry.isFinite, exit.isFinite, dwell.isFinite,
              entry > exit, entry < 0, exit >= -110, dwell >= 1 else { return }
        state = .far
    }

    public mutating func disable() {
        state = .disabled
        smoothedRSSI = nil
        candidateSince = nil
        lastSample = nil
        cooldownUntil = 0
    }

    public mutating func signalLost() {
        guard state != .disabled else { return }
        state = .unconfirmed
        candidateSince = nil
        smoothedRSSI = nil
    }

    public mutating func observe(rssi: Double, time: TimeInterval, authenticated: Bool) -> Action? {
        guard state != .disabled else { return nil }
        guard authenticated, rssi.isFinite, time.isFinite, (-110 ... -10).contains(rssi) else {
            signalLost()
            return nil
        }
        if let lastSample, time <= lastSample || time - lastSample > 5 {
            signalLost()
            return nil
        }
        lastSample = time
        guard state != .unconfirmed else { return nil }
        smoothedRSSI = smoothedRSSI.map { 0.35 * rssi + 0.65 * $0 } ?? rssi
        guard time >= cooldownUntil, let signal = smoothedRSSI else { return nil }
        switch state {
        case .far, .nearCandidate:
            if signal >= entry {
                candidateSince = candidateSince ?? time
                state = .nearCandidate
                if time - (candidateSince ?? time) >= dwell {
                    state = .unlockRequested
                    candidateSince = nil
                    return .unlock
                }
            } else {
                state = .far
                candidateSince = nil
            }
        case .unlocked, .exitCandidate:
            if signal <= exit {
                candidateSince = candidateSince ?? time
                state = .exitCandidate
                if time - (candidateSince ?? time) >= dwell {
                    state = .lockRequested
                    candidateSince = nil
                    return .lock
                }
            } else {
                state = .unlocked
                candidateSince = nil
            }
        default: break
        }
        return nil
    }

    public mutating func complete(_ action: Action, observed: Bool, time: TimeInterval) {
        guard (action == .unlock && state == .unlockRequested)
                || (action == .lock && state == .lockRequested) else { return }
        guard observed else { signalLost(); return }
        state = action == .unlock ? .unlocked : .far
        cooldownUntil = time + 8
        candidateSince = nil
    }
}
