import 'package:flutter/material.dart';
import '../theme.dart';
import 'add_token_screen.dart';
import 'receive_token_screen.dart';
import 'send_token_screen.dart';
import 'swap_screen.dart';
import 'token_details_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  /// Список токенов в кошельке (демо-данные)
  final List<Map<String, dynamic>> _tokens = [
    {
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'network': 'Bitcoin',
      'balance': 0.125,
      'fiat': 8500.0,
      'address': 'btc_demo_address',
    },
    {
      'name': 'Ethereum',
      'symbol': 'ETH',
      'network': 'Ethereum (ERC20)',
      'balance': 2.5,
      'fiat': 5000.0,
      'address': 'eth_demo_address',
    },
    {
      'name': 'Tether',
      'symbol': 'USDT',
      'network': 'Tron (TRC20)',
      'balance': 1000.0,
      'fiat': 1000.0,
      'address': 'usdt_tron_demo_address',
    },
    {
      'name': 'Tether',
      'symbol': 'USDT',
      'network': 'BNB Smart Chain (BEP20)',
      'balance': 500.0,
      'fiat': 500.0,
      'address': 'usdt_bep20_demo_address',
    },
    {
      'name': 'Solana',
      'symbol': 'SOL',
      'network': 'Solana',
      'balance': 10.0,
      'fiat': 1000.0,
      'address': 'sol_demo_address',
    },
  ];

  String _selectedFiat = 'USD'; // пока просто USD / EUR (демо)
  final double _eurRate = 0.93; // условный курс

  double get _totalUsd =>
      _tokens.fold(0.0, (sum, t) => sum + (t['fiat'] as num).toDouble());

  double get _totalFiat =>
      _selectedFiat == 'USD' ? _totalUsd : _totalUsd * _eurRate;

  String get _fiatSign => _selectedFiat;

  // ---------- НАВИГАЦИЯ ----------

  void _openAddToken() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddTokenScreen(
          onTokenAdded: (token) {
            setState(() {
              _tokens.add(token);
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _tokens.add(result);
      });
    }
  }

  void _openReceive(Map<String, dynamic> token) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiveTokenScreen(token: token),
      ),
    );
  }

  void _openSend(Map<String, dynamic> token) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendTokenScreen(token: token),
      ),
    );
  }

  void _openSwap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SwapScreen(),
      ),
    );
  }

  void _openTokenDetails(Map<String, dynamic> token) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TokenDetailsScreen(token: token),
      ),
    );
  }

  // ---------- ВСПОМОГАТЕЛЬНЫЙ ВЫБОР ТОКЕНА ДЛЯ ГЛОБАЛЬНЫХ КНОПОК ----------

  Future<void> _pickTokenForAction({
    required String title,
    required void Function(Map<String, dynamic>) onSelected,
  }) async {
    if (_tokens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала добавь хотя бы один токен')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _tokens.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Color(0xFF1F2937),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final t = _tokens[index];
                      return ListTile(
                        title: Text(
                          '${t['name']} (${t['symbol']})',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          t['network']?.toString() ?? '',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Text(
                          (t['balance'] as num).toString(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelected(t);
                        },
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
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Кошелёк'),
        actions: [
          // выбор валюты USD/EUR (пока демо)
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFiat,
              dropdownColor: AppColors.cardDark,
              iconEnabledColor: Colors.white,
              items: const [
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD'),
                ),
                DropdownMenuItem(
                  value: 'EUR',
                  child: Text('EUR'),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _selectedFiat = v;
                });
              },
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: _openAddToken,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 12),
          _buildActionRow(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTokensList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Общий баланс',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_totalFiat.toStringAsFixed(2)} $_fiatSign',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _bigActionButton(
              icon: Icons.download_rounded,
              label: 'Получить',
              onTap: () => _pickTokenForAction(
                title: 'Выбери токен для получения',
                onSelected: _openReceive,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _bigActionButton(
              icon: Icons.upload_rounded,
              label: 'Отправить',
              onTap: () => _pickTokenForAction(
                title: 'Выбери токен для отправки',
                onSelected: _openSend,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _bigActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Своп',
              onTap: _openSwap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _bigActionButton(
              icon: Icons.credit_card,
              label: 'Купить',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Экран покупки сделаем позже 🚧'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokensList() {
    if (_tokens.isEmpty) {
      return const Center(
        child: Text(
          'Пока нет токенов. Нажми +, чтобы добавить',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      itemCount: _tokens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final token = _tokens[index];
        return _buildTokenTile(token);
      },
    );
  }

  Widget _buildTokenTile(Map<String, dynamic> token) {
    final String name = token['name']?.toString() ?? '';
    final String symbol = token['symbol']?.toString() ?? '';
    final String network = token['network']?.toString() ?? '';
    final double balance = (token['balance'] as num).toDouble();
    final double fiat = (token['fiat'] as num).toDouble();

    return Card(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => _openTokenDetails(token),
        onLongPress: () => _showTokenActions(token),
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceDark,
          child: Text(
            symbol.isNotEmpty ? symbol[0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '$name ($symbol)',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          network,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              balance.toStringAsFixed(6),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '≈ ${fiat.toStringAsFixed(2)} $_fiatSign',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTokenActions(Map<String, dynamic> token) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading:
                const Icon(Icons.download_rounded, color: Colors.white),
                title: const Text(
                  'Получить',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _openReceive(token);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_rounded, color: Colors.white),
                title: const Text(
                  'Отправить',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _openSend(token);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded,
                    color: Colors.white),
                title: const Text(
                  'Своп',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _openSwap();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
