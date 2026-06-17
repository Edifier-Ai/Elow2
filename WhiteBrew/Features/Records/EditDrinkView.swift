import SwiftData
import SwiftUI
import PhotosUI
import UIKit

struct EditDrinkView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let record: DrinkRecord?
    @State private var form: DrinkFormState
    @State private var validationMessage: String?
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(record: DrinkRecord?) {
        self.record = record
        _form = State(initialValue: DrinkFormState(record: record))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    photoHeader

                    claySection("Drink") {
                        Picker("Category", selection: $form.category) {
                            ForEach(DrinkCategory.allCases) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)

                        labeledField("Name", text: $form.name, prompt: "Morning Latte")
                        labeledField("Style", text: $form.style, prompt: "Latte, Americano, Oolong")

                        DatePicker("Date and time", selection: $form.recordedAt)
                            .foregroundStyle(ClayTheme.text)
                    }

                    claySection("Details") {
                        HStack(spacing: 12) {
                            labeledField("Price", text: $form.priceText, prompt: "0")
                                .keyboardType(.decimalPad)
                            labeledField("Caffeine", text: $form.caffeineText, prompt: "mg")
                                .keyboardType(.numberPad)
                        }

                        Stepper("Rating \(form.rating)/5", value: $form.rating, in: 1...5)
                            .foregroundStyle(ClayTheme.text)

                        Picker("Sugar", selection: $form.sugarLevel) {
                            ForEach(SugarLevel.allCases) { level in
                                Text(level.displayName).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("Temperature", selection: $form.temperature) {
                            ForEach(DrinkTemperature.allCases) { temperature in
                                Text(temperature.displayName).tag(temperature)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    claySection("Context") {
                        HStack(spacing: 12) {
                            labeledField("Bean/base", text: $form.beanOrBase, prompt: "Ethiopia, Oolong")
                            labeledField("Size", text: $form.sizeText, prompt: "ml")
                                .keyboardType(.numberPad)
                        }
                        labeledField("Mood", text: $form.mood, prompt: "Focused")
                        labeledField("Tags", text: $form.tagsText, prompt: "milk, morning")
                        labeledField("Note", text: $form.note, prompt: "Soft and balanced")
                    }

                    claySection("Sticker") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                            stickerTile(nil, title: "None")
                            ForEach(PreviewData.stickers) { sticker in
                                stickerTile(sticker.id, title: sticker.name)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(ClayTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                }
            }
            .alert("Check the drink", isPresented: validationBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage ?? "")
            }
            .task(id: selectedPhotoItem) {
                await loadSelectedPhoto()
            }
        }
    }

    private var validationBinding: Binding<Bool> {
        Binding(
            get: { validationMessage != nil },
            set: { if !$0 { validationMessage = nil } }
        )
    }

    private var photoHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(record == nil ? "New cup" : "Edit cup")
                .font(.largeTitle.bold())
                .foregroundStyle(ClayTheme.text)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack(alignment: .bottomLeading) {
                    if let image = form.photoImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        DrinkPhotoPlaceholder(recordName: form.name, style: form.style, size: .large)
                    }

                    Label(form.photoData == nil ? "Add photo" : "Change photo", systemImage: "camera.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.45), in: Capsule())
                        .padding(14)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.85), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
        }
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

    private func labeledField(_ title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(ClayTheme.secondaryText)
            TextField(prompt, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func stickerTile(_ stickerID: String?, title: String) -> some View {
        Button {
            form.stickerID = stickerID
        } label: {
            VStack(spacing: 8) {
                Image(systemName: stickerID == nil ? "circle.slash" : "seal.fill")
                    .font(.title2)
                    .foregroundStyle(ClayTheme.text)
                Text(title)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ClayTheme.text)
            }
            .frame(maxWidth: .infinity, minHeight: 78)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(form.stickerID == stickerID ? ClayTheme.selected.opacity(0.12) : .white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(form.stickerID == stickerID ? ClayTheme.selected : ClayTheme.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func save() {
        do {
            try form.save(record: record, in: modelContext)
            try modelContext.save()
            dismiss()
        } catch {
            validationMessage = error.localizedDescription
        }
    }

    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else { return }

        do {
            guard let data = try await selectedPhotoItem.loadTransferable(type: Data.self) else { return }
            await MainActor.run {
                form.photoData = data
            }
        } catch {
            await MainActor.run {
                validationMessage = "Could not load that photo."
            }
        }
    }
}

extension DrinkFormState {
    var photoImage: UIImage? {
        guard let photoData else { return nil }
        return UIImage(data: photoData)
    }
}
