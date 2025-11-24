import 'package:flutter/material.dart';
import '../theme.dart';

class P2PDealsHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> deals;

  const P2PDealsHistoryScreen({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        title: const Text('Мои сделки P2P'),
      ),
      body: deals.isEmpty
          ? const Center(
              child: Text(
                'Пока нет сделок',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final d = deals[index];
                final bool isUserBuying = d['isUserBuying'] == true;
                final String asset = d['asset'];
                final String fiat = d['fiat'];
                final double fiatAmount =
                    (d['fiatAmount'] as num).toDouble();
                final double cryptoAmount =
                    (d['cryptoAmount'] as num).toDouble();
                final double price = (d['price'] as num).toDouble();
                final String trader = d['trader'];
                final String status = d['status'] ?? 'created';
                final DateTime createdAt = d['createdAt'] as DateTime;

                String statusLabel;
                Color statusColor;
                switch (status) {
                  case 'paid':
                    statusLabel = 'Оплачено';
                    statusColor = Colors.blueAccent;
                    break;
                  case 'finished':
                    statusLabel = 'Завершено';
                    statusColor = Colors.greenAccent;
                    break;
                  case 'cancelled':
                    statusLabel = 'Отменено';
                    statusColor = Colors.redAccent;
                    break;
                  default:
                    statusLabel = 'Создана';
                    statusColor = Colors.orangeAccent;
                }

                final directionText =
                    isUserBuying ? 'Ты покупаешь $asset' : 'Ты продаёшь $asset';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              directionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Контрагент: $trader',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        'Сумма: ${fiatAmount.toStringAsFixed(2)} $fiat · ${cryptoAmount.toStringAsFixed(4)} $asset',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        'Цена: ${price.toStringAsFixed(3)} $fiat за 1 $asset',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${createdAt.day.toString().padLeft(2, '0')}.'
                        '${createdAt.month.toString().padLeft(2, '0')}.'
                        '${createdAt.year} · '
                        '${createdAt.hour.toString().padLeft(2, '0')}:'
                        '${createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

