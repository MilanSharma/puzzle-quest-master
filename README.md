# Puzzle Quest Master

A native iOS Match-3 puzzle game built using SwiftUI and the Combine framework.

## Features

- **Core Gameplay**: Custom 8x8 grid match-3 engine with cascading mechanics.
- **Architecture**: MVVM pattern with separation of concerns between GameState and Views.
- **Persistence**: `NSUbiquitousKeyValueStore` (iCloud Key-Value) for cross-device progress syncing.
- **Monetization**: 
  - StoreKit 2 for In-App Purchases (Consumables & Subscriptions).
  - Google Mobile Ads SDK for Interstitial ads.

## Requirements

- iOS 17.0+
- Xcode 15.2+

## Setup Instructions

1. **Open the Project**
   Open `PuzzleQuestMaster/PuzzleQuestMaster.xcodeproj` in Xcode.

2. **Dependencies**
   The project requires the Google Mobile Ads SDK. 
   - In Xcode, go to **File > Add Package Dependencies...**
   - Enter URL: `https://github.com/googleads/google-mobile-ads-sdk-ios`
   - Click **Add Package**.

3. **Configuration**
   - Update `Info.plist` with your AdMob App ID (`GADApplicationIdentifier`).
   - Update `Services/MonetizationManager.swift` with your specific Product IDs from App Store Connect.

4. **Build**
   Select your target simulator or device and press `Cmd+R`.

## License

Copyright © 2025. All rights reserved.
