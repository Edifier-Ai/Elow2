import SwiftData
import SwiftUI

struct TodayView: View {
    @Query(sort: \DrinkRecord.recordedAt, order: .reverse) private var records: [DrinkRecord]
    @State private var showingEditor = false

    private var visibleRecords: [DrinkRecord] {
        records.filter { $0.deletedAt == nil }
    }

    private var todayRecords: [DrinkRecord] {
        let calendar = Calendar.current
        return visibleRecords.filter { calendar.isDateInToday($0.recordedAt) }
    }

    private var summary: StatsSummary {
        StatsEngine.summary(for: todayRecords)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    metrics
                    recentRecords
                }
                .padding(20)
            }
            .background(ClayTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditor) {
                EditDrinkView(record: nil)
            }
        }
    }

    private var header: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today")
                            .font(.largeTitle.bold())
                            .foregroundStyle(ClayTheme.text)
                        Text("Track each cup while the details are still fresh.")
                            .font(.subheadline)
                            .foregroundStyle(ClayTheme.secondaryText)
                    }

                    Spacer()

                    ClayButton("Add", systemImage: "plus") {
                        showingEditor = true
                    }
                }
            }
        }
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ClayMetricTile(label: "Cups", value: "\(summary.totalCups)")
            ClayMetricTile(label: "Caffeine", value: "\(summary.totalCaffeineMG) mg")
            ClayMetricTile(label: "Spend", value: "RMB \(summary.totalSpend.plainString)")
            ClayMetricTile(label: "Preferred", value: summary.preferredStyle)
        }
    }

    private var recentRecords: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Recent Records")
                        .font(.headline)
                        .foregroundStyle(ClayTheme.text)
                    Spacer()
                    Text("\(visibleRecords.count)")
                        .font(.caption.bold())
                        .foregroundStyle(ClayTheme.secondaryText)
                }

                if visibleRecords.isEmpty {
                    emptyState("No drinks yet", subtitle: "Add your first coffee or milk tea record.")
                } else {
                    ForEach(visibleRecords.prefix(5)) { record in
                        TodayRecordRow(record: record)
                        if record.id != visibleRecords.prefix(5).last?.id {
                            Divider().overlay(ClayTheme.hairline)
                        }
                    }
                }
            }
        }
    }

    private func emptyState(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(ClayTheme.text)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(ClayTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }
}

private struct TodayRecordRow: View {
    let record: DrinkRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.category == .coffee ? "cup.and.saucer.fill" : "takeoutbag.and.cup.and.straw.fill")
                .foregroundStyle(ClayTheme.text)
                .frame(width: 32, height: 32)
                .background(Circle().fill(.white.opacity(0.75)))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(ClayTheme.text)
                Text("\(record.style), \(record.recordedAt.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(ClayTheme.secondaryText)
            }

            Spacer()

            Text("Rating \(record.rating)")
                .font(.caption.bold())
                .foregroundStyle(ClayTheme.text)
        }
        .accessibilityElement(children: .combine)
    }
}
