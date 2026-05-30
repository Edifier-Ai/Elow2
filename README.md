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
