import SwiftUI

struct CabinetView: View {
    @State private var selectedThemeID = PreviewData.themes.first?.id

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    stickerGrid
                    characterShelf
                    themeSelector
                    shareTemplates
                }
                .padding(20)
            }
            .background(ClayTheme.background.ignoresSafeArea())
        }
    }

    private var header: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Cabinet")
                    .font(.largeTitle.bold())
                    .foregroundStyle(ClayTheme.text)
                Text("Your white clay stickers, figures, themes, and share-card starting points.")
                    .font(.subheadline)
                    .foregroundStyle(ClayTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var stickerGrid: some View {
        claySection("Sticker Grid") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 12) {
                ForEach(PreviewData.stickers) { sticker in
                    VStack(spacing: 8) {
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.white.opacity(0.8))
                                .frame(height: 82)
                                .overlay(
                                    Image(systemName: sticker.isPremium ? "sparkles" : "seal.fill")
                                        .font(.title)
                                        .foregroundStyle(ClayTheme.text)
                                )
                                .modifier(ClayTheme.raisedShadow())

                            if sticker.isPremium {
                                premiumBadge
                                    .padding(6)
                            }
                        }

                        Text(sticker.name)
                            .font(.caption.bold())
                            .foregroundStyle(ClayTheme.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)

                        Text(sticker.rarity.displayName)
                            .font(.caption2)
                            .foregroundStyle(ClayTheme.secondaryText)
                    }
                }
            }
        }
    }

    private var characterShelf: some View {
        claySection("Character Shelf") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(PreviewData.characters) { character in
                        VStack(alignment: .leading, spacing: 10) {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white, ClayTheme.surface],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 112, height: 124)
                                .overlay(
                                    Image(systemName: character.unlocked ? "figure.stand" : "lock.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(ClayTheme.text.opacity(character.unlocked ? 1 : 0.45))
                                )
                                .modifier(ClayTheme.raisedShadow())

                            Text(character.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(ClayTheme.text)
                                .lineLimit(1)
                            Text(character.unlocked ? "Unlocked" : character.unlockRule)
                                .font(.caption2)
                                .foregroundStyle(ClayTheme.secondaryText)
                                .lineLimit(2)
                        }
                        .frame(width: 130, alignment: .leading)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var themeSelector: some View {
        claySection("Theme Selector") {
            VStack(spacing: 10) {
                ForEach(PreviewData.themes) { theme in
                    Button {
                        selectedThemeID = theme.id
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(theme.id == selectedThemeID ? ClayTheme.selected : ClayTheme.hairline)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .fill(.white.opacity(0.84))
                                        .padding(10)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(theme.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(ClayTheme.text)
                                    if theme.isPremium {
                                        premiumBadge
                                    }
                                }
                                Text("\(theme.lightingPreset), depth \(theme.surfaceDepth.formatted())")
                                    .font(.caption)
                                    .foregroundStyle(ClayTheme.secondaryText)
                            }

                            Spacer()

                            Image(systemName: theme.id == selectedThemeID ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(ClayTheme.text)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.white.opacity(0.7))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var shareTemplates: some View {
        claySection("Share Cards") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PreviewData.shareCardTemplates) { template in
                    ShareTemplateTile(template: template)
                }
            }
        }
    }

    private var premiumBadge: some View {
        Text("Premium")
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Capsule().fill(ClayTheme.selected))
    }

    private func claySection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ClayTheme.text)
                content()
            }
        }
    }
}

private struct ShareTemplateTile: View {
    let template: ShareCardTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.8))
                    .aspectRatio(1.15, contentMode: .fit)
                    .overlay(
                        Image(systemName: symbol)
                            .font(.title)
                            .foregroundStyle(ClayTheme.text)
                    )

                if template.isPremium {
                    Text("Premium")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(ClayTheme.selected))
                        .padding(8)
                }
            }

            Text(template.name)
                .font(.subheadline.bold())
                .foregroundStyle(ClayTheme.text)

            Text(template.description)
                .font(.caption)
                .foregroundStyle(ClayTheme.secondaryText)
                .lineLimit(2)
        }
    }

    private var symbol: String {
        switch template.id {
        case "daily-cup":
            "sun.max.fill"
        case "taste-notes":
            "text.bubble.fill"
        case "weekly-stack":
            "square.stack.3d.up.fill"
        default:
            "camera.fill"
        }
    }
}
