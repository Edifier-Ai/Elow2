import SwiftData
import SwiftUI

struct TodayView: View {
    @Query(sort: \DrinkRecord.recordedAt, order: .reverse) private var records: [DrinkRecord]
    @State private var showingEditor = false
    @State private var currentMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
    @State private var selectedDate = Date.now

    private var visibleRecords: [DrinkRecord] {
        records.filter { $0.deletedAt == nil }
    }

    private var recordsByDay: [Date: [DrinkRecord]] {
        Dictionary(grouping: visibleRecords) { Calendar.current.startOfDay(for: $0.recordedAt) }
    }

    private var selectedRecords: [DrinkRecord] {
        recordsByDay[Calendar.current.startOfDay(for: selectedDate), default: []]
            .sorted { $0.recordedAt > $1.recordedAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    calendarHero
                    greetingBlock
                    todayNotebook
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 112)
            }
            .background(ClayTheme.background.ignoresSafeArea())
            .sheet(isPresented: $showingEditor) {
                EditDrinkView(record: nil)
            }
        }
    }

    private var calendarHero: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(Calendar.current.component(.day, from: selectedDate))")
                        .font(.system(size: 92, weight: .bold, design: .rounded))
                        .foregroundStyle(ClayTheme.accentSage)
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)

                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ClayTheme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 10) {
                    Text(currentMonth.formatted(.dateTime.month(.narrow).year()))
                        .font(.title3.bold())
                        .foregroundStyle(ClayTheme.text)

                    HStack(spacing: 10) {
                        monthButton("chevron.left", action: { moveMonth(by: -1) })
                        monthButton("chevron.right", action: { moveMonth(by: 1) })
                    }
                }
                .padding(.top, 22)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    Text(weekdaySymbols[index].uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(ClayTheme.secondaryText.opacity(0.72))
                        .frame(maxWidth: .infinity)
                }

                ForEach(monthCells.indices, id: \.self) { index in
                    if let date = monthCells[index] {
                        let dayRecords = recordsByDay[Calendar.current.startOfDay(for: date), default: []]
                        TodayCalendarDot(
                            date: date,
                            records: dayRecords,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear.frame(height: 34)
                    }
                }
            }
        }
    }

    private var greetingBlock: some View {
        VStack(spacing: 14) {
            Text(greeting)
                .font(.title2.bold())
                .foregroundStyle(ClayTheme.text)
            Text(selectedRecords.isEmpty ? "把今天这一杯拍下来，留住香气和心情。" : selectedRecords.first?.note.nonEmptyValue ?? "这一杯已经记在今天。")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(ClayTheme.secondaryText)

            Button {
                showingEditor = true
            } label: {
                ZStack {
                    Circle()
                        .fill(ClayTheme.surface)
                        .frame(width: 74, height: 74)
                        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
                    Circle()
                        .stroke(.white, lineWidth: 10)
                        .frame(width: 58, height: 58)
                    Image(systemName: selectedRecords.isEmpty ? "camera.fill" : "leaf.fill")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(ClayTheme.accentSage)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add coffee record")
        }
        .frame(maxWidth: .infinity)
    }

    private var todayNotebook: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("# 今日风味")
                .font(.subheadline.bold())
                .foregroundStyle(ClayTheme.secondaryText)

            if selectedRecords.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(ClayTheme.accentSage)
                    Text("今天还没有咖啡贴纸。")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ClayTheme.text)
                    Spacer()
                }
                .padding(18)
                .background(ClayTheme.paper, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            } else {
                ForEach(selectedRecords.prefix(2)) { record in
                    TodayCoffeeNote(record: record)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date.now)
        return switch hour {
        case 5..<12: "早上好"
        case 12..<18: "下午好"
        default: "晚上好"
        }
    }

    private var monthCells: [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let dayRange = Calendar.current.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }

        let firstWeekday = Calendar.current.component(.weekday, from: monthInterval.start)
        let leadingEmptyCells = (firstWeekday - Calendar.current.firstWeekday + 7) % 7
        let days = dayRange.compactMap { day in
            Calendar.current.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }
        return Array(repeating: nil, count: leadingEmptyCells) + days
    }

    private var weekdaySymbols: [String] {
        let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        let startIndex = Calendar.current.firstWeekday - 1
        return Array(symbols[startIndex...]) + Array(symbols[..<startIndex])
    }

    private func monthButton(_ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.caption.bold())
                .foregroundStyle(ClayTheme.secondaryText)
                .frame(width: 28, height: 28)
                .background(ClayTheme.surface, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func moveMonth(by value: Int) {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = nextMonth
        selectedDate = nextMonth
    }
}

private struct TodayCalendarDot: View {
    let date: Date
    let records: [DrinkRecord]
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let record = records.first {
                    DrinkRecordPhoto(record: record, size: .compact)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .rotationEffect(.degrees(isSelected ? -4 : 4))
                        .shadow(color: .black.opacity(0.10), radius: 5, x: 0, y: 3)
                } else {
                    Circle()
                        .fill(ClayTheme.surface)
                        .frame(width: 28, height: 28)
                }

                if records.isEmpty {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(ClayTheme.secondaryText)
                }
            }
            .frame(height: 34)
            .overlay {
                if isSelected {
                    Circle()
                        .stroke(ClayTheme.accentSage, lineWidth: 2)
                        .frame(width: 34, height: 34)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct TodayCoffeeNote: View {
    let record: DrinkRecord

    var body: some View {
        HStack(spacing: 14) {
            DrinkRecordPhoto(record: record, size: .compact)
                .frame(width: 58, height: 66)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(record.name)
                    .font(.headline)
                    .foregroundStyle(ClayTheme.text)
                Text(record.style)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(ClayTheme.secondaryText)
                Text(record.recordedAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2.bold())
                    .foregroundStyle(ClayTheme.accentSage)
            }

            Spacer()

            Text("\(record.rating)")
                .font(.headline.bold())
                .foregroundStyle(ClayTheme.accentSage)
                .frame(width: 38, height: 38)
                .background(Circle().stroke(ClayTheme.hairline, lineWidth: 1))
        }
        .padding(14)
        .background(ClayTheme.paper, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private extension String {
    var nonEmptyValue: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
