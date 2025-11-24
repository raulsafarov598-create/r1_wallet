import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Детальный экран P2P-сделки.
/// Сюда попадаем, когда кликаем по офферу в P2P.
class P2PDealDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> deal;

  const P2PDealDetailsScreen({
    super.key,
    required this.deal,
  });

  @override
  State<P2PDealDetailsScreen> createState() => _P2PDealDetailsScreenState();
}

class _P2PDealDetailsScreenState extends State<P2PDealDetailsScreen> {
  late Map<String, dynamic> _deal;
  late String _status;
  late bool _isUserSelling; // true = ты продаёшь крипту, false = ты покупаешь
  late String _asset;
  late String _fiat;
  late double _price;
  late double _fiatAmount;
  late double _cryptoAmount;
  late String _trader;
  late List<String> _payments;
  late DateTime _createdAt;

  final TextEditingController _myDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deal = Map<String, dynamic>.from(widget.deal);

    _status = (_deal['status'] as String?) ?? 'created';
    _isUserSelling = (_deal['isUserSelling'] as bool?) ?? false;
    _asset = (_deal['asset'] ?? 'USDT').toString();
    _fiat = (_deal['fiat'] ?? 'EUR').toString();
    _price = (_deal['price'] as num?)?.toDouble() ?? 1.0;
    _fiatAmount = (_deal['fiatAmount'] as num?)?.toDouble() ?? 0.0;
    _cryptoAmount = (_deal['cryptoAmount'] as num?)?.toDouble() ?? 0.0;
    _trader = (_deal['trader'] ?? 'Trader').toString();
    _payments =
        (_deal['payments'] as List?)?.map((e) => e.toString()).toList() ?? [];

    final created = _deal['createdAt'];
    if (created is DateTime) {
      _createdAt = created;
    } else {
      _createdAt = DateTime.now();
    }

