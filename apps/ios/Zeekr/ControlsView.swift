import SwiftUI
import VehicleCore

struct ControlsView: View {
    @Bindable var model: AppModel
    @State private var search = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(ControlGroup.allCases, id: \.self) { group in
                    let controls = Capability.all.filter { $0.group == group && (search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)) }
                    if !controls.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Eyebrow(text: group.rawValue)
                            VStack(spacing: 0) {
                                ForEach(controls) { capability in
                                    Button { model.selectedControl = capability } label: {
                                        HStack(spacing: 14) {
                                            Image(systemName: capability.symbol).font(.title3).frame(width: 27).foregroundStyle(Theme.accent)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(capability.title).font(.subheadline.weight(.medium)).foregroundStyle(.white)
                                                Text(model.demo && capability.demoAvailable ? "Demo test available" : (capability.demoAvailable ? "Key setup needed" : "Not available"))
                                                    .font(.caption).foregroundStyle(Theme.muted)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
                                        }.padding(17).contentShape(Rectangle())
                                    }.buttonStyle(.plain).accessibilityIdentifier("control-\(capability.id)")
                                    if capability.id != controls.last?.id { Divider().padding(.leading, 58) }
                                }
                            }.background(Theme.card, in: RoundedRectangle(cornerRadius: 22))
                        }
                    }
                }
                if !search.isEmpty && !Capability.all.contains(where: { $0.title.localizedCaseInsensitiveContains(search) }) {
                    ContentUnavailableView.search(text: search)
                }
            }.padding(24).frame(maxWidth: 700).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("Controls")
            .searchable(text: $search, prompt: "Find a control")
    }
}

struct ControlDetail: View {
    @Bindable var model: AppModel
    let capability: Capability
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: capability.symbol).font(.system(size: 42, weight: .light)).foregroundStyle(Theme.accent)
                        .frame(width: 84, height: 84).background(Theme.card, in: RoundedRectangle(cornerRadius: 24))
                    Text(capability.title).font(.largeTitle.bold())
                    StatusPill(title: model.demo && capability.demoAvailable ? "Demo test" : "Not available", color: Theme.amber)
                    if let reason = CommandGate.reason(for: capability, demo: model.demo, busy: false) {
                        Text(capability.demoAvailable ? "Key setup required." : reason)
                            .font(.subheadline).foregroundStyle(Theme.muted).accessibilityIdentifier("blockedReason")
                        if capability.demoAvailable && !model.demo {
                            Button("Demo settings") { dismiss(); model.showSetup = true }.buttonStyle(ActionStyle())
                        }
                    } else {
                        Picker("Test response", selection: $model.demoOutcome) {
                            ForEach(DemoOutcome.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }.pickerStyle(.menu).tint(Theme.accent).disabled(model.busy)
                        Button {
                            model.run(capability)
                        } label: {
                            HStack {
                                if model.busy { ProgressView().tint(Theme.background) }
                                Text(model.busy ? "Running demo…" : "Run demo test")
                            }
                        }.buttonStyle(ActionStyle()).disabled(model.busy).accessibilityIdentifier("runDemo")
                    }
                    if let notice = model.notice {
                        Text(notice).font(.subheadline).foregroundStyle(Theme.accent).accessibilityIdentifier("testNotice")
                    }
                    if capability.id == "lock" || capability.id == "unlock" {
                        Label(model.lockTitle, systemImage: "lock.shield").font(.headline).accessibilityIdentifier("detailLockState")
                    }
                    DisclosureGroup("Compatibility") {
                        Text(capability.evidence).font(.footnote).foregroundStyle(Theme.muted).padding(.top, 8)
                    }.font(.subheadline).foregroundStyle(Theme.muted)
                    Button("View test activity") { dismiss(); model.tab = 3 }.foregroundStyle(Theme.muted).frame(minHeight: 44)
                }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
            }.background(Theme.background)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }

        }.presentationDragIndicator(.visible)
    }
}
