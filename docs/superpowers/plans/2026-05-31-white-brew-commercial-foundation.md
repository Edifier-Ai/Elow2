# White Brew Commercial Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a runnable commercial-foundation iOS app that recreates the public coffee/milk-tea tracking feature set with an original white clay-render visual system, local persistence, backend API scaffold, sync contracts, and StoreKit membership entry points.

**Architecture:** The iOS app is SwiftUI-first, generated with XcodeGen, and stores records locally with SwiftData so it works offline. A TypeScript/Fastify backend scaffold owns auth, sync, catalog, and entitlement API contracts with Prisma/Postgres schema so the commercial architecture has a concrete server boundary.

**Tech Stack:** iOS 17+, SwiftUI, SwiftData, StoreKit 2, XcodeGen, XCTest, TypeScript, Fastify, Prisma, Vitest, Postgres-compatible schema.

---

## Scope Split

The approved design covers multiple subsystems. This plan creates the first working commercial foundation:
- Native iOS app with all primary tabs and local feature behavior.
- Local drink records, statistics, stickers, share-card rendering, and membership UI.
- StoreKit 2 purchase manager using local StoreKit testing configuration.
- Backend API scaffold with typed routes, Prisma schema, and tests for sync and entitlement behavior.
- Verification commands for iOS build/tests and backend tests.

Production deployment, real Apple Developer Team setup, hosted Postgres, production App Store Connect product IDs, and public policy URLs remain release-configuration inputs from the design document.

## File Structure

Create these top-level paths:

- `.gitignore` - ignore Xcode, SwiftPM, Node, Prisma, and local environment artifacts.
- `README.md` - local run/build/test guide.
- `project.yml` - XcodeGen project definition for the iOS app and tests.
- `WhiteBrew.storekit` - local StoreKit test products.
- `WhiteBrew/WhiteBrewApp.swift` - app entry point and SwiftData container.
- `WhiteBrew/App/AppRootView.swift` - tab shell.
- `WhiteBrew/App/AppTab.swift` - tab enum and metadata.
- `WhiteBrew/Design/ClayTheme.swift` - white clay colors, shadows, radii.
- `WhiteBrew/Design/ClayComponents.swift` - reusable buttons/cards/metrics.
- `WhiteBrew/Domain/DrinkRecord.swift` - SwiftData model and enums.
- `WhiteBrew/Domain/CatalogModels.swift` - sticker, character, theme, and membership domain types.
- `WhiteBrew/Services/StatsEngine.swift` - pure stats aggregation.
- `WhiteBrew/Services/SyncClient.swift` - backend sync client contract.
- `WhiteBrew/Services/PurchaseManager.swift` - StoreKit 2 state and actions.
- `WhiteBrew/Services/ShareCardRenderer.swift` - SwiftUI image export service.
- `WhiteBrew/Features/Today/TodayView.swift` - today dashboard.
- `WhiteBrew/Features/Records/RecordsView.swift` - timeline and search.
- `WhiteBrew/Features/Records/EditDrinkView.swift` - add/edit sheet.
- `WhiteBrew/Features/Stats/StatsView.swift` - week/month/year statistics.
- `WhiteBrew/Features/Cabinet/CabinetView.swift` - stickers, characters, themes.
- `WhiteBrew/Features/Profile/ProfileView.swift` - login, membership, sync, privacy.
- `WhiteBrew/Resources/PreviewData.swift` - local preview fixtures.
- `WhiteBrewTests/StatsEngineTests.swift` - deterministic stats tests.
- `WhiteBrewTests/SyncClientTests.swift` - request/response contract tests.
- `WhiteBrewTests/PurchaseManagerTests.swift` - entitlement state tests.
- `backend/package.json` - backend scripts and dependencies.
- `backend/tsconfig.json` - strict TypeScript settings.
- `backend/vitest.config.ts` - backend test config.
- `backend/prisma/schema.prisma` - Postgres data model.
- `backend/src/server.ts` - Fastify app factory.
- `backend/src/routes/auth.ts` - auth routes.
- `backend/src/routes/sync.ts` - sync routes.
- `backend/src/routes/iap.ts` - entitlement routes.
- `backend/src/routes/catalog.ts` - catalog route.
- `backend/src/domain/sync.ts` - pure sync merge logic.
- `backend/src/domain/entitlements.ts` - pure entitlement logic.
- `backend/test/sync.test.ts` - backend sync behavior tests.
- `backend/test/entitlements.test.ts` - entitlement behavior tests.

## Task 1: Initialize Workspace

**Files:**
- Create: `.gitignore`
- Create: `README.md`

- [ ] **Step 1: Initialize git**

Run:

```bash
git init -b main
```

Expected: git creates a `main` branch in `/Users/summer/Desktop/ELOW2`.

- [ ] **Step 2: Create `.gitignore`**

Create `.gitignore` with:

```gitignore
.DS_Store
.superpowers/
DerivedData/
*.xcuserstate
*.xcuserdata/
build/
.build/
.swiftpm/
Package.resolved
node_modules/
backend/node_modules/
backend/.env
backend/.env.local
backend/prisma/dev.db
backend/coverage/
dist/
```

- [ ] **Step 3: Create `README.md`**

Create `README.md` with:

