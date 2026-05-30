import Foundation

struct SyncRecordPayload: Codable, Equatable {
    let id: UUID
    let remoteID: String?
    let category: String
    let name: String
    let style: String
    let recordedAt: Date
    let price: Decimal
    let rating: Int
    let caffeineMG: Int?
    let sugarLevel: String
    let beanOrBase: String?
    let temperature: String
    let sizeML: Int?
    let mood: String?
    let tags: [String]
    let note: String
    let stickerID: String?
    let updatedAt: Date
    let deletedAt: Date?

    init(record: DrinkRecord) {
        self.id = record.id
        self.remoteID = record.remoteID
        self.category = record.category.rawValue
        self.name = record.name
        self.style = record.style
        self.recordedAt = record.recordedAt
        self.price = record.price
        self.rating = record.rating
        self.caffeineMG = record.caffeineMG
        self.sugarLevel = record.sugarLevel.rawValue
        self.beanOrBase = record.beanOrBase
        self.temperature = record.temperature.rawValue
        self.sizeML = record.sizeML
        self.mood = record.mood
        self.tags = record.tags
        self.note = record.note
        self.stickerID = record.stickerID
        self.updatedAt = record.updatedAt
        self.deletedAt = record.deletedAt
    }
}

struct SyncPushRequest: Codable, Equatable {
    let deviceID: String
    let records: [SyncRecordPayload]
}

struct SyncPullResponse: Codable, Equatable {
    let cursor: String
    let records: [SyncRecordPayload]
}

extension JSONEncoder {
    static var whiteBrew: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var whiteBrew: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

struct SyncClient {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
}
