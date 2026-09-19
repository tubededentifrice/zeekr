import SwiftUI

@main
struct ZeekrApp: App {
    @State private var model = AppModel(persist: !ProcessInfo.processInfo.arguments.contains("--ui-testing"))
    @State private var discovery = BluetoothDiscovery()
    @Environment(\.scenePhase) private var phase

    var body: some Scene {
        WindowGroup {
            RootView(model: model, discovery: discovery)
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
                .onChange(of: phase) { _, phase in
                    if phase != .active {
                        model.background()
                        discovery.stop()
                    }
                }
                .onOpenURL { url in
                    guard url.scheme == "zeekr-local" else { return }
                    model.tab = url.host == "proximity" ? 2 : 1
                }
        }
    }
}
