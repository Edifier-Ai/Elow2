import Foundation

enum StickerRarity: String, Codable {
    case base
    case rare
    case premium
}

struct BrewSticker: Identifiable, Hashable {
    let id: String
    let name: String
    let rarity: StickerRarity
    let isPremium: Bool
    let unlockRule: String?
}

struct BrewCharacter: Identifiable, Hashable {
    let id: String
    let name: String
    let unlocked: Bool
    let unlockRule: String
}

struct BrewTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let isPremium: Bool
    let lightingPreset: String
    let surfaceDepth: Double
}

struct ShareCardTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let isPremium: Bool
}

enum MembershipState: Equatable {
    case free
    case annual(expiresAt: Date?)
    case lifetime

    var isMember: Bool {
        isMember(asOf: .now)
    }

    func isMember(asOf date: Date) -> Bool {
        switch self {
        case .free:
            false
        case .annual(let expiresAt):
            expiresAt.map { $0 > date } ?? true
        case .lifetime:
            true
        }
    }
}
