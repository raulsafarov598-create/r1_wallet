import 'package:flutter/material.dart';
import '../theme.dart';

class P2PCreateOfferScreen extends StatefulWidget {
  const P2PCreateOfferScreen({super.key});

  @override
  State<P2PCreateOfferScreen> createState() => _P2PCreateOfferScreenState();
}

class _P2PCreateOfferScreenState extends State<P2PCreateOfferScreen> {
  int _buySellIndex = 0; // 0 купить, 1 продать
  String _asset = 'USDT';
  String _fiat = 'EUR';

  final _priceController = TextEditingController();
  final _availableController = TextEditingController();
  final _minFiatController = TextEditingController();
  final _maxFiatController = TextEditingController();

  final Set<String> _payments = {'SEPA'};
  bool _active = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _priceController.dispose();
    _availableController.dispose();
    _minFiatController.dispose();
    _maxFiatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = _buySellIndex == 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        title: const Text('Создать объявление'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBuySellToggle(),
              const SizedBox(height: 16),
              _buildDropdownRow(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: 'Цена за 1 $_asset ($_fiat)',
                hint: 'Например, 0.95',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _availableController,
                label: 'Доступно ($_asset)',
                hint: 'Например, 1000',
              ),
              const SizedBox(height: 16),
               Text(
  'Лимиты ($_fiat)',
  style: const TextStyle(color: Colors.white70, fontSize: 13),
),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _minFiatController,
                      label: 'Минимум',
                      hint: 'Например, 50',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _maxFiatController,
                      label: 'Максимум',
                      hint: 'Например, 1500',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Способы оплаты',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildPaymentChip('SEPA'),
                  _buildPaymentChip('Bank Transfer'),
                  _buildPaymentChip('Revolut'),
                  _buildPaymentChip('Wise'),
                  _buildPaymentChip('Cash'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Switch(
                    value: _active,
                    activeColor: AppColors.accent,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Активное объявление',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    isBuy ? 'Создать: покупаю $_asset' : 'Создать: продаю $_asset',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuySellToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _buySellIndex = 0),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color:
                    _buySellIndex == 0 ? AppColors.accent : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                'Купить',
                style: TextStyle(
                  color: _buySellIndex == 0 ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _buySellIndex = 1),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color:
                    _buySellIndex == 1 ? AppColors.accent : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                'Продать',
                style: TextStyle(
                  color: _buySellIndex == 1 ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Актив',
            value: _asset,
            items: const ['USDT', 'BTC', 'ETH'],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _asset = v);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            label: 'Фиат',
            value: _fiat,
            items: const ['EUR', 'USD', 'UAH'],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _fiat = v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.cardDark,
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              style: const TextStyle(color: Colors.white),
              onChanged: onChanged,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Заполни поле';
            }
            if (double.tryParse(value.replaceAll(',', '.')) == null) {
              return 'Нужно число';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            filled: true,
            fillColor: AppColors.cardDark,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: Colors.white24, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: Colors.white24, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: Colors.white54, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentChip(String label) {
    final selected = _payments.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      backgroundColor: AppColors.surfaceDark,
      selectedColor: AppColors.accent.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
      ),
      onSelected: (v) {
        setState(() {
          if (v) {
            _payments.add(label);
          } else {
            _payments.remove(label);
          }
        });
      },
    );
  }

  void _saveOffer() {
    if (!_formKey.currentState!.validate()) return;

    double parse(String s) =>
        double.parse(s.replaceAll(',', '.').trim());

    final offer = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'side': _buySellIndex == 0 ? 'buy' : 'sell',
      'asset': _asset,
      'fiat': _fiat,
      'price': parse(_priceController.text),
      'available': parse(_availableController.text),
      'minFiat': parse(_minFiatController.text),
      'maxFiat': parse(_maxFiatController.text),
      'payments': _payments.toList(),
      'active': _active,
    };

    Navigator.of(context).pop(offer);
  }
}

