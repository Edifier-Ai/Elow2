import SwiftData
import SwiftUI

struct StatsView: View {
    @Query(sort: \DrinkRecord.recordedAt, order: .reverse) private var records: [DrinkRecord]
    @State private var period: StatsPeriod = .week

    private var filteredRecords: [DrinkRecord] {
        StatsPeriodFilter.records(in: period, from: records, now: .now, calendar: .current)
    }

    private var summary: StatsSummary {
        StatsEngine.summary(for: filteredRecords)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    photoBubbles
                    titleBlock
                    periodControls
                    weeklySummary
                    brandDistribution
                    flavorPattern
                    intakeOverview
                }
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .padding(.bottom, 112)
            }
            .background(ClayTheme.background.ignoresSafeArea())
        }
    }

    private var photoBubbles: some View {
        HStack(spacing: -10) {
            ForEach(filteredRecords.prefix(3)) { record in
                DrinkRecordPhoto(record: record, size: .compact)
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 5))
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            }

            if filteredRecords.isEmpty {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(ClayTheme.surface)
                        .frame(width: 58, height: 58)
                        .overlay(
                            Image(systemName: index == 0 ? "cup.and.saucer.fill" : "camera.fill")
                                .foregroundStyle(ClayTheme.accentSage.opacity(0.72))
                        )
                        .overlay(Circle().stroke(.white, lineWidth: 5))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("饮品趋势")
                .font(.largeTitle.bold())
                .foregroundStyle(ClayTheme.text)
            Text("按周查看饮用趋势、花费和评分。")
                .font(.subheadline)
                .foregroundStyle(ClayTheme.secondaryText)
        }
    }

    private var periodControls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(StatsPeriod.allCases) { option in
                    Button {
                        period = option
                    } label: {
                        Text(option.localizedTitle)
                            .font(.subheadline.bold())
                            .foregroundStyle(period == option ? ClayTheme.accentSage : ClayTheme.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(period == option ? ClayTheme.surface : .white)
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(ClayTheme.hairline.opacity(0.8), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 10) {
                FilterPill(title: "全部", isActive: true)
                FilterPill(title: "咖啡", isActive: false)
                FilterPill(title: "奶茶", isActive: false)
            }
        }
    }

    private var weeklySummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("总览")
                .font(.caption.weight(.medium))
                .foregroundStyle(ClayTheme.secondaryText)

            Text("周内总览")
                .font(.title2.bold())
                .foregroundStyle(ClayTheme.text)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SoftMetric(label: "总杯数", value: "\(summary.totalCups)")
                SoftMetric(label: "活跃天数", value: "\(summary.activeDays)")
                SoftMetric(label: "总花费", value: "¥\(summary.totalSpend.plainString)")
                SoftMetric(label: "平均评分", value: averageRatingText)
            }
        }
        .softCard()
    }

    private var brandDistribution: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("品牌分布")
                .font(.caption.weight(.medium))
                .foregroundStyle(ClayTheme.secondaryText)
            Text("看看最近更常喝哪些品牌。")
                .font(.caption)
                .foregroundStyle(ClayTheme.secondaryText)

            HStack(spacing: 22) {
                ZStack {
                    Circle()
                        .stroke(ClayTheme.surface, lineWidth: 24)
                        .frame(width: 138, height: 138)
                    Circle()
                        .trim(from: 0, to: coffeeRatio)
                        .stroke(ClayTheme.accentSage, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                        .frame(width: 138, height: 138)
                        .rotationEffect(.degrees(-90))
                    Text("\(summary.totalCups)")
                        .font(.title.bold())
                        .foregroundStyle(ClayTheme.text)
                }

                VStack(alignment: .leading, spacing: 8) {
                    LegendDot(title: "咖啡", value: "\(summary.coffeeCount) 杯", color: ClayTheme.accentSage)
                    LegendDot(title: "奶茶", value: "\(summary.milkTeaCount) 杯", color: ClayTheme.accentCoffee.opacity(0.62))
                }

                Spacer()
            }
        }
        .softCard()
    }

    private var flavorPattern: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("常喝风味")
                .font(.title3.bold())
                .foregroundStyle(ClayTheme.text)
            Text("看看最常选择的咖啡风格。")
                .font(.caption)
                .foregroundStyle(ClayTheme.secondaryText)

            StatProgressRow(index: 1, title: summary.preferredStyle, value: summary.totalCups, maxValue: max(summary.totalCups, 1), color: ClayTheme.accentCoffee.opacity(0.68))
        }
        .softCard()
    }

    private var intakeOverview: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("摄入概览")
                .font(.title3.bold())
                .foregroundStyle(ClayTheme.text)
            Text("看咖啡因和花费的平均值。")
                .font(.caption)
                .foregroundStyle(ClayTheme.secondaryText)

            HStack(spacing: 12) {
                SoftMetric(label: "平均咖啡因", value: averageCaffeineText)
                SoftMetric(label: "平均花费", value: "¥\(summary.averagePrice.plainString)")
            }
        }
        .softCard()
    }

    private var coffeeRatio: CGFloat {
        guard summary.totalCups > 0 else { return 0.02 }
        return max(0.08, CGFloat(summary.coffeeCount) / CGFloat(summary.totalCups))
    }

    private var averageCaffeineText: String {
        guard summary.totalCups > 0 else { return "0mg" }
        return "\(summary.totalCaffeineMG / summary.totalCups)mg"
    }

    private var averageRatingText: String {
        guard !filteredRecords.isEmpty else { return "0" }
        let total = filteredRecords.reduce(0) { $0 + $1.rating }
        return (Double(total) / Double(filteredRecords.count)).formatted(.number.precision(.fractionLength(1)))
    }
}

private struct FilterPill: View {
    let title: String
    let isActive: Bool

    var body: some View {
        Text(title)
            .font(.caption.bold())
            .foregroundStyle(isActive ? ClayTheme.accentSage : ClayTheme.text)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(isActive ? ClayTheme.surface : .white, in: Capsule(style: .continuous))
            .overlay(Capsule(style: .continuous).stroke(ClayTheme.hairline, lineWidth: 1))
    }
}

private struct SoftMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(ClayTheme.accentSage)
            Text(label)
                .font(.caption2)
                .foregroundStyle(ClayTheme.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct LegendDot: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(ClayTheme.text)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(ClayTheme.secondaryText)
            }
        }
    }
}

private struct StatProgressRow: View {
    let index: Int
    let title: String
    let value: Int
    let maxValue: Int
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index)")
                .font(.caption.bold())
                .foregroundStyle(ClayTheme.secondaryText)
                .frame(width: 28, height: 28)
                .background(ClayTheme.surface, in: Circle())

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title == "None" ? "暂无" : title)
                        .font(.subheadline.bold())
                        .foregroundStyle(ClayTheme.text)
                    Spacer()
                    Text("\(value) 杯")
                        .font(.caption.bold())
                        .foregroundStyle(ClayTheme.secondaryText)
                }

                GeometryReader { proxy in
                    Capsule(style: .continuous)
                        .fill(ClayTheme.surface)
                        .overlay(alignment: .leading) {
                            Capsule(style: .continuous)
                                .fill(color)
                                .frame(width: max(12, proxy.size.width * CGFloat(value) / CGFloat(maxValue)))
                        }
                }
                .frame(height: 8)
            }
        }
    }
}

private extension View {
    func softCard() -> some View {
        padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ClayTheme.paper, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(.white.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)
    }
}

private extension StatsPeriod {
    var localizedTitle: String {
        switch self {
        case .week: "本周"
        case .month: "本月"
        case .year: "本年"
        }
    }
}
