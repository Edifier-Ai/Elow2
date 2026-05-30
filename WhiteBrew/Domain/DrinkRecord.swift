import Foundation
import SwiftData

enum DrinkCategory: String, Codable, CaseIterable, Identifiable {
    case coffee
    case milkTea

    var id: String { rawValue }
}

enum SugarLevel: String, Codable, CaseIterable, Identifiable {
    case none
    case low
    case half
    case regular

    var id: String { rawValue }
}

enum DrinkTemperature: String, Codable, CaseIterable, Identifiable {
    case hot
    case iced
    case room

    var id: String { rawValue }
}

enum SyncState: String, Codable {
    case localOnly
    case pendingUpload
    case synced
    case failed
}

@Model
final class DrinkRecord {
    @Attribute(.unique) var id: UUID
    var remoteID: String?
    var categoryRaw: String
    var name: String
    var style: String
    var recordedAt: Date
    var price: Decimal
    var ratingValue: Int
    var caffeineMG: Int?
    var sugarLevelRaw: String
    var beanOrBase: String?
    var temperatureRaw: String
    var sizeML: Int?
    var mood: String?
    var tags: [String]
    var note: String
    var stickerID: String?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var syncStateRaw: String
    var lastSyncedAt: Date?

    var category: DrinkCategory {
        get { DrinkCategory(rawValue: categoryRaw) ?? .coffee }
        set { categoryRaw = newValue.rawValue }
    }

    var sugarLevel: SugarLevel {
        get { SugarLevel(rawValue: sugarLevelRaw) ?? .regular }
        set { sugarLevelRaw = newValue.rawValue }
    }

    var temperature: DrinkTemperature {
        get { DrinkTemperature(rawValue: temperatureRaw) ?? .hot }
        set { temperatureRaw = newValue.rawValue }
    }

    var syncState: SyncState {
        get { SyncState(rawValue: syncStateRaw) ?? .localOnly }
        set { syncStateRaw = newValue.rawValue }
    }

    var rating: Int {
        get { Self.clampedRating(ratingValue) }
        set { ratingValue = Self.clampedRating(newValue) }
    }

    init(
        id: UUID = UUID(),
        remoteID: String? = nil,
        category: DrinkCategory,
        name: String,
        style: String,
        recordedAt: Date,
        price: Decimal,
        rating: Int,
        caffeineMG: Int?,
        sugarLevel: SugarLevel,
        beanOrBase: String?,
        temperature: DrinkTemperature,
        sizeML: Int?,
        mood: String?,
        tags: [String],
        note: String,
        stickerID: String?,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        deletedAt: Date? = nil,
        syncState: SyncState = .localOnly,
        lastSyncedAt: Date? = nil
    ) {
        self.id = id
        self.remoteID = remoteID
        self.categoryRaw = category.rawValue
        self.name = name
        self.style = style
        self.recordedAt = recordedAt
        self.price = price
        self.ratingValue = Self.clampedRating(rating)
        self.caffeineMG = caffeineMG
        self.sugarLevelRaw = sugarLevel.rawValue
        self.beanOrBase = beanOrBase
        self.temperatureRaw = temperature.rawValue
        self.sizeML = sizeML
        self.mood = mood
        self.tags = tags
        self.note = note
        self.stickerID = stickerID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncStateRaw = syncState.rawValue
        self.lastSyncedAt = lastSyncedAt
    }

    private static func clampedRating(_ rating: Int) -> Int {
        min(max(rating, 1), 5)
    }
}
