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

## Verification

Last verified on 2026-05-31 with iPhone 17 Simulator (iOS 26.4).

```bash
xcodegen generate
xcodebuild -project WhiteBrew.xcodeproj -scheme WhiteBrew -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Result: `TEST SUCCEEDED`, 35 XCTest cases passed.

```bash
cd backend
npm test
npm run typecheck
DATABASE_URL="postgresql://whitebrew:whitebrew@localhost:5432/whitebrew" npm run prisma:generate
npm run dev
curl -s http://127.0.0.1:8787/health
```

Result: Vitest passed 3 files / 7 tests, TypeScript typecheck passed, Prisma client generation passed, and health returned `{"ok":true}`.

Runtime simulator check:

- XcodeBuildMCP launched `com.example.whitebrew` on iPhone 17 Simulator.
- Today tab rendered the white clay UI with bottom tabs.
- Add opened the New Drink sheet.
- Profile showed Current plan, Premium plans, and Restore purchases.
- Screenshot evidence: `/tmp/whitebrew-final-profile.png`.
