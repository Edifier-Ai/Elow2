import Foundation
import SwiftData

enum DrinkFormValidationError: LocalizedError, Equatable {
    case missingName
    case missingStyle
    case invalidPrice
    case invalidCaffeine
    case invalidSize

    var errorDescription: String? {
        switch self {
        case .missingName:
            "Add a drink name before saving."
        case .missingStyle:
            "Add a style before saving."
        case .invalidPrice:
            "Enter a valid price or leave it empty."
        case .invalidCaffeine:
            "Enter caffeine as a whole number or leave it empty."
        case .invalidSize:
            "Enter size as a whole number or leave it empty."
        }
    }
}

struct DrinkFormState {
    var category: DrinkCategory
    var name: String
    var style: String
    var recordedAt: Date
    var priceText: String
    var rating: Int
    var caffeineText: String
    var sugarLevel: SugarLevel
    var beanOrBase: String
    var temperature: DrinkTemperature
    var sizeText: String
    var mood: String
    var tagsText: String
    var note: String
    var stickerID: String?
    var photoData: Data?

    init(now: Date = .now) {
        category = .coffee
        name = ""
        style = ""
        recordedAt = now
        priceText = ""
        rating = 4
        caffeineText = ""
        sugarLevel = .regular
        beanOrBase = ""
        temperature = .hot
        sizeText = ""
        mood = ""
        tagsText = ""
        note = ""
        stickerID = nil
        photoData = nil
    }

    init(record: DrinkRecord?) {
        self.init()

        guard let record else { return }

        category = record.category
        name = record.name
        style = record.style
        recordedAt = record.recordedAt
        priceText = record.price.plainString
        rating = record.rating
        caffeineText = record.caffeineMG.map(String.init) ?? ""
        sugarLevel = record.sugarLevel
        beanOrBase = record.beanOrBase ?? ""
        temperature = record.temperature
        sizeText = record.sizeML.map(String.init) ?? ""
        mood = record.mood ?? ""
        tagsText = record.tags.joined(separator: ", ")
        note = record.note
        stickerID = record.stickerID
        photoData = record.photoData
    }

    @discardableResult
    func save(record: DrinkRecord?, in context: ModelContext, now: Date = .now) throws -> DrinkRecord {
        let cleanedName = name.cleanedRequiredValue
        let cleanedStyle = style.cleanedRequiredValue

        guard !cleanedName.isEmpty else { throw DrinkFormValidationError.missingName }
        guard !cleanedStyle.isEmpty else { throw DrinkFormValidationError.missingStyle }

        let parsedPrice = try parsedPrice()
        let parsedCaffeine = try parsedOptionalInt(from: caffeineText, error: .invalidCaffeine)
        let parsedSize = try parsedOptionalInt(from: sizeText, error: .invalidSize)

        let target = record ?? DrinkRecord(
            category: category,
            name: cleanedName,
            style: cleanedStyle,
            recordedAt: recordedAt,
            price: parsedPrice,
            rating: rating,
            caffeineMG: parsedCaffeine,
            sugarLevel: sugarLevel,
            beanOrBase: beanOrBase.cleanedOptionalValue,
            temperature: temperature,
            sizeML: parsedSize,
            mood: mood.cleanedOptionalValue,
            tags: parsedTags,
            note: note.cleanedRequiredValue,
            stickerID: stickerID,
            photoData: photoData,
            createdAt: now,
            updatedAt: now,
            syncState: .pendingUpload
        )

        if record == nil {
            context.insert(target)
        }

        target.category = category
        target.name = cleanedName
        target.style = cleanedStyle
        target.recordedAt = recordedAt
        target.price = parsedPrice
        target.rating = rating
        target.caffeineMG = parsedCaffeine
        target.sugarLevel = sugarLevel
        target.beanOrBase = beanOrBase.cleanedOptionalValue
        target.temperature = temperature
        target.sizeML = parsedSize
        target.mood = mood.cleanedOptionalValue
        target.tags = parsedTags
        target.note = note.cleanedRequiredValue
        target.stickerID = stickerID
        target.photoData = photoData
        target.updatedAt = now
        target.deletedAt = nil
        target.syncState = .pendingUpload

        return target
    }

    private var parsedTags: [String] {
        var seen = Set<String>()
        return tagsText
            .split(separator: ",")
            .map { String($0).cleanedRequiredValue }
            .filter { !$0.isEmpty }
            .filter { seen.insert($0.lowercased()).inserted }
    }

    private func parsedPrice() throws -> Decimal {
        let cleaned = priceText.cleanedRequiredValue
        guard !cleaned.isEmpty else { return 0 }

        let normalized = cleaned.replacingOccurrences(of: ",", with: ".")
        let pricePattern = #"^[0-9]+(\.[0-9]+)?$"#

        guard normalized.range(of: pricePattern, options: .regularExpression) != nil,
              let price = Decimal(string: normalized) else {
            throw DrinkFormValidationError.invalidPrice
        }

        return price
    }

    private func parsedOptionalInt(from text: String, error: DrinkFormValidationError) throws -> Int? {
        let cleaned = text.cleanedRequiredValue
        guard !cleaned.isEmpty else { return nil }

        guard let value = Int(cleaned) else {
            throw error
        }

        return value
    }
}

extension DrinkCategory {
    var displayName: String {
        switch self {
        case .coffee:
            "Coffee"
        case .milkTea:
            "Milk tea"
        }
    }
}

extension SugarLevel {
    var displayName: String {
        switch self {
        case .none:
            "No sugar"
        case .low:
            "Low"
        case .half:
            "Half"
        case .regular:
            "Regular"
        }
    }
}

extension DrinkTemperature {
    var displayName: String {
        switch self {
        case .hot:
            "Hot"
        case .iced:
            "Iced"
        case .room:
            "Room"
        }
    }
}

extension StickerRarity {
    var displayName: String {
        switch self {
        case .base:
            "Base"
        case .rare:
            "Rare"
        case .premium:
            "Premium"
        }
    }
}

extension Decimal {
    var plainString: String {
        NSDecimalNumber(decimal: self).stringValue
    }
}

private extension String {
    var cleanedRequiredValue: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var cleanedOptionalValue: String? {
        let cleaned = cleanedRequiredValue
        return cleaned.isEmpty ? nil : cleaned
    }
}
