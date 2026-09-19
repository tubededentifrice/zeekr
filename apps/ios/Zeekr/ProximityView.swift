import SwiftUI
import Combine
import VehicleCore

struct ProximityView: View {
    @Bindable var model: AppModel
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var armed: Bool { model.proximity.state != .disabled }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        ForEach(0..<3) { index in
                            Circle().stroke(Theme.accent.opacity(0.06 + Double(index) * 0.04), lineWidth: 1)
                                .frame(width: CGFloat(100 + index * 62), height: CGFloat(100 + index * 62))
                        }
                        Circle().fill(Theme.accent.opacity(0.06)).frame(width: 100, height: 100)
                        Image(systemName: "car.side.fill").font(.system(size: 36, weight: .light)).foregroundStyle(Theme.accent)
                        if model.demo && armed {
                            Circle().fill(Theme.accent).frame(width: 10, height: 10)
                                .offset(x: CGFloat((model.demoRSSI + 100) * 1.1), y: -65)
                        }
                    }.frame(maxWidth: .infinity).frame(height: 224).accessibilityHidden(true)
                }
                Panel {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Automatic access").font(.headline)
                            Spacer()
                            StatusPill(title: "Live use off", color: Theme.muted)
                        }
                    }
                }
                if !model.demo {
                    Button("Demo settings") { model.showSetup = true }.buttonStyle(ActionStyle())
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Eyebrow(text: "Proximity demo")
                        Panel {
                            VStack(alignment: .leading, spacing: 18) {
                                HStack {
                                    Text(model.proximity.state.rawValue).font(.headline).accessibilityIdentifier("proximityState")
                                    Spacer()
                                    Image(systemName: "waveform.path").foregroundStyle(Theme.accent)
                                }
                                HStack(alignment: .firstTextBaseline) {
                                    Text("\(Int(model.demoRSSI))").font(.system(size: 42, weight: .light, design: .rounded)).monospacedDigit()
                                    Text("dBm").font(.caption).foregroundStyle(Theme.muted)
                                    Spacer()
                                    Text(model.proximity.smoothedRSSI.map { "Filtered: \(Int($0))" } ?? "No sample")
                                        .font(.caption).foregroundStyle(Theme.muted)
                                }
                                Slider(value: $model.demoRSSI, in: -100 ... -35, step: 1).accessibilityLabel("Synthetic signal strength")
                                HStack {
                                    Button("Far") { model.demoRSSI = -88 }
                                    Spacer()
                                    Button("Near") { model.demoRSSI = -45 }
                                    Spacer()
                                    Button("Signal lost") { model.loseSignal() }
                                }.font(.subheadline).frame(minHeight: 44)
                                Button(armed ? "Stop demo" : "Start proximity demo") {
                                    if armed { model.cancelTest(); model.proximity.disable() }
                                    else { model.armProximity() }
                                }.buttonStyle(ActionStyle()).disabled(model.busy && !armed).accessibilityIdentifier("armProximity")
                            }
                        }
                        Panel {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Demo policy").font(.headline)
                                Text("Approach threshold: \(Int(model.entryThreshold)) dBm").font(.subheadline)
                                Slider(value: $model.entryThreshold, in: -65 ... -40, step: 1).accessibilityLabel("Approach threshold")
                                Text("Departure threshold: \(Int(model.exitThreshold)) dBm").font(.subheadline)
                                Slider(value: $model.exitThreshold, in: -95 ... -70, step: 1).accessibilityLabel("Departure threshold")
                                Stepper("Dwell: \(Int(model.dwell)) seconds", value: $model.dwell, in: 1 ... 10).font(.subheadline)
                                Picker("Response", selection: $model.demoOutcome) {
                                    ForEach(DemoOutcome.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                                }
                            }.disabled(armed)
                        }
                    }
                }
            }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("Proximity")
            .onReceive(timer) { _ in model.tick() }
    }
}
