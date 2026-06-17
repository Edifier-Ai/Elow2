import SwiftData
import SwiftUI
import UIKit

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkRecord.recordedAt, order: .reverse) private var records: [DrinkRecord]

    @State private var currentMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
    @State private var selectedDate = Date.now
    @State private var editorSheet: RecordEditorSheet?
    @State private var pendingDeleteRecord: DrinkRecord?
    @State private var deleteErrorMessage: String?
    @State private var sharePayload: SharePayload?
    @State private var shareErrorMessage: String?

    private var visibleRecords: [DrinkRecord] {
        records.filter { $0.deletedAt == nil }
    }

    private var recordsByDay: [Date: [DrinkRecord]] {
        Dictionary(grouping: visibleRecords) { Calendar.current.startOfDay(for: $0.recordedAt) }
    }

    private var selectedDayRecords: [DrinkRecord] {
        recordsByDay[Calendar.current.startOfDay(for: selectedDate), default: []]
            .sorted { $0.recordedAt > $1.recordedAt }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        calendarSection
                        selectedDaySection
                    }
                    .padding(20)
                    .padding(.bottom, 92)
                }

                floatingAddButton
            }
            .background(ClayTheme.background.ignoresSafeArea())
            .sheet(item: $editorSheet) { sheet in
                switch sheet {
                case .new:
                    EditDrinkView(record: nil)
                case .edit(let record):
                    EditDrinkView(record: record)
                }
            }
            .sheet(item: $sharePayload) { payload in
                ActivityShareSheet(activityItems: [payload.image])
            }
            .confirmationDialog(
                "Delete record?",
                isPresented: isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    confirmDelete()
                }
                Button("Cancel", role: .cancel) {
                    pendingDeleteRecord = nil
                }
            } message: {
                Text(deleteConfirmationMessage)
            }
            .alert("Could not delete record", isPresented: deleteErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage ?? "")
            }
            .alert("Could not create share card", isPresented: shareErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(shareErrorMessage ?? "")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Coffee Diary")
                .font(.largeTitle.bold())
                .foregroundStyle(ClayTheme.text)
            Text("Every cup lives on the calendar as a photo memory.")
                .font(.subheadline)
                .foregroundStyle(ClayTheme.secondaryText)
        }
    }

    private var calendarSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: showPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Previous month")

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.title2.bold())
                        .foregroundStyle(ClayTheme.text)
                    Text("\(recordsInCurrentMonth.count) cups")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ClayTheme.secondaryText)
                }

                Spacer()

                Button(action: showNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next month")
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 9) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(ClayTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                }

                ForEach(monthCells.indices, id: \.self) { index in
                    if let date = monthCells[index] {
                        let dayRecords = recordsByDay[Calendar.current.startOfDay(for: date), default: []]
                        CalendarPhotoDayCell(
                            date: date,
                            records: dayRecords,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .aspectRatio(0.82, contentMode: .fit)
                    }
                }
            }
        }
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.title3.bold())
                    .foregroundStyle(ClayTheme.text)

                Spacer()

                Text(selectedDayRecords.isEmpty ? "No cup" : "\(selectedDayRecords.count) cup")
                    .font(.caption.bold())
                    .foregroundStyle(ClayTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(ClayTheme.surface, in: Capsule())
            }

            if let featuredRecord = selectedDayRecords.first {
                FeaturedCoffeeCard(
                    record: featuredRecord,
                    extraRecords: Array(selectedDayRecords.dropFirst()),
                    onEdit: { editorSheet = .edit(featuredRecord) },
                    onShare: { share(featuredRecord) },
                    onDelete: { pendingDeleteRecord = featuredRecord }
                )
            } else {
                EmptyCoffeeDayCard {
                    editorSheet = .new(UUID())
                }
            }
        }
    }

    private var floatingAddButton: some View {
        Button {
            editorSheet = .new(UUID())
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(ClayTheme.text, in: Circle())
                .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .padding(24)
        .accessibilityLabel("Add coffee")
    }

    private var recordsInCurrentMonth: [DrinkRecord] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth) else { return [] }
        return visibleRecords.filter { monthInterval.contains($0.recordedAt) }
    }

    private var monthCells: [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let dayRange = Calendar.current.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }

        let firstWeekday = Calendar.current.component(.weekday, from: monthInterval.start)
        let leadingEmptyCells = (firstWeekday - Calendar.current.firstWeekday + 7) % 7
        let days = dayRange.compactMap { day -> Date? in
            Calendar.current.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }

        return Array(repeating: nil, count: leadingEmptyCells) + days
    }

    private var weekdaySymbols: [String] {
        let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        let startIndex = Calendar.current.firstWeekday - 1
        return Array(symbols[startIndex...]) + Array(symbols[..<startIndex])
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding(
            get: { pendingDeleteRecord != nil },
            set: { if !$0 { pendingDeleteRecord = nil } }
        )
    }

    private var deleteErrorBinding: Binding<Bool> {
        Binding(
            get: { deleteErrorMessage != nil },
            set: { if !$0 { deleteErrorMessage = nil } }
        )
    }

    private var shareErrorBinding: Binding<Bool> {
        Binding(
            get: { shareErrorMessage != nil },
            set: { if !$0 { shareErrorMessage = nil } }
        )
    }

    private var deleteConfirmationMessage: String {
        if let pendingDeleteRecord {
            "Remove \(pendingDeleteRecord.name) from this diary day?"
        } else {
            "Remove this cup from the diary?"
        }
    }

    private func showPreviousMonth() {
        moveMonth(by: -1)
    }

    private func showNextMonth() {
        moveMonth(by: 1)
    }

    private func moveMonth(by value: Int) {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = nextMonth
        selectedDate = nextMonth
    }

    private func confirmDelete() {
        guard let record = pendingDeleteRecord else { return }
        pendingDeleteRecord = nil

        do {
            try delete(record)
        } catch {
            deleteErrorMessage = error.localizedDescription
        }
    }

    private func share(_ record: DrinkRecord) {
        guard let image = ShareCardRenderer.image(for: record) else {
            shareErrorMessage = "Try again after reopening this record."
            return
        }

        sharePayload = SharePayload(image: image)
    }

    private func delete(_ record: DrinkRecord) throws {
        let now = Date.now

        if record.remoteID == nil {
            modelContext.delete(record)
        } else {
            record.deletedAt = now
            record.syncState = .pendingUpload
            record.updatedAt = now
        }

        try modelContext.save()
    }
}

