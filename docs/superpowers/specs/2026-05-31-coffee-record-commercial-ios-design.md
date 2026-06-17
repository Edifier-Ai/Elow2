# Coffee Record Commercial iOS App Design

## Source Scope

The reference product is the public App Store listing for "一饮 - 咖啡人每日咖啡记录", version 1.0.5: https://apps.apple.com/tw/app/id6761892104. The implementation will reproduce the publicly described product capabilities, not the original brand, artwork, screenshots, icons, copy, or proprietary assets.

Publicly visible feature scope:
- Daily coffee and milk tea records.
- Name, drink type, price, rating, caffeine, sugar, coffee bean, inspiration, and feeling fields.
- Weekly, monthly, and yearly trends.
- Frequency, active days, spending changes, common drink time, and preferred style.
- Sticker-style records, share cards, multiple themes.
- Coffee character collection and sticker cabinet.
- Annual and lifetime membership products.
- Local privacy posture: no third-party data collection by default.

## Product Direction

The app is a commercial iOS product for people who want a durable personal drink diary. It should work immediately offline, sync when signed in, and provide paid upgrades for long-term statistics, premium themes, premium stickers, backup, and cross-device use.

The visual language is original: a clean white spatial interface inspired by Blender/C4D clay renders. The UI uses matte white surfaces, embossed controls, soft directional lighting, light shadows, and small architectural composition. The background stays pure white. No realistic textures, busy decoration, or dark color system should be used.

Working title for implementation: `White Brew`. The name can be replaced before release.

## Platform And Architecture

Minimum platform:
- iOS 17.0+.
- SwiftUI for UI.
- SwiftData for local persistence and offline-first cache.
- StoreKit 2 for annual and lifetime memberships.
- Backend API for account, sync, subscription entitlement verification, backup, and future analytics snapshots.

Commercial architecture:
- The iOS app is usable without login for local records.
- Login unlocks cloud backup and cross-device sync.
- StoreKit purchases are initiated on device.
- The backend validates App Store transactions and returns normalized entitlement state.
- The app stores the latest entitlement locally and refreshes it on launch and purchase updates.

## Navigation

Use a bottom tab app shell with five tabs:

1. Today
   - Main daily dashboard.
   - Current day record summary.
   - Add record entry point.
   - Today's flavor/sticker card.
   - Recent drink list.

2. Record
   - Drink timeline and calendar.
   - Search and filters.
   - Add/edit record flow.

3. Stats
   - Week, month, and year segmented control.
   - Frequency, active days, spend, caffeine, sugar, time-of-day, and style preference modules.
   - Free users see basic recent stats; members see full history and advanced breakdowns.

4. Cabinet
   - Sticker cabinet.
   - Coffee character collection.
   - Theme picker.
   - Share-card templates.

5. Me
   - Profile and login state.
   - Membership status and purchase/restore entry.
   - Sync status.
   - Data export/import.
   - Privacy, terms, and app settings.

## Core Flows

### Add Drink Record

The add flow opens as a sheet from Today or Record.

Fields:
- Drink category: coffee or milk tea.
- Name.
- Type/style, such as latte, americano, hand brew, espresso, cold brew, cappuccino, mocha, milk tea, fruit tea.
- Date and time.
- Price.
- Rating.
- Caffeine amount.
- Sugar level.
- Coffee bean or tea base.
- Temperature: hot, iced, room.
- Size.
- Mood.
- Tags.
- Inspiration/notes.
- Sticker selection.

Save behavior:
- Validate name, category, and date.
- Persist locally immediately.
- Queue sync if user is signed in.
- Recompute visible stats locally.

### Edit And Delete

Records can be opened from Today, Record timeline, calendar, and Stats drilldowns.

Delete behavior:
- Confirm destructive delete.
- Tombstone synced records locally so deletion can sync safely.
- Permanently remove unsynced local-only records.

### Stats Review

Stats are derived from local records first. Backend snapshots are an optimization for signed-in users, but the app must not require network for normal statistics.

Stats modules:
- Total cups.
- Active days.
- Average cups per active day.
- Total spend.
- Average price.
- Caffeine total and daily average.
- Sugar distribution.
- Most common time window.
- Preferred style.
- Coffee versus milk tea split.
- Top tags.
- Trend bars by day/week/month.

### Stickers, Characters, And Themes

Sticker records:
- Each drink can attach one sticker.
- Stickers appear in Today, Record detail, share cards, and Cabinet.

Coffee character collection:
- Characters are unlocked by milestones, such as first record, seven active days, first hand brew, monthly streak, low sugar week, high rating streak.
- The collection is presented as a white 3D figurine shelf, not copied from the reference app.

Themes:
- The base theme is included for all users.
- Premium themes remain white/clay-rendered but vary lighting, surface depth, and accent material.

### Share Cards

Users can generate a share card for a single drink, a day summary, or a period summary.

Share card contents:
- Drink name, category, rating, date, style, price, caffeine/sugar summary, note excerpt, selected sticker.
- App brand watermark.
- Export as image through the iOS share sheet.

Implementation:
- Use SwiftUI rendering to produce an image.
- Keep share card templates original.

### Membership

Products:
- Annual membership.
- Lifetime membership.

Member benefits:
- Full history statistics.
- Premium themes.
- Premium stickers and character shelves.
- Cloud backup and sync.
- Extra share-card templates.
- Data export conveniences.

Free tier:
- Unlimited local records in the initial product.
- Basic recent stats.
- Base stickers, base theme, and basic share card.

Purchase flow:
- StoreKit 2 product loading.
- Purchase, restore, transaction updates.
- Backend receipt/transaction validation when logged in.
- Local entitlement fallback when offline.

## Data Model

