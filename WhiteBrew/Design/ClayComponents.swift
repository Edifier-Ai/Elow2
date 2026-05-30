import SwiftUI

struct ClayCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: ClayTheme.cardRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ClayTheme.raised, ClayTheme.surface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ClayTheme.cardRadius, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
            )
            .modifier(ClayTheme.raisedShadow())
    }
}

struct ClayButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(ClayTheme.text)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white, ClayTheme.surface],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .modifier(ClayTheme.raisedShadow())
        }
        .buttonStyle(.plain)
    }
}

struct ClayMetricTile: View {
    let label: String
    let value: String

    var body: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(ClayTheme.secondaryText)
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(ClayTheme.text)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}