```markdown
# White Brew

White Brew is an original iOS coffee and milk-tea tracking app with a pure white clay-render visual style, local offline records, statistics, stickers, share cards, membership entry points, and a backend sync scaffold.

## Requirements

- Xcode 26.4.1 or newer
- XcodeGen
- Node.js 25 or newer
- npm 11 or newer

## iOS

```bash
xcodegen generate
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Backend

```bash
cd backend
npm install
npm test
```
```

- [ ] **Step 4: Commit workspace initialization**

Run:

```bash
git add .gitignore README.md
git commit -m "chore: initialize white brew workspace"
```

Expected: commit succeeds.

## Task 2: Generate iOS Project

**Files:**
- Create: `project.yml`
- Create: `WhiteBrew.storekit`
- Create: `WhiteBrew/WhiteBrewApp.swift`
- Create: `WhiteBrew/App/AppRootView.swift`
- Create: `WhiteBrew/App/AppTab.swift`
- Create: `WhiteBrew/Resources/PreviewData.swift`
- Create: `WhiteBrewTests/StatsEngineTests.swift`

Controller note for execution: keep Task 2 as a compiling app shell only. Do not reference `DrinkRecord` or SwiftData yet; Task 3 introduces the model and wires SwiftData into the app entry point.

- [ ] **Step 1: Create `project.yml`**

Create `project.yml` with:

```yaml
name: WhiteBrew
options:
  minimumXcodeGenVersion: 2.42.0
  deploymentTarget:
    iOS: "17.0"
settings:
  base:
    SWIFT_VERSION: "5.9"
    IPHONEOS_DEPLOYMENT_TARGET: "17.0"
packages: {}
targets:
  WhiteBrew:
    type: application
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - WhiteBrew
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.example.whitebrew
        MARKETING_VERSION: "0.1.0"
        CURRENT_PROJECT_VERSION: "1"
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
    info:
      path: WhiteBrew/Info.plist
      properties:
        CFBundleDisplayName: White Brew
        UILaunchScreen: {}
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
        ITSAppUsesNonExemptEncryption: false
  WhiteBrewTests:
    type: bundle.unit-test
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - WhiteBrewTests
    dependencies:
      - target: WhiteBrew
```

- [ ] **Step 2: Create local StoreKit configuration**

Create `WhiteBrew.storekit` with:

```json
{
  "identifier" : "WhiteBrew",
  "nonRenewingSubscriptions" : [
    {
      "displayPrice" : "149.00",
      "familyShareable" : false,
      "internalID" : "whitebrew.annual",
      "localizations" : [
        {
          "description" : "Unlock full history stats, premium clay themes, sticker cabinet, cloud sync, and share card templates for one year.",
          "displayName" : "Annual Member",
          "locale" : "en_US"
        }
      ],
      "productID" : "whitebrew.annual",
      "referenceName" : "Annual Member"
    },
    {
      "displayPrice" : "298.00",
      "familyShareable" : false,
      "internalID" : "whitebrew.lifetime",
      "localizations" : [
        {
          "description" : "Unlock all premium features permanently.",
          "displayName" : "Lifetime Member",
          "locale" : "en_US"
        }
      ],
      "productID" : "whitebrew.lifetime",
      "referenceName" : "Lifetime Member"
    }
  ],
  "settings" : {}
}
```

- [ ] **Step 3: Create minimal app shell files**

Create `WhiteBrew/WhiteBrewApp.swift` with:

```swift
import SwiftUI

@main
struct WhiteBrewApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
```

Create `WhiteBrew/App/AppTab.swift` with:

```swift
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case records
    case stats
    case cabinet
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .records: "Record"
        case .stats: "Stats"
        case .cabinet: "Cabinet"
        case .profile: "Me"
        }
    }

    var symbol: String {
        switch self {
        case .today: "cup.and.saucer"
        case .records: "calendar"
        case .stats: "chart.bar"
        case .cabinet: "square.grid.3x3"
        case .profile: "person"
        }
    }
}
```

Create `WhiteBrew/App/AppRootView.swift` with:

```swift
import SwiftUI

struct AppRootView: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label(AppTab.today.title, systemImage: AppTab.today.symbol) }
                .tag(AppTab.today)

            RecordsView()
                .tabItem { Label(AppTab.records.title, systemImage: AppTab.records.symbol) }
                .tag(AppTab.records)

            StatsView()
                .tabItem { Label(AppTab.stats.title, systemImage: AppTab.stats.symbol) }
                .tag(AppTab.stats)

            CabinetView()
                .tabItem { Label(AppTab.cabinet.title, systemImage: AppTab.cabinet.symbol) }
                .tag(AppTab.cabinet)

            ProfileView()
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.symbol) }
                .tag(AppTab.profile)
        }
    }
}
```

- [ ] **Step 4: Create initial feature views**

Create `WhiteBrew/Features/Today/TodayView.swift` with:

```swift
import SwiftUI

struct TodayView: View {
    var body: some View { Text("Today").padding() }
}
```

Create `WhiteBrew/Features/Records/RecordsView.swift` with:

```swift
import SwiftUI

struct RecordsView: View {
    var body: some View { Text("Record").padding() }
}
```

Create `WhiteBrew/Features/Records/EditDrinkView.swift` with:

```swift
import SwiftUI

