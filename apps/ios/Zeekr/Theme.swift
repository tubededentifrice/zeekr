import SwiftUI

enum Theme {
    static let background = Color(red: 0.045, green: 0.055, blue: 0.065)
    static let card = Color(red: 0.085, green: 0.10, blue: 0.115)
    static let accent = Color(red: 0.80, green: 0.91, blue: 0.74)
    static let muted = Color(red: 0.62, green: 0.66, blue: 0.69)
    static let amber = Color(red: 1, green: 0.77, blue: 0.42)
}

struct Panel<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content.padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.055)))
    }
}

struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.system(.caption2, design: .monospaced, weight: .medium))
            .tracking(2).foregroundStyle(Theme.muted)
    }
}

struct StatusPill: View {
    let title: String
    var color: Color = Theme.accent
    var body: some View {
        HStack(spacing: 7) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text(title).font(.caption.weight(.medium))
        }.foregroundStyle(color).padding(.horizontal, 12).padding(.vertical, 8)
            .background(color.opacity(0.09), in: Capsule())
    }
}

struct ActionStyle: ButtonStyle {
    var prominent = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(prominent ? Theme.background : .white)
            .background(prominent ? Theme.accent : Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 17))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
