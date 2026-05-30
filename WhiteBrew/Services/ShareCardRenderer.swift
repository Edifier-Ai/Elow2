import SwiftUI
import UIKit

struct ShareCardContent: Equatable {
    let name: String
    let style: String
    let ratingText: String
    let caffeineText: String
    let sugarText: String
    let note: String
    let brand: String

    init(record: DrinkRecord) {
        name = record.name
        style = record.style
        ratingText = "\(record.rating)/5"
        caffeineText = "\(record.caffeineMG ?? 0) mg"
        sugarText = record.sugarLevel.rawValue
        note = record.note
        brand = "White Brew"
    }
}

struct ShareCardView: View {
    let record: DrinkRecord

    private var content: ShareCardContent {
        ShareCardContent(record: record)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text(content.brand.uppercased())
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(ClayTheme.secondaryText)

            Spacer(minLength: 120)

            VStack(alignment: .leading, spacing: 18) {
                Text(content.name)
                    .font(.system(size: 76, weight: .bold, design: .rounded))
                    .foregroundStyle(ClayTheme.text)
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)

                Text(content.style)
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundStyle(ClayTheme.secondaryText)
            }

            HStack(spacing: 16) {
                ShareCardMetric(text: content.ratingText)
                ShareCardMetric(text: content.caffeineText)
                ShareCardMetric(text: content.sugarText)
            }

            Text(content.note.isEmpty ? "No tasting note." : content.note)
                .font(.system(size: 32, weight: .regular, design: .rounded))
                .foregroundStyle(ClayTheme.secondaryText)
                .lineSpacing(8)
                .lineLimit(7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(64)
        .frame(width: 900, height: 1200, alignment: .topLeading)
        .background(
            ZStack {
                ClayTheme.background

                RoundedRectangle(cornerRadius: 64, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ClayTheme.raised, ClayTheme.surface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(42)
                    .modifier(ClayTheme.raisedShadow())
            }
        )
    }
}

private struct ShareCardMetric: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundStyle(ClayTheme.text)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Capsule(style: .continuous)
                    .fill(.white.opacity(0.78))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(ClayTheme.hairline, lineWidth: 1)
            )
    }
}

@MainActor
enum ShareCardRenderer {
    static func image(for record: DrinkRecord) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(record: record))
        renderer.scale = 2
        return renderer.uiImage
    }
}