struct EditDrinkView: View {
    var body: some View {
        Text("New Drink").padding()
    }
}
```

Create `WhiteBrew/Features/Stats/StatsView.swift` with:

```swift
import SwiftUI

struct StatsView: View {
    var body: some View { Text("Stats").padding() }
}
```

Create `WhiteBrew/Features/Cabinet/CabinetView.swift` with:

```swift
import SwiftUI

struct CabinetView: View {
    var body: some View { Text("Cabinet").padding() }
}
```

Create `WhiteBrew/Features/Profile/ProfileView.swift` with:

```swift
import SwiftUI

struct ProfileView: View {
    var body: some View { Text("Me").padding() }
}
```

- [ ] **Step 5: Generate and build**

Run:

```bash
xcodegen generate
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 6: Commit iOS project scaffold**

Run:

```bash
git add project.yml WhiteBrew.storekit WhiteBrew WhiteBrewTests
git commit -m "chore: scaffold white brew ios app"
```

## Task 3: Add Domain Models And Fixtures

**Files:**
- Create: `WhiteBrew/Domain/DrinkRecord.swift`
- Create: `WhiteBrew/Domain/CatalogModels.swift`
- Modify: `WhiteBrew/Resources/PreviewData.swift`
- Test: `WhiteBrewTests/StatsEngineTests.swift`

- [ ] **Step 1: Add drink domain model**

Create `WhiteBrew/Domain/DrinkRecord.swift` with:

```swift
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
    var rating: Int
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
        self.rating = min(max(rating, 1), 5)
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
}
```

- [ ] **Step 2: Add catalog models**

Create `WhiteBrew/Domain/CatalogModels.swift` with:

```swift
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

enum MembershipState: Equatable {
    case free
    case annual(expiresAt: Date?)
    case lifetime

    var isMember: Bool {
        switch self {
        case .free: false
        case .annual, .lifetime: true
        }
    }
}
```

- [ ] **Step 3: Add preview fixtures**

Create `WhiteBrew/Resources/PreviewData.swift` with:

```swift
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

    static let records: [DrinkRecord] = [
        .init(category: .coffee, name: "Morning Latte", style: "Latte", recordedAt: .now.addingTimeInterval(-3600), price: 32, rating: 5, caffeineMG: 86, sugarLevel: .low, beanOrBase: "Ethiopia", temperature: .hot, sizeML: 300, mood: "Focused", tags: ["milk", "morning"], note: "Soft and balanced.", stickerID: "foam-01"),
        .init(category: .milkTea, name: "Oolong Milk Tea", style: "Milk Tea", recordedAt: .now.addingTimeInterval(-86400), price: 26, rating: 4, caffeineMG: 54, sugarLevel: .half, beanOrBase: "Oolong", temperature: .iced, sizeML: 500, mood: "Calm", tags: ["tea", "iced"], note: "Clean finish.", stickerID: "latte-arch")
    ]
}
```

- [ ] **Step 4: Build**

Run:

```bash
xcodegen generate
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 5: Commit domain models**

Run:

```bash
git add WhiteBrew/Domain WhiteBrew/Resources project.yml
git commit -m "feat: add drink domain models"
```

## Task 4: Add Statistics Engine With Tests

**Files:**
- Create: `WhiteBrew/Services/StatsEngine.swift`
- Modify: `WhiteBrewTests/StatsEngineTests.swift`

- [ ] **Step 1: Write failing stats tests**

Create `WhiteBrewTests/StatsEngineTests.swift` with:

```swift
import XCTest
@testable import WhiteBrew

final class StatsEngineTests: XCTestCase {
    func testSummaryCountsActiveDaysSpendAndCaffeine() {
        let calendar = Calendar(identifier: .gregorian)
        let first = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1, hour: 9))!
        let second = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 15))!
        let records = [
            DrinkRecord(category: .coffee, name: "Latte", style: "Latte", recordedAt: first, price: 30, rating: 5, caffeineMG: 90, sugarLevel: .low, beanOrBase: nil, temperature: .hot, sizeML: 300, mood: nil, tags: ["milk"], note: "", stickerID: nil),
            DrinkRecord(category: .milkTea, name: "Milk Tea", style: "Oolong", recordedAt: second, price: 20, rating: 4, caffeineMG: 40, sugarLevel: .half, beanOrBase: nil, temperature: .iced, sizeML: 500, mood: nil, tags: ["tea"], note: "", stickerID: nil)
        ]

        let summary = StatsEngine.summary(for: records, calendar: calendar)

        XCTAssertEqual(summary.totalCups, 2)
        XCTAssertEqual(summary.activeDays, 2)
        XCTAssertEqual(summary.totalSpend, 50)
        XCTAssertEqual(summary.totalCaffeineMG, 130)
        XCTAssertEqual(summary.preferredStyle, "Latte")
    }
}
```

- [ ] **Step 2: Run test and confirm failure**

Run:

```bash
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:WhiteBrewTests/StatsEngineTests
```

Expected: compile fails because `StatsEngine` does not exist.

- [ ] **Step 3: Implement `StatsEngine`**

Create `WhiteBrew/Services/StatsEngine.swift` with:

```swift
import Foundation

