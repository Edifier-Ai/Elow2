import SwiftData
import SwiftUI

struct EditDrinkView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let record: DrinkRecord?
    @State private var form: DrinkFormState
    @State private var validationMessage: String?

    init(record: DrinkRecord?) {
        self.record = record
        _form = State(initialValue: DrinkFormState(record: record))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ClayCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(record == nil ? "New Drink" : "Edit Drink")
                                .font(.largeTitle.bold())
                                .foregroundStyle(ClayTheme.text)
                            Text("Capture the taste, cost, mood, and small details that make this cup useful later.")
                                .font(.subheadline)
                                .foregroundStyle(ClayTheme.secondaryText)
                        }
                    }

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
        }
    }

    private var validationBinding: Binding<Bool> {
        Binding(
            get: { validationMessage != nil },
            set: { if !$0 { validationMessage = nil } }
        )
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
}
