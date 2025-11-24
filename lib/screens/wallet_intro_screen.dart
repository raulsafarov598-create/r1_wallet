import 'package:flutter/material.dart';
import '../seed_phrase_screen.dart';
import 'wallet_screen.dart';

class WalletIntroScreen extends StatelessWidget {
  const WalletIntroScreen({super.key});

  Future<void> _createWallet(BuildContext context) async {
    // показываем сид-фразу
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SeedPhraseScreen(),
      ),
    );

    // после этого кидаем на экран с токенами
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WalletScreen(),
      ),
    );
  }

  Future<void> _restoreWallet(BuildContext context) async {
    // пока тоже ведём на SeedPhraseScreen (потом сделаем другой экран)
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SeedPhraseScreen(),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WalletScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кошелёк'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Кошелёк',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Создайте новый кошелёк или восстановите существующий с помощью seed-фразы.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _createWallet(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                'Создать кошелёк',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _restoreWallet(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                'Восстановить кошелёк',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