    final myDetails = (_deal['myDetails'] ?? '').toString();
    _myDetailsController.text = myDetails;
  }

  @override
  void dispose() {
    _myDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        _isUserSelling ? 'Ты ПРОДАЁШЬ $_asset' : 'Ты ПОКУПАЕШЬ $_asset';

    return WillPopScope(
      onWillPop: () async {
        // При выходе возвращаем обновлённую сделку наверх
        Navigator.of(context).pop(_deal);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: Colors.white,
          title: const Text('P2P сделка'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(title),
              const SizedBox(height: 12),
              _buildAmountsCard(),
              const SizedBox(height: 12),
              _buildPaymentsCard(),
              const SizedBox(height: 12),
              _buildCounterpartyDetailsCard(),
              const SizedBox(height: 12),
              _buildMyDetailsCard(),
              const SizedBox(height: 20),
              _buildStatusSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ HEADER ------------------ //

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Левая часть — текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _isUserSelling
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Трейдер: $_trader',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Пара: $_asset / $_fiat · Курс: ${_price.toStringAsFixed(4)} $_fiat',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Создано: ${_formatDate(_createdAt)}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusChip(),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color bg;
    Color fg;
    String text;

    switch (_status) {
      case 'created':
        bg = Colors.blueAccent.withOpacity(0.12);
        fg = Colors.blueAccent;
        text = 'Создана';
        break;
      case 'waiting_payment':
        bg = Colors.orangeAccent.withOpacity(0.12);
        fg = Colors.orangeAccent;
        text = 'Ожидает оплату';
        break;
      case 'paid':
        bg = Colors.purpleAccent.withOpacity(0.12);
        fg = Colors.purpleAccent;
        text = 'Оплачено';
        break;
      case 'completed':
        bg = Colors.greenAccent.withOpacity(0.12);
        fg = Colors.greenAccent;
        text = 'Завершена';
        break;
      case 'cancelled':
        bg = Colors.redAccent.withOpacity(0.12);
        fg = Colors.redAccent;
        text = 'Отменена';
        break;
      default:
        bg = Colors.white10;
        fg = Colors.white70;
        text = _status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ------------------ AMOUNTS ------------------ //

  Widget _buildAmountsCard() {
    final bool isSell = _isUserSelling;
    final String mainLabel = isSell ? 'Ты отдаёшь' : 'Ты платишь';
    final String secondaryLabel = isSell ? 'Получаешь' : 'Получишь';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Сумма сделки',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAmountLine(
                  label: mainLabel,
                  value: isSell
                      ? '${_cryptoAmount.toStringAsFixed(4)} $_asset'
                      : '${_fiatAmount.toStringAsFixed(2)} $_fiat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAmountLine(
                  label: secondaryLabel,
                  value: isSell
                      ? '${_fiatAmount.toStringAsFixed(2)} $_fiat'
                      : '${_cryptoAmount.toStringAsFixed(4)} $_asset',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Курс: 1 $_asset = ${_price.toStringAsFixed(4)} $_fiat',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          if (_deal['minFiat'] != null && _deal['maxFiat'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Лимиты: '
              '${(_deal['minFiat'] as num).toDouble().toStringAsFixed(0)} – '
              '${(_deal['maxFiat'] as num).toDouble().toStringAsFixed(0)} $_fiat',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountLine({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ------------------ PAYMENTS ------------------ //

  Widget _buildPaymentsCard() {
    if (_payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Методы оплаты не указаны',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Методы оплаты',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _payments
                .map(
                  (p) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      p,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ------------------ COUNTERPARTY DETAILS ------------------ //

  Widget _buildCounterpartyDetailsCard() {
    final String details = (_deal['paymentDetails'] ??
            'Реквизиты контрагента (IBAN, имя, банк и т.п.)')
        .toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Реквизиты контрагента',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: details));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Реквизиты скопированы'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: Colors.white70,
                ),
                tooltip: 'Скопировать',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              details,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ MY DETAILS (МОИ РЕКВИЗИТЫ) ------------------ //

  Widget _buildMyDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Мои реквизиты для оплаты',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _myDetailsController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Например: IBAN, имя, банк, комментарий...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (value) {
              _deal['myDetails'] = value;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  final text = _myDetailsController.text.trim();
                  if (text.isEmpty) return;
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Твои реквизиты скопированы'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
                label: const Text(
                  'Скопировать мои реквизиты',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ STATUS SECTION (КНОПКИ СТАТУСОВ) ------------------ //

  Widget _buildStatusSection() {
    final bool isDone =
        _status == 'completed' || _status == 'cancelled';

    String infoText;
    if (_status == 'created') {
      infoText =
          'Шаг 1. Отправь контрагенту свои реквизиты и дождись оплаты/перевода.';
    } else if (_status == 'waiting_payment') {
      infoText = 'Ждём поступления денег от контрагента.';
    } else if (_status == 'paid') {
      infoText =
          'Подтверди, что получил деньги, либо отмени сделку при проблеме.';
    } else if (_status == 'completed') {
      infoText = 'Сделка завершена ✅';
    } else if (_status == 'cancelled') {
      infoText = 'Сделка отменена ❌';
    } else {
      infoText = 'Статус: $_status';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статус сделки',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            infoText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          if (!isDone) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onPaidPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Я оплатил',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onCompletedPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Я получил деньги',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _onCancelPressed,
                child: const Text(
                  'Отменить сделку',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onPaidPressed() {
    setState(() {
      _status = 'paid';
      _deal['status'] = _status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Статус изменён на "Оплачено"')),
    );
  }

  void _onCompletedPressed() {
    setState(() {
      _status = 'completed';
      _deal['status'] = _status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сделка отмечена как завершённая')),
    );
  }

  void _onCancelPressed() {
    setState(() {
      _status = 'cancelled';
      _deal['status'] = _status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сделка отменена')),
    );
  }

  // ------------------ UTILS ------------------ //

  String _formatDate(DateTime dt) {
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }
}

