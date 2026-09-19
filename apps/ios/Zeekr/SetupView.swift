import SwiftUI

struct SetupView: View {
    @Bindable var model: AppModel
    var discovery: BluetoothDiscovery
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Panel {
                        HStack(spacing: 14) {
                            Image(systemName: "key.horizontal").font(.title2).foregroundStyle(Theme.accent)
                            Text("Digital key").font(.headline)
                            Spacer()
                            StatusPill(title: "Not enrolled", color: Theme.muted)
                        }
                    }
                    Panel {
                        Toggle("Demo mode", isOn: Binding(get: { model.demo }, set: { enabled in
                            discovery.stop()
                            model.setDemo(enabled)
                        })).font(.headline).accessibilityIdentifier("demoToggle")
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Eyebrow(text: "Bluetooth discovery")
                        Panel {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "antenna.radiowaves.left.and.right").foregroundStyle(Theme.accent)
                                    Text(discovery.status).font(.headline)
                                    Spacer()
                                    if discovery.scanning { ProgressView() }
                                }
                                Button(discovery.scanning ? "Stop scan" : "Scan nearby signals") {
                                    if discovery.scanning { discovery.stop() }
                                    else { discovery.start() }
                                }.buttonStyle(ActionStyle(prominent: false)).accessibilityIdentifier("scanBluetooth")
                                ForEach(discovery.candidates) { candidate in
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(candidate.label).font(.subheadline.weight(.medium))
                                            Spacer()
                                            Text("\(candidate.rssi) dBm").font(.subheadline.monospacedDigit())
                                        }
                                        Text("Identity unverified").font(.caption).foregroundStyle(Theme.muted)
                                        Text(candidate.lastSeen, style: .relative).font(.caption2).foregroundStyle(Theme.muted)
                                    }
                                }
                                if discovery.status == "Bluetooth access denied" {
                                    Button("Open iOS settings") {
                                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                                    }.font(.footnote).frame(minHeight: 44)
                                }
                            }
                        }
                    }
                }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
            }.background(Theme.background).navigationTitle("Key setup")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }.presentationDragIndicator(.visible).onDisappear { discovery.stop() }
    }
}
