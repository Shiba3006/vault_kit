## 1.0.6
- Update: bump minimum supported Flutter to 3.44.0 / Dart to 3.12.0.
- Add: Swift Package Manager support for iOS alongside the existing CocoaPods podspec.
- Add: iOS privacy manifest (PrivacyInfo.xcprivacy) declaring UserDefaults API usage.
- Update: align iOS deployment target to 13.0 (podspec previously targeted 11.0 while the example app required 13.0).
- Update: bump Android Gradle Plugin to 8.9.1, Kotlin to 2.1.0, compileSdk to 36.
- Update: bump flutter_lints to ^6.0.0.
- Chore: remove stray generated GeneratedPluginRegistrant files from ios/Runner.

## 1.0.5
- Fix: clear Keychain data on fresh iOS app install to prevent stale 
  credentials from previous installations being accessible after reinstall.
  iOS Keychain persists data across uninstalls by default — this fix adds
  a first-launch detection using `UserDefaults` to wipe any residual 
  Keychain entries on fresh install, aligning iOS behavior with Android 
  which automatically wipes data on uninstall.

## 1.0.4
- Fix: explicitly set `kSecAttrSynchronizable: false` on iOS to fully exclude Keychain items from iCloud sync and backups.

## 1.0.3
- update: make class VaultKit const.

## 1.0.2
- Fix: update README and deleted unused file.

## 1.0.1
- Fix: update README logo path.

## 1.0.0
- Initial release.
- Android Keystore AES-256-GCM encryption with unique IV per entry.
- iOS Keychain storage with kSecAttrAccessibleWhenUnlockedThisDeviceOnly.
- save, fetch, delete, clearAll, has operations.
- Generic adapter — store any JSON-encodable type.
- Zero third-party dependencies.
- Full test coverage via MethodChannel mock binding.
