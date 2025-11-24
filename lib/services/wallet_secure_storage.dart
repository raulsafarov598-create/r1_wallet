import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ключи, под которыми будем хранить данные
class _Keys {
  static const pinHash = 'r1_pin_hash';
  static const seedEncrypted = 'r1_seed_encrypted';
  static const hasWallet = 'r1_has_wallet';
  static const autoLockSeconds = 'r1_auto_lock_sec';
}

/// Простое “шифрование” для демо.
/// В ПРОДАКШЕНЕ надо будет перейти на настоящую крипту + secure storage.
class _SimpleEncryptor {
  static const String _secret = 'r1_wallet_demo_key_2025';

  static String encrypt(String plain) {
    final plainBytes = utf8.encode(plain);
    final keyBytes = utf8.encode(_secret);
    final out = <int>[];

    for (var i = 0; i < plainBytes.length; i++) {
      out.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64UrlEncode(out);
  }

  static String decrypt(String cipher) {
    try {
      final cipherBytes = base64Url.decode(cipher);
      final keyBytes = utf8.encode(_secret);
      final out = <int>[];

      for (var i = 0; i < cipherBytes.length; i++) {
        out.add(cipherBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(out);
    } catch (_) {
      return '';
    }
  }
}

/// Основной класс для работы с локальным хранилищем кошелька.
class WalletSecureStorage {
  // ---------- PIN ----------

  /// Сохранить PIN (хранится только SHA256-хэш)
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = sha256.convert(utf8.encode(pin)).toString();
    await prefs.setString(_Keys.pinHash, hash);
  }

  /// Проверить PIN — считаем хэш и сравниваем
  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_Keys.pinHash);
    if (stored == null) return false;

    final hash = sha256.convert(utf8.encode(pin)).toString();
    return stored == hash;
  }

  /// Есть ли вообще сохранённый PIN
  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_Keys.pinHash);
  }

  /// Сбросить PIN (например, при логауте)
  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_Keys.pinHash);
  }

  // ---------- SEED-ФРАЗА ----------

  /// Сохранить сид-фразу (строкой, через пробел) в зашифрованном виде
  static Future<void> saveSeedPhrase(List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    final joined = words.join(' ');
    final encrypted = _SimpleEncryptor.encrypt(joined);
    await prefs.setString(_Keys.seedEncrypted, encrypted);
    await prefs.setBool(_Keys.hasWallet, true);
  }

  /// Получить расшифрованную сид-фразу (список слов) или null
  static Future<List<String>?> getSeedPhrase() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_Keys.seedEncrypted);
    if (encrypted == null || encrypted.isEmpty) return null;

    final plain = _SimpleEncryptor.decrypt(encrypted);
    if (plain.trim().isEmpty) return null;

    return plain.split(RegExp(r'\s+'));
  }

  /// Есть ли уже сохранённый кошелёк (seed)
  static Future<bool> hasWallet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_Keys.hasWallet) ?? false;
  }

  /// Полный сброс сид-фразы
  static Future<void> clearSeed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_Keys.seedEncrypted);
    await prefs.setBool(_Keys.hasWallet, false);
  }

  // ---------- АВТОБЛОКИРОВКА (на будущее) ----------

  /// Сохранить таймаут автоблокировки в секундах (например 60, 300, 600)
  static Future<void> setAutoLockSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_Keys.autoLockSeconds, seconds);
  }

  static Future<int> getAutoLockSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_Keys.autoLockSeconds) ?? 60; // дефолт: 1 минута
  }
}