struct StatsSummary: Equatable {
    let totalCups: Int
    let activeDays: Int
    let totalSpend: Decimal
    let averagePrice: Decimal
    let totalCaffeineMG: Int
    let preferredStyle: String
    let mostCommonTimeWindow: String
    let coffeeCount: Int
    let milkTeaCount: Int
}

enum StatsEngine {
    static func summary(for records: [DrinkRecord], calendar: Calendar = .current) -> StatsSummary {
        let visibleRecords = records.filter { $0.deletedAt == nil }
        let totalCups = visibleRecords.count
        let activeDays = Set(visibleRecords.map { calendar.startOfDay(for: $0.recordedAt) }).count
        let totalSpend = visibleRecords.reduce(Decimal.zero) { $0 + $1.price }
        let averagePrice = totalCups == 0 ? 0 : totalSpend / Decimal(totalCups)
        let totalCaffeine = visibleRecords.compactMap(\.caffeineMG).reduce(0, +)
        let preferredStyle = mostFrequent(visibleRecords.map(\.style)) ?? "None"
        let mostCommonTimeWindow = mostFrequent(visibleRecords.map { timeWindow(for: $0.recordedAt, calendar: calendar) }) ?? "None"
        let coffeeCount = visibleRecords.filter { $0.category == .coffee }.count
        let milkTeaCount = visibleRecords.filter { $0.category == .milkTea }.count

        return StatsSummary(
            totalCups: totalCups,
            activeDays: activeDays,
            totalSpend: totalSpend,
            averagePrice: averagePrice,
            totalCaffeineMG: totalCaffeine,
            preferredStyle: preferredStyle,
            mostCommonTimeWindow: mostCommonTimeWindow,
            coffeeCount: coffeeCount,
            milkTeaCount: milkTeaCount
        )
    }

    private static func mostFrequent(_ values: [String]) -> String? {
        values.reduce(into: [String: Int]()) { counts, value in
            counts[value, default: 0] += 1
        }
        .sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key < rhs.key }
            return lhs.value > rhs.value
        }
        .first?.key
    }

    private static func timeWindow(for date: Date, calendar: Calendar) -> String {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12: "Morning"
        case 12..<18: "Afternoon"
        default: "Evening"
        }
    }
}
```

- [ ] **Step 4: Run tests**

Run:

```bash
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:WhiteBrewTests/StatsEngineTests
```

Expected: `TEST SUCCEEDED`.

- [ ] **Step 5: Commit stats engine**

Run:

```bash
git add WhiteBrew/Services/StatsEngine.swift WhiteBrewTests/StatsEngineTests.swift
git commit -m "feat: add drink statistics engine"
```

## Task 5: Build Clay Visual System

**Files:**
- Create: `WhiteBrew/Design/ClayTheme.swift`
- Create: `WhiteBrew/Design/ClayComponents.swift`

- [ ] **Step 1: Create theme tokens**

Create `WhiteBrew/Design/ClayTheme.swift` with:

```swift
import SwiftUI

enum ClayTheme {
    static let background = Color.white
    static let surface = Color(red: 0.97, green: 0.97, blue: 0.94)
    static let raised = Color(red: 0.99, green: 0.99, blue: 0.97)
    static let text = Color(red: 0.13, green: 0.13, blue: 0.12)
    static let secondaryText = Color(red: 0.45, green: 0.45, blue: 0.40)
    static let hairline = Color(red: 0.88, green: 0.88, blue: 0.84)
    static let selected = Color(red: 0.16, green: 0.16, blue: 0.14)

    static let cardRadius: CGFloat = 24
    static let controlRadius: CGFloat = 18

    static func raisedShadow() -> some ViewModifier {
        ClayRaisedShadow()
    }
}

private struct ClayRaisedShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 10, y: 14)
            .shadow(color: Color.white.opacity(0.95), radius: 8, x: -4, y: -5)
    }
}
```

- [ ] **Step 2: Create reusable components**

Create `WhiteBrew/Design/ClayComponents.swift` with:

```swift
import SwiftUI

struct ClayCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: ClayTheme.cardRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ClayTheme.raised, ClayTheme.surface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ClayTheme.cardRadius, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
            )
            .modifier(ClayTheme.raisedShadow())
    }
}

struct ClayButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(ClayTheme.text)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: [.white, ClayTheme.surface], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .modifier(ClayTheme.raisedShadow())
        }
        .buttonStyle(.plain)
    }
}

struct ClayMetricTile: View {
    let label: String
    let value: String

