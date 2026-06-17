import SwiftUI
import UIKit

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
    let systemImage: String?
    let role: ButtonRole?
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }

    init(
        title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.init(title, systemImage: systemImage, role: role, action: action)
    }

    var body: some View {
        Button(role: role, action: action) {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .buttonStyle(ClayButtonStyle())
    }
}

struct ClayButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(ClayTheme.text)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: ClayTheme.controlRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white, ClayTheme.surface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ClayTheme.controlRadius, style: .continuous)
                    .stroke(.white.opacity(isEnabled ? 0.75 : 0.45), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(isEnabled ? (configuration.isPressed ? 0.035 : 0.08) : 0.025),
                radius: configuration.isPressed ? 8 : 18,
                x: configuration.isPressed ? 4 : 10,
                y: configuration.isPressed ? 6 : 14
            )
            .shadow(
                color: Color.white.opacity(isEnabled ? 0.95 : 0.55),
                radius: configuration.isPressed ? 4 : 8,
                x: configuration.isPressed ? -2 : -4,
                y: configuration.isPressed ? -2 : -5
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .offset(y: configuration.isPressed ? 1 : 0)
            .opacity(isEnabled ? 1 : 0.52)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.12), value: isEnabled)
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

enum DrinkPhotoPlaceholderSize {
    case compact
    case large
}

struct DrinkPhotoPlaceholder: View {
    let recordName: String
    let style: String
    let size: DrinkPhotoPlaceholderSize

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.91, blue: 0.80),
                    Color(red: 0.73, green: 0.82, blue: 0.78),
                    Color(red: 0.47, green: 0.55, blue: 0.62)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.22))
                .frame(width: size == .large ? 190 : 62, height: size == .large ? 190 : 62)
                .offset(x: size == .large ? 92 : 24, y: size == .large ? -76 : -22)

            VStack(spacing: size == .large ? 14 : 4) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(size == .large ? .system(size: 54, weight: .semibold) : .title3)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 5)

                if size == .large {
                    Text(recordName.isEmpty ? "Coffee" : recordName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(style.isEmpty ? "Tap to add a photo" : style)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(1)
                }
            }
            .padding(size == .large ? 18 : 6)
        }
    }
}

struct DrinkRecordPhoto: View {
    let record: DrinkRecord
    let size: DrinkPhotoPlaceholderSize

    var body: some View {
        if let photoData = record.photoData,
           let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            DrinkPhotoPlaceholder(recordName: record.name, style: record.style, size: size)
        }
    }
}
