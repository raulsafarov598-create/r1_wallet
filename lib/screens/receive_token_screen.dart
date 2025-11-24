import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceiveTokenScreen extends StatelessWidget {
  final Map<String, dynamic> token;

  const ReceiveTokenScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final String name = token['name'] ?? '';
    final String symbol = token['symbol'] ?? '';
    final String network = token['network'] ?? '';

    // Если адреса нет в map — делаем демо-адрес, чтобы всё работало
    final String address =
        (token['address'] as String?) ??
        '_demo_${symbol.toLowerCase()}_${network.toLowerCase()}_wallet_address';

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050816),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Получить $symbol',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Заголовок монеты
            Text(
              '$name ($symbol)',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Сеть: $network',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),

            // QR-код (через внешний сервис, без лишних пакетов)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=230x230&data=$address',
                width: 230,
                height: 230,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Адрес для получения:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            // ТЁМНОЕ ПОЛЕ С АДРЕСОМ — БЕЛЫЙ ТЕКСТ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF374151)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        address,
                        style: const TextStyle(
                          color: Colors.white, // видно на тёмном фоне
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Адрес скопирован'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Отправляйте только этот токен и только в этой сети.\nИначе средства могут быть потеряны.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

