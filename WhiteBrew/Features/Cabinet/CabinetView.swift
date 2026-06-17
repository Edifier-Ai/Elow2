import SwiftUI

struct CabinetView: View {
    @State private var selectedThemeID = PreviewData.themes.first?.id

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    themeSelector
                    shareTemplates
                    stickerGrid
                    characterShelf
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(ClayTheme.background.ignoresSafeArea())
        }
    }

    private var header: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("丰富主题")
                    .font(.largeTitle.bold())
                    .foregroundStyle(ClayTheme.text)
                Text("用颜色，定制你的咖啡美学。")
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
        VStack(alignment: .leading, spacing: 14) {
            ClayCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("把喜欢的每一杯留下")
                        .font(.title2.bold())
                        .foregroundStyle(ClayTheme.text)
                    Text("主题色会同步作用到首页、趋势页和个人中心。")
                        .font(.caption)
                        .foregroundStyle(ClayTheme.secondaryText)

                    HStack(spacing: 12) {
                        SoftPreviewMetric(title: "总杯数", value: "126")
                        SoftPreviewMetric(title: "本周", value: "12")
                        SoftPreviewMetric(title: "评分", value: "4.8")
                    }
                }
            }

            Text("颜色主题")
                .font(.headline)
                .foregroundStyle(ClayTheme.text)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PreviewData.themes) { theme in
                    Button {
                        selectedThemeID = theme.id
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            ThemeSwatchRow(theme: theme)
                                .frame(height: 58)
                                .background(ClayTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(theme.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(ClayTheme.text)
                                    if theme.isPremium {
                                        premiumBadge
                                    }
                                }
                                Text(theme.lightingPreset)
                                    .font(.caption)
                                    .foregroundStyle(ClayTheme.secondaryText)
                            }

                            if theme.id == selectedThemeID {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ClayTheme.accentSage)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(ClayTheme.paper)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(theme.id == selectedThemeID ? ClayTheme.accentSage : ClayTheme.hairline, lineWidth: 1)
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

private struct SoftPreviewMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(ClayTheme.accentSage)
            Text(title)
                .font(.caption2)
                .foregroundStyle(ClayTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ClayTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ThemeSwatchRow: View {
    let theme: BrewTheme

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(primaryColor)
            Circle().fill(secondaryColor)
            Circle().fill(Color(red: 0.86, green: 0.76, blue: 0.55))
            Circle().fill(Color(red: 0.96, green: 0.86, blue: 0.52))
        }
        .padding(.horizontal, 14)
    }

    private var primaryColor: Color {
        switch theme.id {
        case "gallery-white": ClayTheme.accentCoffee
        case "studio-clay": ClayTheme.accentSage
        default: Color(red: 0.45, green: 0.55, blue: 0.72)
        }
    }

    private var secondaryColor: Color {
        switch theme.id {
        case "gallery-white": Color(red: 0.70, green: 0.45, blue: 0.32)
        case "studio-clay": Color(red: 0.70, green: 0.52, blue: 0.40)
        default: Color(red: 0.72, green: 0.42, blue: 0.62)
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