    var body: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(ClayTheme.secondaryText)
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(ClayTheme.text)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
```

- [ ] **Step 3: Build**

Run:

```bash
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 4: Commit visual system**

Run:

```bash
git add WhiteBrew/Design
git commit -m "feat: add white clay visual system"
```

## Task 6: Implement Local iOS Feature Screens

**Files:**
- Modify: `WhiteBrew/Features/Today/TodayView.swift`
- Modify: `WhiteBrew/Features/Records/RecordsView.swift`
- Modify: `WhiteBrew/Features/Records/EditDrinkView.swift`
- Modify: `WhiteBrew/Features/Stats/StatsView.swift`
- Modify: `WhiteBrew/Features/Cabinet/CabinetView.swift`
- Modify: `WhiteBrew/Features/Profile/ProfileView.swift`

- [ ] **Step 1: Implement Today dashboard**

Replace `TodayView` with a SwiftData-backed view that queries records, computes `StatsEngine.summary`, shows today's metrics, recent records, and opens `EditDrinkView` from a sheet.

Core structure:

```swift
import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkRecord.recordedAt, order: .reverse) private var records: [DrinkRecord]
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Today Flavor").font(.largeTitle.bold())
                            Text("A quiet white space for each cup.").foregroundStyle(ClayTheme.secondaryText)
                        }
                        Spacer()
                        ClayButton(title: "Record", systemImage: "plus") { isAdding = true }
                    }

                    let summary = StatsEngine.summary(for: records)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ClayMetricTile(label: "Cups", value: "\(summary.totalCups)")
                        ClayMetricTile(label: "Caffeine", value: "\(summary.totalCaffeineMG) mg")
                        ClayMetricTile(label: "Spend", value: "\(summary.totalSpend)")
                        ClayMetricTile(label: "Style", value: summary.preferredStyle)
                    }

                    ClayCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent").font(.headline)
                            ForEach(records.prefix(5)) { record in
                                HStack {
                                    Text(record.name).font(.body.weight(.semibold))
                                    Spacer()
                                    Text(record.style).foregroundStyle(ClayTheme.secondaryText)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(ClayTheme.background)
            .sheet(isPresented: $isAdding) {
                EditDrinkView(record: nil)
            }
        }
    }
}
```

- [ ] **Step 2: Implement add/edit form**

`EditDrinkView` must include fields for category, name, style, date, price, rating, caffeine, sugar, bean/base, temperature, size, mood, tags, note, and sticker. Saving inserts or updates `DrinkRecord`, sets `updatedAt`, and dismisses.

- [ ] **Step 3: Implement records timeline**

`RecordsView` must query records, filter by search text, show timeline rows, and open `EditDrinkView(record:)` for editing.

- [ ] **Step 4: Implement Stats**

`StatsView` must show a week/month/year segmented control, summary metrics, drink split, time window, and simple white clay bar chart from records.

- [ ] **Step 5: Implement Cabinet**

`CabinetView` must display sticker grid, character shelf, theme selector, and share-card template tiles from `PreviewData`.

- [ ] **Step 6: Implement Profile**

`ProfileView` must display login call-to-action, membership state, purchase/restore buttons, sync status, data export/import rows, privacy, and terms rows.

- [ ] **Step 7: Build and run tests**

Run:

```bash
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Expected: `TEST SUCCEEDED`.

- [ ] **Step 8: Commit local screens**

Run:

```bash
git add WhiteBrew/Features
git commit -m "feat: implement local coffee tracking screens"
```

## Task 7: Add StoreKit Purchase Manager

**Files:**
- Create: `WhiteBrew/Services/PurchaseManager.swift`
- Modify: `WhiteBrew/Features/Profile/ProfileView.swift`
- Test: `WhiteBrewTests/PurchaseManagerTests.swift`

- [ ] **Step 1: Write entitlement state tests**

Create `WhiteBrewTests/PurchaseManagerTests.swift` with:

```swift
import XCTest
@testable import WhiteBrew

final class PurchaseManagerTests: XCTestCase {
    func testLifetimeEntitlementIsMember() {
        XCTAssertTrue(MembershipState.lifetime.isMember)
    }

    func testFreeEntitlementIsNotMember() {
        XCTAssertFalse(MembershipState.free.isMember)
    }
}
```

- [ ] **Step 2: Implement `PurchaseManager`**

Create `WhiteBrew/Services/PurchaseManager.swift` with:

```swift
import Foundation
import StoreKit

@MainActor
@Observable
final class PurchaseManager {
    private let productIDs = ["whitebrew.annual", "whitebrew.lifetime"]

