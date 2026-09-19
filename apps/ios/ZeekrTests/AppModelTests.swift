import XCTest
import VehicleCore
@testable import Zeekr

@MainActor
final class AppModelTests: XCTestCase {
    func testLiveCommandIsBlocked() {
        let model = AppModel(persist: false)
        model.run(Capability.find("unlock")!)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.simulatedLock)
        XCTAssertEqual(model.events.first?.stage, .blocked)
    }

    func testModeChangeCancelsInFlightDemo() async throws {
        let model = AppModel(persist: false)
        model.setDemo(true)
        model.run(Capability.find("unlock")!)
        try await Task.sleep(for: .milliseconds(400))
        model.setDemo(false)
        let count = model.events.count
        try await Task.sleep(for: .seconds(2))
        XCTAssertEqual(model.events.count, count)
        XCTAssertNil(model.simulatedLock)
        XCTAssertFalse(model.busy)
        XCTAssertFalse(model.events.contains { $0.stage == .observed })
    }

    func testReceiptOnlyDoesNotSetLockState() async throws {
        let model = AppModel(persist: false)
        model.setDemo(true)
        model.demoOutcome = .receiptOnly
        model.run(Capability.find("lock")!)
        try await Task.sleep(for: .seconds(2))
        XCTAssertNil(model.simulatedLock)
        XCTAssertEqual(model.events.first?.stage, .uncertain)
        XCTAssertFalse(model.busy)
    }

    func testBackgroundStopsProximity() {
        let model = AppModel(persist: false)
        model.setDemo(true)
        model.armProximity()
        XCTAssertEqual(model.proximity.state, .far)
        model.background()
        XCTAssertEqual(model.proximity.state, .disabled)
    }

    func testControlChangeClearsPreviousNoticeAndDoesNotReceiveAnotherResult() async throws {
        let model = AppModel(persist: false)
        model.setDemo(true)
        let lock = Capability.find("lock")!
        let unlock = Capability.find("unlock")!
        model.selectedControl = lock
        model.run(lock)
        try await Task.sleep(for: .seconds(2))
        XCTAssertEqual(model.notice, "Demo complete.")
        model.selectedControl = unlock
        XCTAssertNil(model.notice)
        model.run(unlock)
        model.selectedControl = Capability.find("acStart")!
        try await Task.sleep(for: .seconds(2))
        XCTAssertNil(model.notice)
        XCTAssertEqual(model.simulatedLock, false)
    }

    func testSuccessfulDemoHasExplicitObservedStateAndSafeReport() async throws {
        let model = AppModel(persist: false)
        model.setDemo(true)
        model.run(Capability.find("lock")!)
        try await Task.sleep(for: .seconds(2))
        XCTAssertEqual(model.simulatedLock, true)
        XCTAssertTrue(model.report.contains("DEMO"))
        XCTAssertTrue(model.report.contains("No target-car commands"))
        model.clearHistory()
        XCTAssertTrue(model.events.isEmpty)
    }
}
