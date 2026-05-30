import SwiftData
import SwiftUI
import UIKit

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkRecord.recordedAt, order: .reverse) private var records: [DrinkRecord]

    @State private var searchText = ""
    @State private var editorSheet: RecordEditorSheet?
    @State private var pendingDeleteRecord: DrinkRecord?
    @State private var deleteErrorMessage: String?
    @State private var sharePayload: SharePayload?
    @State private var shareErrorMessage: String?

    private var visibleRecords: [DrinkRecord] {
        records
            .filter { $0.deletedAt == nil }
            .filter(matchesSearch)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    searchField
                    timeline
                }
                .padding(20)
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
        ClayCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Record")
                        .font(.largeTitle.bold())
                        .foregroundStyle(ClayTheme.text)
                    Text("A searchable timeline for every local cup.")
                        .font(.subheadline)
                        .foregroundStyle(ClayTheme.secondaryText)
                }

                Spacer()

                ClayButton("Add", systemImage: "plus") {
                    editorSheet = .new(UUID())
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ClayTheme.secondaryText)
            TextField("Search name, style, or tags", text: $searchText)
                .textInputAutocapitalization(.never)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: ClayTheme.controlRadius, style: .continuous)
                .fill(ClayTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ClayTheme.controlRadius, style: .continuous)
                .stroke(ClayTheme.hairline, lineWidth: 1)
        )
    }

    private var timeline: some View {
        VStack(spacing: 12) {
            if visibleRecords.isEmpty {
                ClayCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(searchText.isEmpty ? "No records yet" : "No matching records")
                            .font(.headline)
                            .foregroundStyle(ClayTheme.text)
                        Text(searchText.isEmpty ? "Add a cup to start the local timeline." : "Try a drink name, style, or tag.")
                            .font(.subheadline)
                            .foregroundStyle(ClayTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(visibleRecords) { record in
                    RecordTimelineRow(record: record) {
                        editorSheet = .edit(record)
                    } onShare: {
                        share(record)
                    } onDelete: {
                        pendingDeleteRecord = record
                    }
                }
            }
        }
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
            "Remove \(pendingDeleteRecord.name) from the visible timeline?"
        } else {
            "Remove this record from the visible timeline?"
        }
    }

    private func matchesSearch(_ record: DrinkRecord) -> Bool {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !term.isEmpty else { return true }

        return record.name.lowercased().contains(term)
            || record.style.lowercased().contains(term)
            || record.tags.contains { $0.lowercased().contains(term) }
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

private struct RecordTimelineRow: View {
    let record: DrinkRecord
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ClayCard {
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    HStack(spacing: 12) {
                        Image(systemName: record.category == .coffee ? "cup.and.saucer.fill" : "takeoutbag.and.cup.and.straw.fill")
                            .font(.title3)
                            .foregroundStyle(ClayTheme.text)
                            .frame(width: 42, height: 42)
                            .background(Circle().fill(.white.opacity(0.78)))

                        VStack(alignment: .leading, spacing: 5) {
                            Text(record.name)
                                .font(.headline)
                                .foregroundStyle(ClayTheme.text)
                            Text(record.style)
                                .font(.subheadline)
                                .foregroundStyle(ClayTheme.secondaryText)
                            Text(record.recordedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(ClayTheme.secondaryText)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("RMB \(record.price.plainString)")
                                .font(.subheadline.bold())
                                .foregroundStyle(ClayTheme.text)
                            Text("Rating \(record.rating)")
                                .font(.caption.bold())
                                .foregroundStyle(ClayTheme.secondaryText)
                        }
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 4) {
                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(ClayTheme.text.opacity(0.78))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Share \(record.name)")

                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .font(.headline)
                            .foregroundStyle(.red.opacity(0.75))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Delete \(record.name)")
                }
            }
        }
    }
}