    var products: [Product] = []
    var membershipState: MembershipState = .free
    var isLoading = false
    var errorMessage: String?

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                applyEntitlement(productID: transaction.productID, expirationDate: transaction.expirationDate)
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                errorMessage = "Purchase could not be completed."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var newState: MembershipState = .free
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == "whitebrew.lifetime" {
                    newState = .lifetime
                } else if transaction.productID == "whitebrew.annual" {
                    newState = .annual(expiresAt: transaction.expirationDate)
                }
            }
        }
        membershipState = newState
    }

    private func applyEntitlement(productID: String, expirationDate: Date?) {
        if productID == "whitebrew.lifetime" {
            membershipState = .lifetime
        } else if productID == "whitebrew.annual" {
            membershipState = .annual(expiresAt: expirationDate)
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum PurchaseError: Error {
    case failedVerification
}
```

- [ ] **Step 3: Wire purchase manager into Profile**

Add `@State private var purchaseManager = PurchaseManager()` to `ProfileView`, call `await purchaseManager.loadProducts()` in `.task`, render products, and call `purchaseManager.purchase(product)` from premium buttons.

- [ ] **Step 4: Run tests**

Run:

```bash
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:WhiteBrewTests/PurchaseManagerTests
```

Expected: `TEST SUCCEEDED`.

- [ ] **Step 5: Commit StoreKit work**

Run:

```bash
git add WhiteBrew.storekit WhiteBrew/Services/PurchaseManager.swift WhiteBrew/Features/Profile/ProfileView.swift WhiteBrewTests/PurchaseManagerTests.swift
git commit -m "feat: add storekit membership manager"
```

## Task 8: Add Sync Client Contract

**Files:**
- Create: `WhiteBrew/Services/SyncClient.swift`
- Test: `WhiteBrewTests/SyncClientTests.swift`

- [ ] **Step 1: Write sync request encoding test**

Create `WhiteBrewTests/SyncClientTests.swift` with:

```swift
import XCTest
@testable import WhiteBrew

final class SyncClientTests: XCTestCase {
    func testPushRequestEncodesChangedRecords() throws {
        let record = DrinkRecord(category: .coffee, name: "Flat White", style: "Flat White", recordedAt: Date(timeIntervalSince1970: 1_780_000_000), price: 28, rating: 5, caffeineMG: 80, sugarLevel: .none, beanOrBase: "Blend", temperature: .hot, sizeML: 250, mood: "Clear", tags: ["morning"], note: "Clean milk.", stickerID: "foam-01")
        let request = SyncPushRequest(deviceID: "test-device", records: [.init(record: record)])
        let data = try JSONEncoder.whiteBrew.encode(request)
        let json = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(json.contains("Flat White"))
        XCTAssertTrue(json.contains("test-device"))
    }
}
```

- [ ] **Step 2: Implement sync types and client**

Create `WhiteBrew/Services/SyncClient.swift` with:

```swift
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
        id = record.id
        remoteID = record.remoteID
        category = record.category.rawValue
        name = record.name
        style = record.style
        recordedAt = record.recordedAt
        price = record.price
        rating = record.rating
        caffeineMG = record.caffeineMG
        sugarLevel = record.sugarLevel.rawValue
        beanOrBase = record.beanOrBase
        temperature = record.temperature.rawValue
        sizeML = record.sizeML
        mood = record.mood
        tags = record.tags
        note = record.note
        stickerID = record.stickerID
        updatedAt = record.updatedAt
        deletedAt = record.deletedAt
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
```

- [ ] **Step 3: Run sync tests**

Run:

```bash
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:WhiteBrewTests/SyncClientTests
```

Expected: `TEST SUCCEEDED`.

- [ ] **Step 4: Commit sync client contract**

Run:

```bash
git add WhiteBrew/Services/SyncClient.swift WhiteBrewTests/SyncClientTests.swift
git commit -m "feat: add sync client contract"
```

## Task 9: Add Share Card Rendering

**Files:**
- Create: `WhiteBrew/Services/ShareCardRenderer.swift`
- Modify: `WhiteBrew/Features/Records/RecordsView.swift`

- [ ] **Step 1: Implement share card view and renderer**

Create `WhiteBrew/Services/ShareCardRenderer.swift` with:

```swift
import SwiftUI

struct ShareCardView: View {
    let record: DrinkRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(record.name)
                .font(.largeTitle.bold())
                .foregroundStyle(ClayTheme.text)
            Text(record.style)
                .font(.title3)
                .foregroundStyle(ClayTheme.secondaryText)
            HStack {
                Text("\(record.rating)/5")
                Text("\(record.caffeineMG ?? 0) mg")
                Text(record.sugarLevel.rawValue)
            }
            .font(.headline)
            .foregroundStyle(ClayTheme.text)
            Text(record.note)
                .font(.body)
                .foregroundStyle(ClayTheme.secondaryText)
            Text("White Brew")
                .font(.caption.bold())
                .foregroundStyle(ClayTheme.secondaryText)
        }
        .padding(28)
        .frame(width: 900, height: 1200, alignment: .topLeading)
        .background(ClayTheme.background)
    }
}

@MainActor
enum ShareCardRenderer {
    static func image(for record: DrinkRecord) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(record: record))
        renderer.scale = 2
        return renderer.uiImage
    }
}
```

- [ ] **Step 2: Add share action to record rows**

In `RecordsView`, add a share action that calls `ShareCardRenderer.image(for:)` and presents a `ShareLink` or `UIActivityViewController` wrapper for the generated image.

- [ ] **Step 3: Build**

Run:

```bash
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 4: Commit share card work**

Run:

```bash
git add WhiteBrew/Services/ShareCardRenderer.swift WhiteBrew/Features/Records/RecordsView.swift
git commit -m "feat: add white brew share cards"
```

## Task 10: Scaffold Backend

**Files:**
- Create: `backend/package.json`
- Create: `backend/tsconfig.json`
- Create: `backend/vitest.config.ts`
- Create: `backend/src/server.ts`
- Create: `backend/src/routes/auth.ts`
- Create: `backend/src/routes/sync.ts`
- Create: `backend/src/routes/iap.ts`
- Create: `backend/src/routes/catalog.ts`

- [ ] **Step 1: Create backend package**

Create `backend/package.json` with:

```json
{
  "name": "white-brew-backend",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx src/server.ts",
    "test": "vitest run",
    "typecheck": "tsc --noEmit",
    "prisma:generate": "prisma generate"
  },
  "dependencies": {
    "@fastify/cors": "^11.0.0",
    "@prisma/client": "^6.8.0",
    "fastify": "^5.3.3",
    "zod": "^3.25.0"
  },
  "devDependencies": {
    "prisma": "^6.8.0",
    "tsx": "^4.19.4",
    "typescript": "^5.8.3",
    "vitest": "^3.1.4"
  }
}
```

