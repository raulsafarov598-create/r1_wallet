// lib/screens/swap_screen.dart

import 'package:flutter/material.dart';
import '../theme.dart';

/// Демо-набор монет (если с экрана кошелька ничего не передали)
const List<Map<String, dynamic>> demoTokens = [
  {
    'name': 'Bitcoin',
    'symbol': 'BTC',
    'balance': 0.0,
  },
  {
    'name': 'Ethereum',
    'symbol': 'ETH',
    'balance': 0.0,
  },
  {
    'name': 'Tether',
    'symbol': 'USDT',
    'balance': 0.0,
  },
  {
    'name': 'USD Coin',
    'symbol': 'USDC',
    'balance': 0.0,
  },
  {
    'name': 'Solana',
    'symbol': 'SOL',
    'balance': 0.0,
  },
  {
    'name': 'Toncoin',
    'symbol': 'TON',
    'balance': 0.0,
  },
];

class SwapScreen extends StatefulWidget {
  /// Можно передать реальные токены с кошелька, а можно не передавать — тогда
  /// используются demoTokens сверху.
  final List<Map<String, dynamic>> tokens;

  const SwapScreen({
    super.key,
    this.tokens = demoTokens,
  });

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  late Map<String, dynamic> _fromToken;
  late Map<String, dynamic> _toToken;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  /// Условные цены для демо-конвертации
  final Map<String, double> _demoPrices = {
    'BTC': 60000,
    'ETH': 3000,
    'USDT': 1,
    'USDC': 1,
    'SOL': 150,
    'TON': 6,
  };

  @override
  void initState() {
    super.initState();
    final tokens =
        widget.tokens.isNotEmpty ? widget.tokens : demoTokens;

    _fromToken = tokens[0];
    _toToken = tokens.length > 1 ? tokens[1] : tokens[0];
  }

  double _getPrice(Map<String, dynamic> token) {
    final symbol = (token['symbol'] ?? '').toString();
    return _demoPrices[symbol] ?? 1.0;
  }

  void _recalculateToAmount() {
    final raw = _fromController.text.replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0;

    final fromPrice = _getPrice(_fromToken);
    final toPrice = _getPrice(_toToken);

    final result = amount * fromPrice / toPrice;

    if (result == 0) {
      _toController.text = '';
    } else {
      _toController.text = result.toStringAsFixed(6);
    }

    setState(() {});
  }

  void _switchTokens() {
    setState(() {
      final tmp = _fromToken;
      _fromToken = _toToken;
      _toToken = tmp;
    });
    _recalculateToAmount();
  }

  Future<void> _selectToken({required bool isFrom}) async {
    final tokens =
        widget.tokens.isNotEmpty ? widget.tokens : demoTokens;

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final TextEditingController searchController =
            TextEditingController();
        List<Map<String, dynamic>> filtered = List.from(tokens);

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            void _onSearch(String value) {
              final q = value.trim().toLowerCase();
              setModalState(() {
                filtered = tokens.where((t) {
                  final name =
                      (t['name'] ?? '').toString().toLowerCase();
                  final symbol =
                      (t['symbol'] ?? '').toString().toLowerCase();
                  return name.contains(q) || symbol.contains(q);
                }).toList();
              });
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Text(
                      isFrom
                          ? 'Выбери монету, которую отдаёшь'
                          : 'Выбери монету, которую получаешь',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      onChanged: _onSearch,
                      style:
                          const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                            'Поиск по названию или символу',
                        hintStyle: const TextStyle(
                            color: Colors.white54),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const Divider(
                                color: Colors.white10, height: 1),
                        itemBuilder: (ctx, index) {
                          final token = filtered[index];
                          final symbol =
                              (token['symbol'] ?? '?')
                                  .toString()
                                  .toUpperCase();
                          return ListTile(
                            onTap: () =>
                                Navigator.of(ctx).pop(token),
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.accent.withOpacity(0.2),
                              child: Text(
                                symbol.isEmpty
                                    ? '?'
                                    : symbol[0],
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                            title: Text(
                              '${token['name']} (${token['symbol']})',
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromToken = selected;
        } else {
          _toToken = selected;
        }
      });
      _recalculateToAmount();
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromPrice = _getPrice(_fromToken);
    final toPrice = _getPrice(_toToken);
    final fromSymbol = (_fromToken['symbol'] ?? '').toString();
    final toSymbol = (_toToken['symbol'] ?? '').toString();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Своп'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwapCard(
              title: 'Отдаёшь',
              controller: _fromController,
              token: _fromToken,
              onTokenTap: () => _selectToken(isFrom: true),
              readOnly: false,
              onChanged: (_) => _recalculateToAmount(),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _switchTokens,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.swap_vert,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSwapCard(
              title: 'Получаешь',
              controller: _toController,
              token: _toToken,
              onTokenTap: () => _selectToken(isFrom: false),
              readOnly: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Своп в демо-режиме. Реальная логика будет позже.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Рассчитать и выполнить (демо)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Демо-курс: 1 $fromSymbol = '
              '${(fromPrice / toPrice).toStringAsFixed(4)} $toSymbol',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapCard({
    required String title,
    required TextEditingController controller,
    required Map<String, dynamic> token,
    required VoidCallback onTokenTap,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    final symbol = (token['symbol'] ?? '').toString();
    final name = (token['name'] ?? '').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: onChanged,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(color: Colors.white30),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onTokenTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        AppColors.accent.withOpacity(0.2),
                    child: Text(
                      symbol.isEmpty ? '?' : symbol[0],
                      style:
                          const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$name ($symbol)',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

