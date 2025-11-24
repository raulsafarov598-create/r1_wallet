import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Очень простой мок-бэкенд для безопасности.
/// ⚠️ ВАЖНО: сейчас всё хранится ТОЛЬКО в памяти (пока приложение запущено).
/// После перезапуска всё пропадёт. Это осознанно — чтобы не добавлять новые
/// пакеты в pubspec и не ловить ошибки. Потом заменим на secure storage.
class SecurityService {
  SecurityService._internal();

  static final SecurityService _instance = SecurityService._internal();

  factory SecurityService() => _instance;

  // ----------------- ХРАНИЛКА В ПАМЯТИ -----------------

  /// Хэш PIN-кода (SHA256)
  String? _pinHash;

  /// "Зашифрованная" сид-фраза (пока просто строка, будет заменено)
  String? _encryptedSeed;

  /// Адреса по сетям -> список строк
  final Map<String, List<String>> _addressesByNetwork = {};

  // ----------------- PIN КОД -----------------

  /// Установить PIN-код (минимум 4 цифры).
  Future<void> setPin(String pin) async {
    if (pin.length < 4) {
      throw ArgumentError('PIN должен быть минимум 4 символа');
    }
    _pinHash = _hash(pin);
  }

  /// Проверить PIN-код.
  Future<bool> verifyPin(String pin) async {
    if (_pinHash == null) return false;
    return _hash(pin) == _pinHash;
  }

  bool get hasPin => _pinHash != null;

  // ----------------- СИД-ФРАЗА -----------------

  /// Сохранить сид-фразу (пока БЕЗ шифрования — только мок).
  Future<void> saveSeedPhrase(String seed) async {
    // Здесь потом добавим шифрование + secure storage
    _encryptedSeed = seed;
  }

  /// Получить сид-фразу (мок).
  Future<String?> getSeedPhrase() async {
    return _encryptedSeed;
  }

  bool get hasSeed => _encryptedSeed != null;

  // ----------------- АДРЕСА ПО СЕТЯМ -----------------

  /// Сохранить адрес для сети (например, tron / solana / evm)
  Future<void> addAddress({
    required String networkKey,
    required String address,
  }) async {
    final list = _addressesByNetwork.putIfAbsent(networkKey, () => []);
    if (!list.contains(address)) {
      list.add(address);
    }
  }

  /// Получить все адреса конкретной сети
  Future<List<String>> getAddressesForNetwork(String networkKey) async {
    return List<String>.from(_addressesByNetwork[networkKey] ?? []);
  }

  /// Получить ВСЕ адреса по всем сетям
  Future<Map<String, List<String>>> getAllAddresses() async {
    final result = <String, List<String>>{};
    _addressesByNetwork.forEach((key, value) {
      result[key] = List<String>.from(value);
    });
    return result;
  }

  // ----------------- ВСПОМОГАТЕЛЬНОЕ -----------------

  String _hash(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }
}