- [ ] **Step 2: Add TypeScript config**

Create `backend/tsconfig.json` with:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist"
  },
  "include": ["src", "test", "vitest.config.ts"]
}
```

Create `backend/vitest.config.ts` with:

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node"
  }
});
```

- [ ] **Step 3: Implement Fastify app factory**

Create `backend/src/server.ts` with:

```ts
import cors from "@fastify/cors";
import Fastify from "fastify";
import { registerAuthRoutes } from "./routes/auth.js";
import { registerCatalogRoutes } from "./routes/catalog.js";
import { registerIapRoutes } from "./routes/iap.js";
import { registerSyncRoutes } from "./routes/sync.js";

export function buildServer() {
  const app = Fastify({ logger: true });
  app.register(cors, { origin: true });
  app.get("/health", async () => ({ ok: true }));
  app.register(registerAuthRoutes, { prefix: "/auth" });
  app.register(registerSyncRoutes, { prefix: "/sync" });
  app.register(registerIapRoutes, { prefix: "/iap" });
  app.register(registerCatalogRoutes, { prefix: "/catalog" });
  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const app = buildServer();
  const port = Number(process.env.PORT ?? 8787);
  await app.listen({ host: "127.0.0.1", port });
}
```

- [ ] **Step 4: Add route modules**

Create `backend/src/routes/auth.ts` with:

```ts
import type { FastifyPluginAsync } from "fastify";

export const registerAuthRoutes: FastifyPluginAsync = async (app) => {
  app.post("/apple", async () => ({ token: "local-dev-token", user: { id: "local-user" } }));
  app.post("/email/start", async () => ({ sent: true }));
  app.post("/email/verify", async () => ({ token: "local-dev-token", user: { id: "local-user" } }));
};
```

Create `backend/src/routes/sync.ts` with:

```ts
import type { FastifyPluginAsync } from "fastify";

export const registerSyncRoutes: FastifyPluginAsync = async (app) => {
  app.post("/push", async () => ({ accepted: true, cursor: "local-cursor" }));
  app.get("/pull", async () => ({ cursor: "local-cursor", records: [] }));
};
```

Create `backend/src/routes/iap.ts` with:

```ts
import type { FastifyPluginAsync } from "fastify";

export const registerIapRoutes: FastifyPluginAsync = async (app) => {
  app.post("/verify", async () => ({ status: "active", type: "lifetime", expiresAt: null }));
};
```

Create `backend/src/routes/catalog.ts` with:

```ts
import type { FastifyPluginAsync } from "fastify";

export const registerCatalogRoutes: FastifyPluginAsync = async (app) => {
  app.get("/", async () => ({
    stickers: [
      { id: "foam-01", name: "Foam Shell", rarity: "base", isPremium: false },
      { id: "moon-cup", name: "Moon Cup", rarity: "premium", isPremium: true }
    ],
    characters: [
      { id: "first-sip", name: "First Sip", unlockRule: "Create first record" }
    ],
    themes: [
      { id: "gallery-white", name: "Gallery White", isPremium: false },
      { id: "studio-clay", name: "Studio Clay", isPremium: true }
    ]
  }));
};
```

- [ ] **Step 5: Install and typecheck**

Run:

```bash
cd backend
npm install
npm run typecheck
```

Expected: typecheck passes.

- [ ] **Step 6: Commit backend scaffold**

Run:

```bash
git add backend
git commit -m "feat: scaffold commercial backend api"
```

## Task 11: Add Backend Domain Tests

**Files:**
- Create: `backend/src/domain/sync.ts`
- Create: `backend/src/domain/entitlements.ts`
- Create: `backend/test/sync.test.ts`
- Create: `backend/test/entitlements.test.ts`

- [ ] **Step 1: Write sync merge test**

Create `backend/test/sync.test.ts` with:

```ts
import { describe, expect, it } from "vitest";
import { chooseWinningRecord } from "../src/domain/sync.js";

describe("chooseWinningRecord", () => {
  it("keeps the newest updatedAt value", () => {
    const older = { id: "r1", name: "Old", updatedAt: "2026-05-01T00:00:00.000Z" };
    const newer = { id: "r1", name: "New", updatedAt: "2026-05-02T00:00:00.000Z" };
    expect(chooseWinningRecord(older, newer)).toEqual(newer);
  });
});
```

- [ ] **Step 2: Implement sync merge logic**

Create `backend/src/domain/sync.ts` with:

```ts
export type SyncComparableRecord = {
  id: string;
  updatedAt: string;
  [key: string]: unknown;
};

export function chooseWinningRecord<T extends SyncComparableRecord>(local: T, incoming: T): T {
  const localTime = Date.parse(local.updatedAt);
  const incomingTime = Date.parse(incoming.updatedAt);
  if (incomingTime >= localTime) {
    return incoming;
  }
  return local;
}
```

- [ ] **Step 3: Write entitlement test**

Create `backend/test/entitlements.test.ts` with:

```ts
import { describe, expect, it } from "vitest";
import { normalizeEntitlement } from "../src/domain/entitlements.js";

describe("normalizeEntitlement", () => {
  it("returns lifetime for lifetime product", () => {
    expect(normalizeEntitlement({ productId: "whitebrew.lifetime", expiresAt: null })).toEqual({
      status: "active",
      type: "lifetime",
      expiresAt: null
    });
  });
});
```

