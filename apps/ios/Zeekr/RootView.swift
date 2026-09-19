import SwiftUI
import VehicleCore

struct RootView: View {
    @Bindable var model: AppModel
    var discovery: BluetoothDiscovery
    var body: some View {
        TabView(selection: $model.tab) {
            NavigationStack { VehicleView(model: model) }
                .tabItem { Label("Vehicle", systemImage: "car.side") }.tag(0)
            NavigationStack { ControlsView(model: model) }
                .tabItem { Label("Controls", systemImage: "square.grid.2x2") }.tag(1)
            NavigationStack { ProximityView(model: model) }
                .tabItem { Label("Proximity", systemImage: "sensor") }.tag(2)
            NavigationStack { ActivityView(model: model) }
                .tabItem { Label("Activity", systemImage: "clock.arrow.circlepath") }.tag(3)
        }
        .sheet(isPresented: $model.showSetup) { SetupView(model: model, discovery: discovery) }
        .sheet(item: $model.selectedControl) { capability in ControlDetail(model: model, capability: capability) }
    }
}

struct VehicleView: View {
    @Bindable var model: AppModel
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Eyebrow(text: "My vehicle")
                        Text("ZEEKR 001").font(.system(size: 34, weight: .semibold, design: .rounded)).tracking(-1)
                        Text("2024  /  GCC").font(.caption).tracking(2).foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    Button { model.showSetup = true } label: {
                        Image(systemName: "key.horizontal").font(.title3).frame(width: 48, height: 48)
                            .background(.white.opacity(0.06), in: Circle())
                    }.foregroundStyle(.white).accessibilityLabel("Key setup").accessibilityIdentifier("setup")
                }
                HStack {
                    StatusPill(title: model.demo ? "Demo mode" : "Key setup needed", color: model.demo ? Theme.amber : Theme.muted)
                    Spacer()
                    Label("Bluetooth only", systemImage: "antenna.radiowaves.left.and.right")
                        .font(.caption2).foregroundStyle(Theme.muted)
                }
                Image("Vehicle").resizable().aspectRatio(contentMode: .fit)
                    .mask(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.12), .init(color: .black, location: 0.80), .init(color: .clear, location: 1)], startPoint: .top, endPoint: .bottom))
                    .padding(.horizontal, -24).padding(.vertical, -12)
                    .accessibilityLabel("Silver ZEEKR 001 illustration")
                VStack(spacing: 8) {
                    Label(model.lockTitle, systemImage: model.simulatedLock == true && model.demo ? "lock.fill" : "lock.open")
                        .font(.title3.weight(.medium)).accessibilityIdentifier("lockState")
                }
                HStack(spacing: 12) {
                    Button { model.selectedControl = Capability.find("unlock") } label: { Label("Unlock", systemImage: "lock.open") }
                        .buttonStyle(ActionStyle()).accessibilityIdentifier("unlock")
                    Button { model.selectedControl = Capability.find("lock") } label: { Label("Lock", systemImage: "lock") }
                        .buttonStyle(ActionStyle(prominent: false)).accessibilityIdentifier("lock")
                }
                HStack(alignment: .top, spacing: 10) {
                    quickAction("trunkRelease", label: "Trunk", symbol: "car.side.rear.open")
                    quickAction("ventilation", label: "Ventilation", symbol: "fan")
                    quickAction("locate", label: "Locate", symbol: "light.beacon.max")
                    quickAction("chargeFlap", label: "Charge flap", symbol: "bolt.car")
                }
                VStack(spacing: 12) {
                    Button { model.tab = 2 } label: {
                        Panel {
                            HStack(spacing: 14) {
                                Image(systemName: "sensor").font(.title2).foregroundStyle(Theme.accent)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Proximity").font(.headline)
                                    Text("Approach unlock & walk-away lock").font(.caption).foregroundStyle(Theme.muted)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
                            }
                        }
                    }.buttonStyle(.plain)
                    Button { model.showSetup = true } label: {
                        HStack {
                            Label(model.demo ? "Demo settings" : "Set up your digital key", systemImage: "key")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }.font(.subheadline).foregroundStyle(Theme.muted).padding(16)
                    }.buttonStyle(.plain)
                }
            }.padding(24).frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
        }.background(Theme.background).toolbar(.hidden, for: .navigationBar)
    }

    private func quickAction(_ id: String, label: String, symbol: String) -> some View {
        Button { model.selectedControl = Capability.find(id) } label: {
            VStack(spacing: 10) {
                Image(systemName: symbol).font(.system(size: 22, weight: .light)).frame(height: 38)
                Text(label).font(.caption2).fixedSize(horizontal: false, vertical: true)
            }.foregroundStyle(.white.opacity(0.85)).frame(maxWidth: .infinity, minHeight: 76)
        }.buttonStyle(.plain)
    }
}
