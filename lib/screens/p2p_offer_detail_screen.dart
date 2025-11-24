import 'package:flutter/material.dart';
import '../theme.dart';

/// Модель оффера P2P (общая для Маркета и деталей)
class P2POffer {
  final String id;
  final String traderName;
  final bool isBuying; // true = покупает USDT, false = продаёт USDT
  final String asset;  // USDT, BTC и т.д.
  final String fiat;   // EUR, UAH, PLN...
  final double price;  // цена 1 монеты в фиате
  final String limits; // строка "100 – 1500 EUR"
  final List<String> payments; // ['SEPA', 'Revolut']

  P2POffer({
    required this.id,
    required this.traderName,
    required this.isBuying,
    required this.asset,
    required this.fiat,
    required this.price,
    required this.limits,
    required this.payments,
  });
}

/// Детальный экран оффера "как на Binance"
class P2POfferDetailScreen extends StatefulWidget {
  final P2POffer offer;

  const P2POfferDetailScreen({Key? key, required this.offer}) : super(key: key);

  @override
  State<P2POfferDetailScreen> createState() => _P2POfferDetailScreenState();
}

class _P2POfferDetailScreenState extends State<P2POfferDetailScreen> {
  final TextEditingController _amountFiatController = TextEditingController();
  final TextEditingController _amountCryptoController = TextEditingController();

  // Реквизиты контрагента (демо)
  final String _counterpartyName = 'Raul Safarov';
  final String _counterpartyIban = 'BE12 3456 7890 1234';
  final String _counterpartyBank = 'KBC / SEPA';
  final String _counterpartyNote = 'Payment reference: R1_P2P_1234';

  // Мои реквизиты (демо – в реале потянем из настроек)
  final String _myRequisites = 'Revolut: @raul_r1  |  IBAN: BE98 7654 3210 9876';

  String _status = 'Создано';
  bool _copiedRequisites = false;

  @override
  void dispose() {
    _amountFiatController.dispose();
    _amountCryptoController.dispose();
    super.dispose();
  }

  void _onFiatChanged(String value) {
    final v = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    final crypto = v / widget.offer.price;
    _amountCryptoController.text =
        crypto == 0 ? '' : crypto.toStringAsFixed(4);
    setState(() {});
  }

  void _onCryptoChanged(String value) {
    final v = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    final fiat = v * widget.offer.price;
    _amountFiatController.text =
        fiat == 0 ? '' : fiat.toStringAsFixed(2);
    setState(() {});
  }

  Future<void> _copyText(String text) async {
    // для web/desktop нормальный Clipboard иногда не работает,
    // поэтому просто показываем SnackBar, будто скопировали.
    setState(() {
      _copiedRequisites = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Текст скопирован (демо).'),
      ),
    );
  }

  void _markPaid() {
    setState(() {
      _status = 'Ожидает подтверждения';
    });
  }

  void _markDone() {
    setState(() {
      _status = 'Завершено';
    });
  }

  void _cancelDeal() {
    setState(() {
      _status = 'Отменено';
    });
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          '${offer.isBuying ? 'Продать' : 'Купить'} ${offer.asset}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок с ценой и лимитами
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${offer.isBuying ? 'Покупает' : 'Продаёт'} ${offer.asset}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offer.price.toStringAsFixed(3)} ${offer.fiat} за 1 ${offer.asset}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Лимиты: ${offer.limits}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: offer.payments
                        .map(
                          (p) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              p,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ввод суммы
            const Text(
              'Сумма сделки',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _amountFiatController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onFiatChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Сумма в ${offer.fiat}',
                      labelStyle: const TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  TextField(
                    controller: _amountCryptoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onCryptoChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Сумма в ${offer.asset}',
                      labelStyle: const TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Реквизиты контрагента
            const Text(
              'Реквизиты контрагента',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _reqRow('Имя / получатель', _counterpartyName),
                  const SizedBox(height: 4),
                  _reqRow('IBAN / счёт', _counterpartyIban),
                  const SizedBox(height: 4),
                  _reqRow('Банк / метод', _counterpartyBank),
                  const SizedBox(height: 4),
                  _reqRow('Комментарий к платежу', _counterpartyNote),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _copyText(_counterpartyIban),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Копировать реквизиты',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  if (_copiedRequisites)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Реквизиты скопированы (демо)',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Мои реквизиты (демо)
            const Text(
              'Мои реквизиты (для сохранения в будущем)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _myRequisites,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Статус сделки
            const Text(
              'Статус сделки',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _markPaid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('Я оплатил'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _markDone,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.greenAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Подтвердить завершение',
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelDeal,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Отменить сделку',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _reqRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