### Local SwiftData Entities

`DrinkRecord`
- `id: UUID`
- `remoteID: String?`
- `category: DrinkCategory`
- `name: String`
- `style: String`
- `recordedAt: Date`
- `price: Decimal`
- `rating: Int`
- `caffeineMG: Int?`
- `sugarLevel: SugarLevel`
- `beanOrBase: String?`
- `temperature: DrinkTemperature`
- `sizeML: Int?`
- `mood: String?`
- `tags: [String]`
- `note: String`
- `stickerID: String?`
- `createdAt: Date`
- `updatedAt: Date`
- `deletedAt: Date?`
- `syncState: SyncState`
- `lastSyncedAt: Date?`

`Sticker`
- `id: String`
- `name: String`
- `rarity: StickerRarity`
- `isPremium: Bool`
- `unlockRule: String?`

`Character`
- `id: String`
- `name: String`
- `unlockState: UnlockState`
- `unlockRule: String`
- `unlockedAt: Date?`

`Theme`
- `id: String`
- `name: String`
- `isPremium: Bool`
- `lightingPreset: String`
- `surfaceDepth: Double`

`UserProfile`
- `id: UUID`
- `remoteUserID: String?`
- `displayName: String`
- `email: String?`
- `signInProvider: String?`
- `membership: MembershipState`
- `lastSyncAt: Date?`

### Backend Tables

`users`
- `id`
- `email`
- `apple_sub`
- `display_name`
- `created_at`
- `updated_at`

`drink_records`
- Mirrors `DrinkRecord` fields.
- Includes `user_id`, `client_id`, `device_id`, `version`, and tombstone fields.

`entitlements`
- `user_id`
- `product_id`
- `type`
- `status`
- `expires_at`
- `original_transaction_id`
- `latest_transaction_id`

`sync_cursors`
- `user_id`
- `device_id`
- `cursor`
- `updated_at`

`share_exports`
- Optional metadata for future saved cloud exports.

## Backend API

Initial endpoints:

- `POST /auth/apple`
- `POST /auth/email/start`
- `POST /auth/email/verify`
- `GET /me`
- `PATCH /me`
- `POST /sync/push`
- `GET /sync/pull?cursor=...`
- `POST /iap/verify`
- `GET /entitlements`
- `GET /catalog`

Sync behavior:
- App sends changed records since last successful push.
- Backend accepts upserts and tombstones.
- Backend returns server changes since cursor.
- Conflict resolution uses newest `updatedAt`; if equal, server version wins.
- Client keeps a sync log for failed attempts and retries with backoff.

## Visual System

Design principles:
- Pure white background.
- Matte white cards and controls.
- Subtle 3D extrusion through shadows and highlights.
- No realistic paper, coffee, wood, fabric, or photographic texture.
- Small accent usage only for charts and selected states; default remains monochrome white.
- Icons are system or custom line icons; no copied app icon or reference artwork.

Component set:
- `ClayButton`
- `ClayCard`
- `ClaySegmentedControl`
- `ClayTabBar`
- `ClayMetricTile`
- `ClayChartBar`
- `ClayStickerTile`
- `ClayShareCard`
- `ClayShelf`

Accessibility:
- Maintain contrast through text and shadow, not color alone.
- Dynamic Type support for primary text.
- VoiceOver labels for record actions, chart summaries, and purchase buttons.
- Reduce Motion disables large spring transitions while preserving state changes.

## Error Handling

Local save failure:
- Show inline error and keep form content.

Sync failure:
- Keep app usable.
- Show sync status in Me.
- Retry silently with backoff.

Purchase failure:
- Distinguish cancellation, pending, failed verification, and network failure.
- Provide restore purchases.

Backend unavailable:
- App runs local mode.
- Queue changes.
- Refresh entitlements when network access returns.

## Privacy And Compliance

Default stance:
- No third-party tracking.
- No advertising SDK.
- No analytics until explicitly added and disclosed.
- Drink records are private user content.

Commercial launch requirements:
- Privacy policy.
- Terms of use.
- App Store Connect in-app purchase products.
- Sign in with Apple if other third-party/login options are offered.
- Server-side App Store transaction validation.
- Data deletion/export path.

## Testing And Verification

iOS tests:
- Unit tests for stats aggregation.
- Unit tests for sync conflict resolution.
- Unit tests for entitlement state transitions.
- SwiftUI previews for empty, populated, offline, member, and non-member states.

Backend tests:
- API contract tests.
- Auth tests.
- Sync upsert/tombstone tests.
- Entitlement verification tests with mocked App Store responses.

Manual QA:
- Add/edit/delete drink record.
- Offline add then online sync.
- Week/month/year stats.
- Sticker unlocks.
- Share image export.
- Purchase success, cancellation, restore, and expired entitlement.
- App launch with no network.

## Implementation Phasing

Phase 1: App foundation
- Create iOS SwiftUI project.
- Add clay visual system.
- Add local SwiftData models.
- Implement Today, Record, Add/Edit, Stats, Cabinet, Me with local data.

Phase 2: Commercial systems
- Add backend service scaffold.
- Add auth, sync, and entitlement APIs.
- Add StoreKit 2 purchase UI and local StoreKit testing configuration.

Phase 3: Polish and release readiness
- Add share-card rendering.
- Add premium catalog rules.
- Add privacy/terms screens.
- Add test coverage and simulator verification.
- Prepare App Store configuration checklist.

## Open Release Inputs

The following are required before real App Store release but do not block local development:
- Apple Developer Team ID.
- Bundle identifier.
- App display name.
- Annual membership product ID.
- Lifetime membership product ID.
- Backend hosting provider and production URL.
- Privacy policy URL.
- Terms URL.
