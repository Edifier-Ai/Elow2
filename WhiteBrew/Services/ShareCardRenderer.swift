import SwiftUI
import UIKit

struct ShareCardContent: Equatable {
    let name: String
    let style: String
    let ratingText: String
    let caffeineText: String
    let sugarText: String
    let priceText: String
    let note: String
    let brand: String

    init(record: DrinkRecord) {
        name = record.name
        style = record.style
        ratingText = "\(record.rating)/5"
        caffeineText = "\(record.caffeineMG ?? 0) mg"
        sugarText = record.sugarLevel.displayName
        priceText = "¥\(record.price.plainString)"
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
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text(Date.now.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(ClayTheme.accentSage)
                Spacer()
                Text(content.brand)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(ClayTheme.secondaryText)
            }

            DrinkRecordPhoto(record: record, size: .large)
                .frame(width: 360, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 54, style: .continuous))
                .frame(maxWidth: .infinity)
                .padding(.top, 18)

            VStack(alignment: .leading, spacing: 18) {
                Text("“ \(content.note.isEmpty ? "一杯日常" : content.note) ”")
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundStyle(ClayTheme.text)
                    .lineLimit(3)
                    .minimumScaleFactor(0.68)

                HStack(spacing: 16) {
                    ShareCardMetric(text: content.style)
                    ShareCardMetric(text: content.sugarText)
                    ShareCardMetric(text: content.caffeineText)
                }
            }

            Spacer()

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(content.priceText)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(ClayTheme.accentSage)
                    Text(content.name)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(ClayTheme.secondaryText)
                }

                Spacer()

                Text("\(record.rating)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(ClayTheme.accentSage)
                    .frame(width: 96, height: 96)
                    .background(Circle().stroke(ClayTheme.hairline, lineWidth: 4))
            }
        }
        .padding(72)
        .frame(width: 900, height: 1200, alignment: .topLeading)
        .background(
            ZStack {
                ClayTheme.background

                RoundedRectangle(cornerRadius: 64, style: .continuous)
                    .fill(ClayTheme.paper)
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
            .font(.system(size: 26, weight: .bold, design: .rounded))
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