private struct CalendarPhotoDayCell: View {
    let date: Date
    let records: [DrinkRecord]
    let isSelected: Bool
    let isToday: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .topLeading) {
                if let record = records.first {
                    CoffeeRecordImage(record: record, size: .compact)
                } else {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(isToday ? ClayTheme.surface : Color(red: 0.98, green: 0.98, blue: 0.96))
                }

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(records.isEmpty ? ClayTheme.secondaryText : .white)
                    .padding(6)
                    .shadow(color: records.isEmpty ? .clear : .black.opacity(0.22), radius: 4, x: 0, y: 2)

                if records.count > 1 {
                    Text("+\(records.count - 1)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.42), in: Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(5)
                }
            }
            .aspectRatio(0.82, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(isSelected ? ClayTheme.text : (isToday ? ClayTheme.selected.opacity(0.35) : .clear), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.04 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .abbreviated, time: .omitted))
    }
}

private struct FeaturedCoffeeCard: View {
    let record: DrinkRecord
    let extraRecords: [DrinkRecord]
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomLeading) {
                CoffeeRecordImage(record: record, size: .large)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text(record.name)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text("\(record.style) · \(record.recordedAt.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.86))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0), .black.opacity(0.62)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.10), radius: 22, x: 0, y: 14)

            HStack(spacing: 10) {
                CoffeeActionButton(systemImage: "pencil", title: "Edit", action: onEdit)
                CoffeeActionButton(systemImage: "square.and.arrow.up", title: "Share", action: onShare)
                CoffeeActionButton(systemImage: "trash", title: "Delete", role: .destructive, action: onDelete)
            }

            if !extraRecords.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(extraRecords) { record in
                            CoffeeRecordImage(record: record, size: .compact)
                                .frame(width: 72, height: 88)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(alignment: .bottomLeading) {
                                    Text(record.recordedAt.formatted(date: .omitted, time: .shortened))
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                        .padding(6)
                                }
                        }
                    }
                }
            }
        }
    }
}

private struct EmptyCoffeeDayCard: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(ClayTheme.text)
                Text("Add a coffee photo")
                    .font(.headline)
                    .foregroundStyle(ClayTheme.text)
                Text("This day is ready for one picture and a few tasting notes.")
                    .font(.caption)
                    .foregroundStyle(ClayTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 190)
            .background(ClayTheme.surface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(ClayTheme.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct CoffeeRecordImage: View {
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

private struct CoffeeActionButton: View {
    let systemImage: String
    let title: String
    var role: ButtonRole?
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption.bold())
                .foregroundStyle(role == .destructive ? .red.opacity(0.82) : ClayTheme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(ClayTheme.surface, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct SharePayload: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private enum RecordEditorSheet: Identifiable {
    case new(UUID)
    case edit(DrinkRecord)

    var id: String {
        switch self {
        case .new(let id):
            "new-\(id.uuidString)"
        case .edit(let record):
            "edit-\(record.id.uuidString)"
        }
    }
}
