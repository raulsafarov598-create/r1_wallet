import 'package:flutter/material.dart';
import '../services/wallet_secure_storage.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  // Режим: создаём PIN или вводим существующий
  bool _isCreateMode = true;

  // Первый ввод PIN при создании
  String _firstPin = '';

  // Текущий вводимый PIN
  String _currentPin = '';

  @override
  void initState() {
    super.initState();
    _initMode();
  }

  Future<void> _initMode() async {
    bool hasPin = await WalletSecureStorage.hasPin();
    setState(() {
      _isCreateMode = !hasPin; // если PIN есть → вход, если нет → создание
    });
  }

  void _onKeyboardTap(String value) {
    setState(() {
      if (_currentPin.length < 4) {
        _currentPin += value;
      }
    });

    if (_currentPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _handlePinComplete);
    }
  }

  void _handlePinComplete() async {
    if (_isCreateMode) {
      // СОЗДАНИЕ PIN — 1 шаг
      if (_firstPin.isEmpty) {
        setState(() {
          _firstPin = _currentPin;
          _currentPin = '';
        });
        return;
      }

      // СОЗДАНИЕ PIN — подтверждение
      if (_currentPin == _firstPin) {
        await WalletSecureStorage.savePin(_currentPin);

        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        setState(() {
          _currentPin = '';
          _firstPin = '';
        });
        _showError('PIN не совпадает, попробуй ещё раз');
      }
    } else {
      // ПРОВЕРКА PIN
      bool ok = await WalletSecureStorage.verifyPin(_currentPin);
      if (ok) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        setState(() => _currentPin = '');
        _showError('Неверный PIN');
      }
    }
  }

  void _deleteLast() {
    if (_currentPin.isNotEmpty) {
      setState(() {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      });
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (i) {
          bool filled = i < _currentPin.length;
          return Container(
            margin: const EdgeInsets.all(10),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: filled ? Colors.white : Colors.white24,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeyboardButton(String number) {
    return InkWell(
      onTap: () => _onKeyboardTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map(_buildKeyboardButton).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60),
            _buildKeyboardButton('0'),
            InkWell(
              onTap: _deleteLast,
              borderRadius: BorderRadius.circular(40),
              child: const Icon(Icons.backspace, color: Colors.white70, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isCreateMode
                  ? (_firstPin.isEmpty ? 'Создай PIN' : 'Повтори PIN')
                  : 'Введите PIN',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildPinDots(),
            const SizedBox(height: 40),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }
}
