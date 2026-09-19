import SwiftUI
import VehicleCore

struct ActivityView: View {
    @Bindable var model: AppModel
    @State private var clear = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if model.events.isEmpty {
                    ContentUnavailableView("No activity", systemImage: "clock.badge.checkmark")
                } else {
                    ForEach(model.events) { event in
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: symbol(event.stage)).foregroundStyle(event.stage == .observed ? Theme.accent : Theme.muted)
                                .frame(width: 24, height: 24)
                            VStack(alignment: .leading, spacing: 7) {
                                HStack(alignment: .top) {
                                    Text(event.command).font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(event.demo ? "DEMO" : "SETUP").font(.system(.caption2, design: .monospaced)).foregroundStyle(Theme.amber)
                                }
                                Text(event.stage.rawValue).font(.subheadline).foregroundStyle(Theme.accent)
                                Text(event.date, format: .dateTime.month().day().hour().minute().second()).font(.caption2).foregroundStyle(Theme.muted)
                            }
                        }.padding(18).background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
                    }
                }
            }.padding(24).frame(maxWidth: 700).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: model.report) { Image(systemName: "square.and.arrow.up") }.accessibilityLabel("Share test report")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { clear = true } label: { Image(systemName: "trash") }.disabled(model.events.isEmpty || model.busy).accessibilityLabel("Clear test history")
                }
            }
            .confirmationDialog("Delete local test history?", isPresented: $clear, titleVisibility: .visible) {
                Button("Delete history", role: .destructive) { model.clearHistory() }
            }
    }

    private func symbol(_ stage: CommandStage) -> String {
        switch stage {
        case .observed: "eye"
        case .sent: "arrow.up.right"
        case .received: "arrow.down.left"
        case .result: "checkmark.circle"
        case .blocked, .rejected: "xmark.circle"
        case .timedOut: "clock"
        case .uncertain: "questionmark.circle"
        }
    }
}
