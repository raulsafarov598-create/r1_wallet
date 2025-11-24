import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0A84FF);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ---- Баланс ----
              const Text(
                'Баланс',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '€12,540.20',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              // ---- Кнопки действий ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  actionButton(Icons.south_west, 'Получить'),
                  actionButton(Icons.north_east, 'Отправить'),
                  actionButton(Icons.sync_alt, 'Swap'),
                ],
              ),

              const SizedBox(height: 30),

              // ---- Список монет ----
              const Text(
                'Активы',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: ListView(
                  children: const [
                    CoinTile(
                      name: 'Bitcoin',
                      symbol: 'BTC',
                      amount: '0.0312 BTC',
                      value: '€1,850',
                    ),
                    CoinTile(
                      name: 'Ethereum',
                      symbol: 'ETH',
                      amount: '0.42 ETH',
                      value: '€1,100',
                    ),
                    CoinTile(
                      name: 'Solana',
                      symbol: 'SOL',
                      amount: '12.4 SOL',
                      value: '€1,300',
                    ),
                    CoinTile(
                      name: 'Tether',
                      symbol: 'USDT',
                      amount: '5,920 USDT',
                      value: '€5,890',
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---- Кнопка действий ----
  Widget actionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          height: 62,
          width: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade900,
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

// ---- Плитка монеты ----
class CoinTile extends StatelessWidget {
  final String name;
  final String symbol;
  final String amount;
  final String value;

  const CoinTile({
    super.key,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade900,
                child: Text(
                  symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

