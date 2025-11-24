// lib/screens/token_details_screen.dart

import 'package:flutter/material.dart';
import '../theme.dart';
import 'receive_token_screen.dart';
import 'send_token_screen.dart';

class TokenDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> token;

  const TokenDetailsScreen({super.key, required this.token});

  @override
  State<TokenDetailsScreen> createState() =>
      _TokenDetailsScreenState();
}

class _TokenDetailsScreenState extends State<TokenDetailsScreen> {
  List<Map<String, dynamic>> txHistory = [];

  String get _name => widget.token['name']?.toString() ?? '';
  String get _symbol =>
      (widget.token['symbol'] ?? '').toString().toUpperCase();
  String get _network =>
      widget.token['network']?.toString() ?? '';

  double get _balance =>
      (widget.token['balance'] as double? ?? 0.0);
  double get _fiat =>
      (widget.token['fiat'] as double? ?? 0.0);

  @override
  void initState() {
    super.initState();
    // демо-история
    txHistory = [
      {
        'type': 'in',
        'amount': 125.5,
        'fiat': 125.5,
        'status': 'success',
        'date': '19.11.2025 · 12:30',
      },
      {
        'type': 'out',
        'amount': 50.0,
        'fiat': 50.0,
        'status': 'success',
        'date': '18.11.2025 · 21:05',
      },
      {
        'type': 'in',
        'amount': 10.0,
        'fiat': 10.0,
        'status': 'pending',
        'date': '17.11.2025 · 09:12',
      },
      {
        'type': 'out',
        'amount': 5.25,
        'fiat': 5.25,
        'status': 'failed',
        'date': '15.11.2025 · 18:40',
      },
    ];
  }

  Widget _buildTxRow(Map<String, dynamic> tx) {
    final bool isIn = tx['type'] == 'in';
    final double amount = tx['amount'] as double? ?? 0.0;
    final double fiat = tx['fiat'] as double? ?? 0.0;
    final String status = tx['status']?.toString() ?? '';
    final String date = tx['date']?.toString() ?? '';

    final Color color =
        isIn ? Colors.greenAccent : Colors.redAccent;

    Color statusColor;
    switch (status) {
      case 'success':
        statusColor = Colors.greenAccent;
        break;
      case 'failed':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.orangeAccent;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          isIn ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        '${isIn ? '+' : '-'}${amount.toStringAsFixed(4)} $_symbol',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '≈ ${fiat.toStringAsFixed(2)} USD',
            style: const TextStyle(
                fontSize: 12, color: Colors.white70),
          ),
          Text(
            date,
            style: const TextStyle(
                fontSize: 11, color: Colors.white60),
          ),
          Text(
            status == 'success'
                ? 'Успешно'
                : status == 'failed'
                    ? 'Отклонено'
                    : 'В ожидании',
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSend() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendTokenScreen(token: widget.token),
      ),
    );
    // после возвращения обновим данные
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openReceive() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ReceiveTokenScreen(token: widget.token),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        title: Text('$_name ($_symbol)'),
      ),
      body: Container(
        color: AppColors.backgroundDark,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // карточка баланса токена
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Баланс',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _balance.toStringAsFixed(6),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${_fiat.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Сеть: $_network',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // кнопки Отправить / Получить
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openSend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text('Отправить'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openReceive,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.accent
                              .withOpacity(0.6),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                      icon:
                          const Icon(Icons.arrow_downward),
                      label: const Text(
                        'Получить',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'История транзакций',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: txHistory.isEmpty
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Пока нет транзакций',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white70),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: ListView.separated(
                          itemCount: txHistory.length,
                          separatorBuilder:
                              (context, index) =>
                                  const Divider(
                            height: 1,
                            color: Color(0xFF1F2937),
                          ),
                          itemBuilder: (context, index) {
                            final tx = txHistory[index];
                            return _buildTxRow(tx);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

