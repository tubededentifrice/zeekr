import Testing
@testable import VehicleCore

@Test func liveCommandsRemainBlocked() {
    for control in Capability.all {
        #expect(CommandGate.reason(for: control, demo: false, busy: false) != nil)
    }
    #expect(CommandGate.reason(for: Capability.find("unlock")!, demo: true, busy: false) == nil)
    #expect(CommandGate.reason(for: Capability.find("unlock")!, demo: true, busy: true) != nil)
    #expect(CommandGate.reason(for: Capability.find("parking")!, demo: true, busy: false) != nil)
    #expect(CommandGate.reason(for: Capability.find("acStart")!, demo: true, busy: false) != nil)
}

@Test func uncertainResultsNeverObserveState() {
    for result in [DemoOutcome.receiptOnly, .rejected, .timeout, .linkLost] {
        #expect(!result.stages.contains(.observed))
    }
    #expect(DemoOutcome.observed.stages.last == .observed)
}

@Test func catalogHasNoDuplicateIDsAndNoEmptyReasons() {
    #expect(Set(Capability.all.map(\.id)).count == Capability.all.count)
    #expect(Capability.all.allSatisfy { !$0.evidence.isEmpty && !$0.liveBlockReason.isEmpty })
}

@Test func proximityRequiresArmAndDwell() {
    var policy = ProximityPolicy()
    #expect(policy.observe(rssi: -40, time: 0, authenticated: true) == nil)
    policy.arm()
    for time in 0..<3 { #expect(policy.observe(rssi: -40, time: Double(time), authenticated: true) == nil) }
    #expect(policy.observe(rssi: -40, time: 3, authenticated: true) == .unlock)
    for time in 4...10 { #expect(policy.observe(rssi: -40, time: Double(time), authenticated: true) == nil) }
    #expect(policy.state == .unlockRequested)
}

@Test func noReplyCannotBecomeUnlocked() {
    var policy = ProximityPolicy(dwell: 1)
    policy.arm()
    _ = policy.observe(rssi: -40, time: 0, authenticated: true)
    #expect(policy.observe(rssi: -40, time: 1, authenticated: true) == .unlock)
    policy.complete(.unlock, observed: false, time: 2)
    #expect(policy.state == .unconfirmed)
    for time in 3...20 { #expect(policy.observe(rssi: -40, time: Double(time), authenticated: true) == nil) }
}

@Test func walkAwayWaitsForCooldownAndObservation() {
    var policy = ProximityPolicy(dwell: 1)
    policy.arm()
    _ = policy.observe(rssi: -40, time: 0, authenticated: true)
    _ = policy.observe(rssi: -40, time: 1, authenticated: true)
    policy.complete(.unlock, observed: true, time: 1)
    for time in 2...8 { #expect(policy.observe(rssi: -95, time: Double(time), authenticated: true) == nil) }
    #expect(policy.observe(rssi: -95, time: 9, authenticated: true) == nil)
    #expect(policy.observe(rssi: -95, time: 10, authenticated: true) == .lock)
    #expect(policy.state == .lockRequested)
    policy.signalLost()
    policy.complete(.lock, observed: true, time: 11)
    #expect(policy.state == .unconfirmed)
}

@Test func staleInvalidAndUnauthenticatedSignalsStopActions() {
    for variant in 0...4 {
        var policy = ProximityPolicy()
        policy.arm()
        _ = policy.observe(rssi: -40, time: 10, authenticated: true)
        switch variant {
        case 0: _ = policy.observe(rssi: -40, time: 16, authenticated: true)
        case 1: _ = policy.observe(rssi: -40, time: 9, authenticated: true)
        case 2: _ = policy.observe(rssi: 127, time: 11, authenticated: true)
        case 3: _ = policy.observe(rssi: .nan, time: 11, authenticated: true)
        default: _ = policy.observe(rssi: -40, time: 11, authenticated: false)
        }
        #expect(policy.state == .unconfirmed)
        #expect(policy.observe(rssi: -40, time: 17, authenticated: true) == nil)
    }
}

@Test func interruptedDwellDoesNotTriggerUnlock() {
    var policy = ProximityPolicy(dwell: 3)
    policy.arm()
    _ = policy.observe(rssi: -58, time: 0, authenticated: true)
    _ = policy.observe(rssi: -90, time: 1, authenticated: true)
    #expect(policy.state == .far)
    for time in 2...4 { #expect(policy.observe(rssi: -40, time: Double(time), authenticated: true) == nil) }
}

@Test func invalidConfigurationCannotArm() {
    for configuration in [(Double.nan, -74.0, 3.0), (-80.0, -60.0, 3.0), (-58.0, -74.0, 0.0)] {
        var policy = ProximityPolicy(entry: configuration.0, exit: configuration.1, dwell: configuration.2)
        policy.arm()
        #expect(policy.state == .disabled)
    }
}

@Test func disableClearsPendingWork() {
    var policy = ProximityPolicy()
    policy.arm()
    _ = policy.observe(rssi: -40, time: 1, authenticated: true)
    policy.disable()
    policy.complete(.unlock, observed: true, time: 2)
    #expect(policy.state == .disabled)
    #expect(policy.smoothedRSSI == nil)
}
