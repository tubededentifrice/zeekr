import Foundation

public enum ControlGroup: String, CaseIterable, Sendable {
    case access = "Access"
    case climate = "Climate"
    case openings = "Doors and windows"
    case charging = "Charging"
    case comfort = "Comfort"
    case key = "Key and proximity"
    case other = "Other functions"
}

public struct Capability: Identifiable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let symbol: String
    public let group: ControlGroup
    public let evidence: String
    public let demoAvailable: Bool
    public let needsConfirmation: Bool

    public var liveBlockReason: String {
        demoAvailable
            ? "Key enrollment and vehicle authentication are not ready. No target-car test has passed."
            : evidence
    }

    private init(_ id: String, _ title: String, _ symbol: String, _ group: ControlGroup,
                 _ evidence: String, demo: Bool = false, confirm: Bool = false) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.group = group
        self.evidence = evidence
        demoAvailable = demo
        needsConfirmation = confirm
    }

    public static func find(_ id: String) -> Capability? { all.first { $0.id == id } }

    public static let all: [Capability] = [
        .init("unlock", "Unlock", "lock.open", .access, "OpenZeekr reports BLE unlock on an EU car. GCC test pending.", demo: true),
        .init("lock", "Lock", "lock", .access, "OpenZeekr reports BLE lock on an EU car. GCC test pending.", demo: true),
        .init("locate", "Lights and horn", "light.beacon.max", .access, "A combined locator is mapped in the source. The physical pattern is untested.", demo: true, confirm: true),
        .init("panic", "Panic search", "exclamationmark.triangle", .access, "A source constant exists. Its behavior is unknown."),
        .init("frunk", "Release front hood", "car.side.front.open", .openings, "Source mapping only. Hardware and movement are unknown.", demo: true, confirm: true),
        .init("trunkRelease", "Release trunk latch", "car.side.rear.open", .openings, "Source mapping only. This does not prove powered opening.", demo: true, confirm: true),
        .init("trunkLock", "Lock trunk latch", "lock.rectangle", .openings, "Source mapping only. This does not prove powered closing.", demo: true, confirm: true),
        .init("windowsUp", "Raise windows", "arrow.up.square", .openings, "Source mapping only. Extent and anti-pinch behavior need tests.", demo: true, confirm: true),
        .init("windowsDown", "Lower windows", "arrow.down.square", .openings, "Source mapping only. Extent needs a target-car test.", demo: true, confirm: true),
        .init("ventilation", "Cabin ventilation", "fan", .climate, "A BLE byte exists. Actual cooling and a stop command are not confirmed.", demo: true),
        .init("acStart", "Start AC", "snowflake", .climate, "No confirmed BLE method. Ventilation does not prove cooling."),
        .init("acStop", "Stop AC", "power", .climate, "No confirmed BLE method."),
        .init("acTemperature", "AC temperature", "thermometer.medium", .climate, "No confirmed BLE method."),
        .init("acDuration", "AC duration", "timer", .climate, "No confirmed BLE method."),
        .init("ventilationStop", "Stop ventilation", "fan.slash", .climate, "No confirmed BLE method."),
        .init("defrost", "Defrost", "windshield.front.and.heat.waves", .climate, "No confirmed BLE method."),
        .init("chargeFlap", "Open charge flap", "bolt.car", .charging, "Source mapping only. Target-car test pending.", demo: true, confirm: true),
        .init("chargeFlapClose", "Close charge flap", "bolt.car", .charging, "No confirmed BLE method."),
        .init("chargeStart", "Start charging", "bolt", .charging, "No confirmed BLE method."),
        .init("chargeStop", "Stop charging", "stop.circle", .charging, "No confirmed BLE method."),
        .init("chargeTarget", "Charge limit", "battery.80percent", .charging, "No confirmed BLE method."),
        .init("preheat", "Battery preheat", "battery.100percent.bolt", .charging, "No confirmed BLE method."),
        .init("schedules", "Charge and departure times", "calendar", .charging, "No confirmed BLE method. Outside the first release scope."),
        .init("seatHeat", "Seat heat", "carseat.left.and.heat.waves", .comfort, "No confirmed BLE method for any seat."),
        .init("seatVent", "Seat ventilation", "carseat.left.fan", .comfort, "No confirmed BLE method for any seat."),
        .init("wheelHeat", "Steering wheel heat", "steeringwheel", .comfort, "No confirmed BLE method."),
        .init("fragrance", "Fragrance", "sparkles", .comfort, "No confirmed BLE method. Equipment dependent."),
        .init("fridge", "Fridge", "refrigerator", .comfort, "No confirmed BLE method. Equipment dependent."),
        .init("tailgateOpen", "Open powered tailgate", "car.side.rear.open", .openings, "Latch release does not prove powered opening. No confirmed BLE method."),
        .init("tailgateClose", "Close powered tailgate", "car.side.rear.open", .openings, "Latch lock does not prove powered closing. No confirmed BLE method."),
        .init("windowVent", "Window vent position", "window.horizontal", .openings, "The source does not map this to cabin ventilation."),
        .init("sunroof", "Sunroof", "sun.max", .openings, "No confirmed BLE method. Equipment dependent."),
        .init("sunshade", "Sunshade", "sun.min", .openings, "No confirmed BLE method. Equipment dependent."),
        .init("approach", "Approach unlock", "figure.walk.arrival", .key, "The local demo can test the policy. Live use needs enrollment, calibration, and background tests."),
        .init("walkAway", "Walk-away lock", "figure.walk.departure", .key, "The local demo can test the policy. BLE-only locking is not confirmed on the target car."),
        .init("vehicleApproach", "Vehicle approach setting", "sensor", .key, "Source constant only. The vehicle function is untested."),
        .init("vehicleWalkAway", "Vehicle walk-away setting", "sensor.fill", .key, "Experimental source path. Calibration and target tests are required."),
        .init("autoLockEvent", "Vehicle auto-lock event", "bell", .key, "A source event exists. No target-car decoder is ready."),
        .init("drive", "Drive authorization", "steeringwheel", .key, "Authenticated key presence requires a separate GCC start and restart test."),
        .init("enrollment", "Enroll key", "key", .key, "Online enrollment is a separate setup step. The GCC route is unresolved."),
        .init("sharing", "Share key", "person.2", .key, "The GCC enrollment and sharing route is unresolved."),
        .init("revoke", "Revoke key", "key.slash", .key, "Vehicle revocation is separate from local deletion. Enrollment is not ready."),
        .init("keyInside", "Key inside signal", "key.horizontal", .key, "Protocol constant only. This is not a user command."),
        .init("keyOutside", "Key outside signal", "key.horizontal", .key, "Protocol constant only. This is not a user command."),
        .init("engineStart", "Remote engine start", "engine.combustion", .other, "Constant only. This is not AC or drive authorization."),
        .init("engineStop", "Remote engine stop", "engine.combustion", .other, "No confirmed BLE method."),
        .init("flash", "Flash lights", "lightbulb", .other, "A separate light command is not confirmed. The combined locator is listed under Access."),
        .init("horn", "Sound horn", "speaker.wave.2", .other, "A separate horn command is not confirmed."),
        .init("sentry", "Sentry mode", "shield", .other, "No confirmed BLE method."),
        .init("locker", "Private locker", "lock.square", .other, "No confirmed BLE method."),
        .init("glovebox", "Glovebox lock", "lock.rectangle", .other, "No confirmed BLE method."),
        .init("visitor", "Visitor mode", "person.crop.circle", .other, "No confirmed BLE method."),
        .init("status", "Vehicle status", "gauge.with.dots.needle.50percent", .other, "No complete BLE decoder for lock state, battery, range, or tire pressure."),
        .init("location", "Location and journeys", "map", .other, "No confirmed BLE method. Outside the first release scope."),
        .init("camera", "Camera and live view", "video", .other, "No confirmed BLE method. Outside the first release scope."),
        .init("parking", "Remote parking", "parkingsign.circle", .other, "Vehicle motion is excluded. It must not be used as a connection check.")
    ]
}

public enum CommandStage: String, Codable, Sendable, CaseIterable {
    case blocked = "Blocked"
    case sent = "Sent"
    case received = "Received"
    case result = "Result received"
    case rejected = "Rejected"
    case timedOut = "Timed out"
    case uncertain = "Outcome unknown"
    case observed = "State observed"
}

public enum DemoOutcome: String, CaseIterable, Sendable {
    case observed = "State observed"
    case receiptOnly = "Receipt only"
    case rejected = "Rejected"
    case timeout = "No reply"
    case linkLost = "Link lost after send"

    public var stages: [CommandStage] {
        switch self {
        case .observed: [.sent, .received, .result, .observed]
        case .receiptOnly: [.sent, .received, .uncertain]
        case .rejected: [.sent, .rejected]
        case .timeout: [.sent, .timedOut]
        case .linkLost: [.sent, .uncertain]
        }
    }
}

public enum CommandGate {
    public static func reason(for capability: Capability, demo: Bool, busy: Bool) -> String? {
        if busy { return "Wait for the current test to finish." }
        if !demo { return capability.liveBlockReason }
        if !capability.demoAvailable { return capability.evidence }
        return nil
    }
}
