import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_kit/vault_kit.dart';

void main() {
  late VaultKit vault;
  final Map<String, String> storage = {};

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    vault = VaultKit();

    // 👈 intercept the MethodChannel directly
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('vault_kit_channel'),
      (MethodCall call) async {
        switch (call.method) {
          case 'save':
            storage[call.arguments['key']] = call.arguments['value'];
            return null;
          case 'fetch':
            return storage[call.arguments['key']];
          case 'delete':
            storage.remove(call.arguments['key']);
            return null;
          case 'clearAll':
            storage.clear();
            return null;
          case 'has':
            return storage.containsKey(call.arguments['key']);
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    storage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('vault_kit_channel'),
      null,
    );
  });

  // -------------------------------------------------------
  // 💾 save()
  // -------------------------------------------------------

  group('save()', () {
    test('saves a string value successfully', () async {
      await expectLater(
        vault.save(key: 'token', value: 'eyJhbGci...'),
        completes,
      );
    });

    test('overwrites existing value for same key', () async {
      await vault.save(key: 'token', value: 'first');
      await vault.save(key: 'token', value: 'second');
      final result = await vault.fetch<String>(key: 'token');
      expect(result, equals('second'));
    });
  });

  // -------------------------------------------------------
  // 📦 fetch()
  // -------------------------------------------------------

  group('fetch()', () {
    test('returns null when key does not exist', () async {
      final result = await vault.fetch<String>(key: 'non_existent');
      expect(result, isNull);
    });

    test('fetches a saved string value', () async {
      await vault.save(key: 'token', value: 'eyJhbGci...');
      final result = await vault.fetch<String>(key: 'token');
      expect(result, equals('eyJhbGci...'));
    });

    test('fetches and deserializes a model with fromJson', () async {
      await vault.save(key: 'user', value: '{"name":"John","age":30}');
      final result = await vault.fetch<Map<String, dynamic>>(
        key: 'user',
        fromJson: (p) {
          // 👇 p is already a String from mock storage, parse it first
          if (p is String) return jsonDecode(p) as Map<String, dynamic>;
          return p as Map<String, dynamic>;
        },
      );
      expect(result?['name'], equals('John'));
      expect(result?['age'], equals(30));
    });
  });

  // -------------------------------------------------------
  // 🗑 delete()
  // -------------------------------------------------------

  group('delete()', () {
    test('deletes an existing key', () async {
      await vault.save(key: 'token', value: 'eyJhbGci...');
      await vault.delete(key: 'token');
      final result = await vault.fetch<String>(key: 'token');
      expect(result, isNull);
    });

    test('only deletes the target key', () async {
      await vault.save(key: 'token', value: 'token_value');
      await vault.save(key: 'password', value: 'pass_value');
      await vault.delete(key: 'token');
      expect(await vault.fetch<String>(key: 'token'), isNull);
      expect(await vault.fetch<String>(key: 'password'), equals('pass_value'));
    });

    test('no-op when key does not exist', () async {
      await expectLater(vault.delete(key: 'non_existent'), completes);
    });
  });

  // -------------------------------------------------------
  // 🧹 clearAll()
  // -------------------------------------------------------

  group('clearAll()', () {
    test('clears all stored values', () async {
      await vault.save(key: 'token', value: 'token_value');
      await vault.save(key: 'password', value: 'pass_value');
      await vault.clearAll();
      expect(await vault.fetch<String>(key: 'token'), isNull);
      expect(await vault.fetch<String>(key: 'password'), isNull);
    });

    test('no-op when storage is already empty', () async {
      await expectLater(vault.clearAll(), completes);
    });
  });

  // -------------------------------------------------------
  // 🔍 has()
  // -------------------------------------------------------

  group('has()', () {
    test('returns false when key does not exist', () async {
      expect(await vault.has(key: 'non_existent'), isFalse);
    });

    test('returns true after saving', () async {
      await vault.save(key: 'token', value: 'eyJhbGci...');
      expect(await vault.has(key: 'token'), isTrue);
    });

    test('returns false after delete', () async {
      await vault.save(key: 'token', value: 'eyJhbGci...');
      await vault.delete(key: 'token');
      expect(await vault.has(key: 'token'), isFalse);
    });

    test('returns false after clearAll', () async {
      await vault.save(key: 'token', value: 'eyJhbGci...');
      await vault.clearAll();
      expect(await vault.has(key: 'token'), isFalse);
    });
  });

  // -------------------------------------------------------
  // 🔗 Integration
  // -------------------------------------------------------

  group('integration', () {
    test('full save → fetch → delete → has lifecycle', () async {
      await vault.save(key: 'token', value: 'eyJhbGci...');
      expect(await vault.has(key: 'token'), isTrue);

      final token = await vault.fetch<String>(key: 'token');
      expect(token, equals('eyJhbGci...'));

      await vault.delete(key: 'token');
      expect(await vault.has(key: 'token'), isFalse);
    });

    test('multiple keys are isolated', () async {
      await vault.save(key: 'token', value: 'token_value');
      await vault.save(key: 'password', value: 'pass_value');

      await vault.delete(key: 'token');

      expect(await vault.has(key: 'token'), isFalse);
      expect(await vault.has(key: 'password'), isTrue);
    });

    test('clearAll on logout wipes everything', () async {
      await vault.save(key: 'token', value: 'token_value');
      await vault.save(key: 'password', value: 'pass_value');

      await vault.clearAll();

      expect(await vault.has(key: 'token'), isFalse);
      expect(await vault.has(key: 'password'), isFalse);
    });
  });
}
