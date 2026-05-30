import Foundation

struct SyncRecordPayload: Codable, Equatable {
    let clientId: UUID
    let remoteId: String?
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

    enum CodingKeys: String, CodingKey {
        case clientId
        case remoteId = "id"
        case category
        case name
        case style
        case recordedAt
        case price
        case rating
        case caffeineMG = "caffeineMg"
        case sugarLevel
        case beanOrBase
        case temperature
        case sizeML = "sizeMl"
        case mood
        case tags
        case note
        case stickerID = "stickerId"
        case updatedAt
        case deletedAt
    }

    init(record: DrinkRecord) {
        self.clientId = record.id
        self.remoteId = record.remoteID
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
    let deviceId: String
    let records: [SyncRecordPayload]

    enum CodingKeys: String, CodingKey {
        case deviceId
        case records
    }
}

struct SyncPullResponse: Codable, Equatable {
    let cursor: String
    let records: [SyncRecordPayload]

    enum CodingKeys: String, CodingKey {
        case cursor
        case records
    }
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
