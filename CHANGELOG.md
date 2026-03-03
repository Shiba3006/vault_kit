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
