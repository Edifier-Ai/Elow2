import Foundation

enum PreviewData {
    static let stickers: [BrewSticker] = [
        .init(id: "foam-01", name: "Foam Shell", rarity: .base, isPremium: false, unlockRule: nil),
        .init(id: "latte-arch", name: "Latte Arch", rarity: .rare, isPremium: false, unlockRule: "Record 7 active days"),
        .init(id: "moon-cup", name: "Moon Cup", rarity: .premium, isPremium: true, unlockRule: "Premium")
    ]

    static let characters: [BrewCharacter] = [
        .init(id: "first-sip", name: "First Sip", unlocked: true, unlockRule: "Create first record"),
        .init(id: "week-builder", name: "Week Builder", unlocked: false, unlockRule: "Record 7 active days"),
        .init(id: "low-sugar", name: "Low Sugar Form", unlocked: false, unlockRule: "Record five low-sugar drinks")
    ]

    static let themes: [BrewTheme] = [
        .init(id: "gallery-white", name: "Gallery White", isPremium: false, lightingPreset: "soft-left", surfaceDepth: 0.7),
        .init(id: "studio-clay", name: "Studio Clay", isPremium: true, lightingPreset: "top-diffuse", surfaceDepth: 1.0),
        .init(id: "model-room", name: "Model Room", isPremium: true, lightingPreset: "ambient-grid", surfaceDepth: 1.2)
    ]

    static func records(now: Date = .now) -> [DrinkRecord] {
        [
            .init(category: .coffee, name: "Morning Latte", style: "Latte", recordedAt: now.addingTimeInterval(-3600), price: 32, rating: 5, caffeineMG: 86, sugarLevel: .low, beanOrBase: "Ethiopia", temperature: .hot, sizeML: 300, mood: "Focused", tags: ["milk", "morning"], note: "Soft and balanced.", stickerID: "foam-01"),
            .init(category: .milkTea, name: "Oolong Milk Tea", style: "Milk Tea", recordedAt: now.addingTimeInterval(-86400), price: 26, rating: 4, caffeineMG: 54, sugarLevel: .half, beanOrBase: "Oolong", temperature: .iced, sizeML: 500, mood: "Calm", tags: ["tea", "iced"], note: "Clean finish.", stickerID: "latte-arch")
        ]
    }
}
