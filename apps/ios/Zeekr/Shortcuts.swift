import AppIntents

struct OpenControlsIntent: AppIntent {
    static let title: LocalizedStringResource = "Open vehicle controls"
    static let description = IntentDescription("Open the local ZEEKR control catalog. This action sends no command.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(URL(string: "zeekr-local://controls")!))
    }
}

struct OpenProximityIntent: AppIntent {
    static let title: LocalizedStringResource = "Open proximity tests"
    static let description = IntentDescription("Open the local proximity demo. Live automatic access remains off.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(URL(string: "zeekr-local://proximity")!))
    }
}

struct ZeekrShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: OpenControlsIntent(), phrases: ["Open controls in \(.applicationName)"], shortTitle: "Vehicle controls", systemImageName: "car.side")
        AppShortcut(intent: OpenProximityIntent(), phrases: ["Open proximity in \(.applicationName)"], shortTitle: "Proximity tests", systemImageName: "sensor")
    }
}
