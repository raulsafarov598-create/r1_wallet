// lib/screens/send_token_screen.dart

import 'package:flutter/material.dart';
import '../theme.dart';

class SendTokenScreen extends StatefulWidget {
  final Map<String, dynamic> token;

  const SendTokenScreen({super.key, required this.token});

  @override
  State<SendTokenScreen> createState() => _SendTokenScreenState();
}

class _SendTokenScreenState extends State<SendTokenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isSending = false;
  String? _errorText;

  String get _symbol =>
      (widget.token['symbol'] ?? '').toString().toUpperCase();
  String get _name => widget.token['name']?.toString() ?? '';
  String get _network => widget.token['network']?.toString() ?? '';

  double get _balance =>
      (widget.token['balance'] as double? ?? 0.0);

  void _setMax() {
    _amountController.text = _balance.toStringAsFixed(6);
    setState(() {
      _errorText = null;
    });
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final text = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(text) ?? 0.0;

    if (amount <= 0) {
      setState(() {
        _errorText = 'Введите сумму больше 0';
      });
      return;
    }

    if (amount > _balance) {
      setState(() {
        _errorText = 'Недостаточно средств';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _errorText = null;
    });

    // имитация запроса
    await Future.delayed(const Duration(milliseconds: 800));

    // обновляем демо-баланс и фиат 1:1
    final double oldFiat =
        (widget.token['fiat'] as double? ?? 0.0);

    setState(() {
      widget.token['balance'] = _balance - amount;
      widget.token['fiat'] = (oldFiat - amount).clamp(0.0, 99999999.0);
      _isSending = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Отправлено $amount $_symbol (демо)',
        ),
      ),
    );

    Navigator.of(context).pop(); // вернуться к предыдущему экрану
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        title: Text('Отправить $_symbol'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // карточка баланса
              Container(
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
                      _name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Сеть: $_network',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Баланс',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_balance.toStringAsFixed(6)} $_symbol',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // адрес
              const Text(
                'Адрес получателя',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Вставь адрес',
                  hintStyle:
                      const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Адрес обязателен';
                  }
                  if (value.trim().length < 10) {
                    return 'Слишком короткий адрес';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // сумма
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Сумма',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Доступно: см. выше',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType
                            .numberWithOptions(
                                decimal: true),
                        style: const TextStyle(
                            color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '0.0',
                          hintStyle: TextStyle(
                              color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Укажи сумму';
                          }
                          final text = value
                              .replaceAll(',', '.');
                          final amount =
                              double.tryParse(text);
                          if (amount == null) {
                            return 'Неверный формат';
                          }
                          if (amount <= 0) {
                            return 'Сумма должна быть > 0';
                          }
                          if (amount > _balance) {
                            return 'Недостаточно средств';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          setState(() {
                            _errorText = null;
                          });
                        },
                      ),
                    ),
                    Text(
                      _symbol,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _setMax,
                      child: const Text('MAX'),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Отправить (демо)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