- [ ] **Step 4: Implement entitlement logic**

Create `backend/src/domain/entitlements.ts` with:

```ts
export type EntitlementInput = {
  productId: string;
  expiresAt: string | null;
};

export type EntitlementState = {
  status: "active" | "expired";
  type: "annual" | "lifetime";
  expiresAt: string | null;
};

export function normalizeEntitlement(input: EntitlementInput): EntitlementState {
  if (input.productId === "whitebrew.lifetime") {
    return { status: "active", type: "lifetime", expiresAt: null };
  }

  if (input.expiresAt && Date.parse(input.expiresAt) > Date.now()) {
    return { status: "active", type: "annual", expiresAt: input.expiresAt };
  }

  return { status: "expired", type: "annual", expiresAt: input.expiresAt };
}
```

- [ ] **Step 5: Run backend tests**

Run:

```bash
cd backend
npm test
npm run typecheck
```

Expected: tests and typecheck pass.

- [ ] **Step 6: Commit backend domain tests**

Run:

```bash
git add backend/src/domain backend/test
git commit -m "test: cover sync and entitlement domain logic"
```

## Task 12: Add Prisma Schema

**Files:**
- Create: `backend/prisma/schema.prisma`
- Create: `backend/.env.example`

- [ ] **Step 1: Create Prisma schema**

Create `backend/prisma/schema.prisma` with:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id          String        @id @default(cuid())
  email       String?       @unique
  appleSub    String?       @unique
  displayName String?
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt
  records     DrinkRecord[]
  entitlements Entitlement[]
  cursors     SyncCursor[]
}

model DrinkRecord {
  id          String    @id @default(cuid())
  userId      String
  clientId    String
  deviceId    String
  category    String
  name        String
  style       String
  recordedAt  DateTime
  price       Decimal
  rating      Int
  caffeineMG  Int?
  sugarLevel  String
  beanOrBase  String?
  temperature String
  sizeML      Int?
  mood        String?
  tags        String[]
  note        String
  stickerID   String?
  version     Int       @default(1)
  deletedAt   DateTime?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  user        User      @relation(fields: [userId], references: [id])

  @@index([userId, updatedAt])
  @@unique([userId, clientId])
}

model Entitlement {
  id                    String    @id @default(cuid())
  userId                String
  productId             String
  type                  String
  status                String
  expiresAt             DateTime?
  originalTransactionId String?
  latestTransactionId   String?
  createdAt             DateTime  @default(now())
  updatedAt             DateTime  @updatedAt
  user                  User      @relation(fields: [userId], references: [id])

  @@index([userId, status])
}

model SyncCursor {
  id        String   @id @default(cuid())
  userId    String
  deviceId  String
  cursor    String
  updatedAt DateTime @updatedAt
  user      User     @relation(fields: [userId], references: [id])

  @@unique([userId, deviceId])
}
```

- [ ] **Step 2: Add env example**

Create `backend/.env.example` with:

```dotenv
DATABASE_URL="postgresql://whitebrew:whitebrew@localhost:5432/whitebrew"
PORT=8787
```

- [ ] **Step 3: Generate Prisma client**

Run:

```bash
cd backend
DATABASE_URL="postgresql://whitebrew:whitebrew@localhost:5432/whitebrew" npm run prisma:generate
```

Expected: Prisma client generation succeeds.

- [ ] **Step 4: Commit Prisma schema**

Run:

```bash
git add backend/prisma/schema.prisma backend/.env.example backend/package-lock.json backend/package.json
git commit -m "feat: add backend postgres schema"
```

## Task 13: Final Verification

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Run iOS tests**

Run:

```bash
xcodegen generate
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Expected: `TEST SUCCEEDED`.

- [ ] **Step 2: Run backend tests**

Run:

```bash
cd backend
npm test
npm run typecheck
```

Expected: Vitest and TypeScript both pass.

- [ ] **Step 3: Launch iOS app on simulator**

Use XcodeBuildMCP simulator workflow. First call `session_show_defaults`. If defaults are missing, configure the project as `WhiteBrew.xcodeproj`, scheme `WhiteBrew`, and an available iPhone simulator. Then run build-and-launch.

Expected:
- App launches to the Today tab.
- Bottom tabs are visible.
- Add record sheet opens.
- Profile shows membership entry points.

- [ ] **Step 4: Start backend health check**

Run:

```bash
cd backend
npm run dev
```

In another shell:

```bash
curl -s http://127.0.0.1:8787/health
```

Expected:

```json
{"ok":true}
```

- [ ] **Step 5: Update README verification section**

Append the final passing command outputs and simulator target used to `README.md` under a `## Verification` heading.

- [ ] **Step 6: Commit final verification docs**

Run:

```bash
git add README.md
git commit -m "docs: record commercial foundation verification"
```

## Self-Review Checklist

- Source-scope requirements from the approved design are represented: drink records, stats, stickers, characters, themes, share cards, membership, backend API, sync, privacy-facing settings.
- The plan uses concrete file paths and commands.
- iOS and backend tests are part of the implementation, not an afterthought.
- The app remains original and does not copy reference branding or assets.
- Release-only inputs are separated from local development so implementation can start immediately.
