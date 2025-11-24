import 'dart:math';

import '../services/security_service.dart';

/// Поддерживаемые сети кошелька.
/// Потом здесь можно добавить BSC, Polygon и т.д.
enum WalletNetwork {
  tron,
  solana,
  evm,
}

extension WalletNetworkExt on WalletNetwork {
  String get key {
    switch (this) {
      case WalletNetwork.tron:
        return 'tron';
      case WalletNetwork.solana:
        return 'solana';
      case WalletNetwork.evm:
        return 'evm';
    }
  }

  String get displayName {
    switch (this) {
      case WalletNetwork.tron:
        return 'TRON (TRC20)';
      case WalletNetwork.solana:
        return 'Solana (SPL)';
      case WalletNetwork.evm:
        return 'Ethereum (ERC20)';
    }
  }
}

/// Токен (монета) в конкретной сети
class WalletToken {
  final String symbol; // USDT, BTC, ETH, SOL и т.п.
  final String name; // Полное имя
  final WalletNetwork network;

  const WalletToken({
    required this.symbol,
    required this.name,
    required this.network,
  });
}

/// Баланс токена
class WalletTokenBalance {
  final WalletToken token;
  final double amount;
  final double? fiatValueUsd;

  const WalletTokenBalance({
    required this.token,
    required this.amount,
    this.fiatValueUsd,
  });
}

/// Сервис, который будет общаться с блокчейнами.
/// Сейчас это МОК (фейк) без реального блокчейна.
/// Но интерфейс уже нормальный: потом просто вместо моков
/// подключим реальные SDK (Tron, Solana, web3dart).
class WalletService {
  WalletService._internal();

  static final WalletService _instance = WalletService._internal();

  factory WalletService() => _instance;

  final SecurityService _security = SecurityService();

  // ----------------- СПИСОК ТОКЕНОВ ПО УМОЛЧАНИЮ -----------------

  /// ТОП токены по сетям (чтобы совпадало с твоим UX в кошельке)
  final List<WalletToken> _defaultTokens = const [
    // TRON
    WalletToken(symbol: 'USDT', name: 'Tether USD (TRC20)', network: WalletNetwork.tron),
    WalletToken(symbol: 'TRX', name: 'TRON', network: WalletNetwork.tron),

    // Solana
    WalletToken(symbol: 'SOL', name: 'Solana', network: WalletNetwork.solana),
    WalletToken(symbol: 'USDC', name: 'USD Coin (SPL)', network: WalletNetwork.solana),

    // EVM / Ethereum
    WalletToken(symbol: 'ETH', name: 'Ethereum', network: WalletNetwork.evm),
    WalletToken(symbol: 'USDT', name: 'Tether USD (ERC20)', network: WalletNetwork.evm),
    WalletToken(symbol: 'USDC', name: 'USD Coin (ERC20)', network: WalletNetwork.evm),
  ];

  List<WalletToken> getTokensForNetwork(WalletNetwork network) {
    return _defaultTokens.where((t) => t.network == network).toList();
  }

  // ----------------- АДРЕСА -----------------

  /// Создать новый адрес для сети.
  /// Пока: генерируем фейковую строку и кладём в SecurityService.
  Future<String> createAddress(WalletNetwork network) async {
    final random = Random();
    final suffix = List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();

    String address;
    switch (network) {
      case WalletNetwork.tron:
        // TRON-адреса обычно начинаются с T
        address = 'T' + suffix.toUpperCase();
        break;
      case WalletNetwork.solana:
        // Solana-адрес — просто base58-like строка (для вида сделаем SOL...)
        address = 'SoL' + suffix;
        break;
      case WalletNetwork.evm:
        // EVM-адрес
        address = '0x' + suffix;
        break;
    }

    await _security.addAddress(networkKey: network.key, address: address);
    return address;
  }

  /// Получить все адреса конкретной сети
  Future<List<String>> getAddresses(WalletNetwork network) {
    return _security.getAddressesForNetwork(network.key);
  }

  /// Получить первый адрес сети (для UI типа "получить")
  Future<String?> getMainAddress(WalletNetwork network) async {
    final list = await getAddresses(network);
    if (list.isEmpty) return null;
    return list.first;
  }

  // ----------------- БАЛАНСЫ (МОК) -----------------

  /// Получить баланс одного токена по адресу.
  /// Сейчас возвращаем мок-значения, чтобы можно было красиво показать в UI.
  Future<WalletTokenBalance> getBalanceForToken({
    required WalletToken token,
    required String address,
  }) async {
    // TODO: здесь позже вызываем реальные RPC/SDK
    final double baseAmount;
    switch (token.symbol) {
      case 'USDT':
        baseAmount = 123.45;
        break;
      case 'USDC':
        baseAmount = 987.65;
        break;
      case 'ETH':
        baseAmount = 0.42;
        break;
      case 'SOL':
        baseAmount = 3.14;
        break;
      case 'TRX':
        baseAmount = 7777.0;
        break;
      default:
        baseAmount = 0.0;
    }

    // Фейковый курс в USD (для красоты)
    final double priceUsd;
    switch (token.symbol) {
      case 'USDT':
      case 'USDC':
        priceUsd = 1.0;
        break;
      case 'ETH':
        priceUsd = 3200.0;
        break;
      case 'SOL':
        priceUsd = 150.0;
        break;
      case 'TRX':
        priceUsd = 0.11;
        break;
      default:
        priceUsd = 0.0;
    }

    return WalletTokenBalance(
      token: token,
      amount: baseAmount,
      fiatValueUsd: baseAmount * priceUsd,
    );
  }

  /// Получить ВСЕ балансы по сети и адресу (для экрана кошелька)
  Future<List<WalletTokenBalance>> getBalancesForNetwork({
    required WalletNetwork network,
    required String address,
  }) async {
    final tokens = getTokensForNetwork(network);
    final List<WalletTokenBalance> result = [];

    for (final t in tokens) {
      final b = await getBalanceForToken(token: t, address: address);
      result.add(b);
    }

    return result;
  }

  /// Получить общую сумму в USD по сети (сумма всех токенов)
  Future<double> getTotalUsdForNetwork({
    required WalletNetwork network,
    required String address,
  }) async {
    final balances = await getBalancesForNetwork(network: network, address: address);
    double sum = 0.0;
    for (final b in balances) {
      sum += b.fiatValueUsd ?? 0.0;
    }
    return sum;
  }
}

