import SwiftData
import SwiftUI

struct StatsView: View {
    @Query(sort: \DrinkRecord.recordedAt, order: .reverse) private var records: [DrinkRecord]
    @State private var period: StatsPeriod = .week

    private var filteredRecords: [DrinkRecord] {
        let start = period.startDate(from: .now, calendar: .current)
        return records.filter { record in
            record.deletedAt == nil && record.recordedAt >= start
        }
    }

    private var summary: StatsSummary {
        StatsEngine.summary(for: filteredRecords)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    Picker("Period", selection: $period) {
                        ForEach(StatsPeriod.allCases) { period in
                            Text(period.title).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)

                    metrics
                    chart
                    breakdown
                }
                .padding(20)
            }
            .background(ClayTheme.background.ignoresSafeArea())
        }
    }

    private var header: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Stats")
                    .font(.largeTitle.bold())
                    .foregroundStyle(ClayTheme.text)
                Text("Local insights from your saved records.")
                    .font(.subheadline)
                    .foregroundStyle(ClayTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ClayMetricTile(label: "Cups", value: "\(summary.totalCups)")
            ClayMetricTile(label: "Spend", value: "RMB \(summary.totalSpend.plainString)")
            ClayMetricTile(label: "Caffeine", value: "\(summary.totalCaffeineMG) mg")
            ClayMetricTile(label: "Preferred", value: summary.preferredStyle)
        }
    }

    private var chart: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cups by day")
                    .font(.headline)
                    .foregroundStyle(ClayTheme.text)

                if chartEntries.isEmpty {
                    Text("No cups in this period yet.")
                        .font(.subheadline)
                        .foregroundStyle(ClayTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 24)
                } else {
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(chartEntries) { entry in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [ClayTheme.selected, ClayTheme.secondaryText],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: max(12, CGFloat(entry.count) / CGFloat(maxChartCount) * 132))
                                    .frame(maxWidth: .infinity)
                                Text(entry.label)
                                    .font(.caption2)
                                    .foregroundStyle(ClayTheme.secondaryText)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(height: 170)
                }
            }
        }
    }

    private var breakdown: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Pattern")
                    .font(.headline)
                    .foregroundStyle(ClayTheme.text)

                VStack(spacing: 10) {
                    statLine("Coffee / Milk tea", "\(summary.coffeeCount) / \(summary.milkTeaCount)")
                    statLine("Most common time", summary.mostCommonTimeWindow)
                    statLine("Active days", "\(summary.activeDays)")
                    statLine("Average price", "RMB \(summary.averagePrice.plainString)")
                }
            }
        }
    }

    private var chartEntries: [StatsChartEntry] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredRecords) { calendar.startOfDay(for: $0.recordedAt) }
        return grouped
            .map { date, records in
                StatsChartEntry(date: date, label: date.formatted(.dateTime.month(.abbreviated).day()), count: records.count)
            }
            .sorted { $0.date < $1.date }
            .suffix(8)
            .map { $0 }
    }

    private var maxChartCount: Int {
        chartEntries.map(\.count).max() ?? 1
    }

    private func statLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(ClayTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(ClayTheme.text)
        }
        .accessibilityElement(children: .combine)
    }
}

private enum StatsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week:
            "Week"
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }

    func startDate(from date: Date, calendar: Calendar) -> Date {
        switch self {
        case .week:
            calendar.date(byAdding: .day, value: -7, to: date) ?? date
        case .month:
            calendar.date(byAdding: .month, value: -1, to: date) ?? date
        case .year:
            calendar.date(byAdding: .year, value: -1, to: date) ?? date
        }
    }
}

private struct StatsChartEntry: Identifiable {
    let date: Date
    let label: String
    let count: Int

    var id: Date { date }
}
