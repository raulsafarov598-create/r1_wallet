import 'package:flutter/material.dart';
import 'services/wallet_secure_storage.dart';

/// Screen for creating and confirming a 4-digit PIN.
class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

enum _PinStep { create, confirm }

class _PinScreenState extends State<PinScreen> {
  _PinStep _step = _PinStep.create;
  String _firstPin = '';
  String _currentPin = '';

  void _onKeyboardTap(String value) {
    if (_currentPin.length >= 4) return;
    setState(() {
      _currentPin += value;
    });

    if (_currentPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 120), _handlePinComplete);
    }
  }

  Future<void> _handlePinComplete() async {
    if (_step == _PinStep.create) {
      setState(() {
        _firstPin = _currentPin;
        _currentPin = '';
        _step = _PinStep.confirm;
      });
      return;
    }

    if (_currentPin == _firstPin) {
      await WalletSecureStorage.savePin(_currentPin);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } else {
      _showError('PIN does not match. Try confirming again.');
      setState(() {
        _currentPin = '';
      });
    }
  }

  void _deleteLast() {
    if (_currentPin.isEmpty) return;
    setState(() {
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
    });
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
      children: List.generate(4, (index) {
        final bool filled = index < _currentPin.length;
        return Container(
          margin: const EdgeInsets.all(10),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.white24,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildKeyboardButton(String number) {
    return InkWell(
      onTap: () => _onKeyboardTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map(_buildKeyboardButton).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 64),
              _buildKeyboardButton('0'),
              InkWell(
                onTap: _deleteLast,
                borderRadius: BorderRadius.circular(40),
                child:
                    const Icon(Icons.backspace, color: Colors.white70, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirm = _step == _PinStep.confirm;

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isConfirm ? 'Confirm your PIN' : 'Create a 4-digit PIN',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isConfirm
                  ? 'Re-enter the PIN to confirm'
                  : 'This will secure your wallet',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 28),
            _buildPinDots(),
            const SizedBox(height: 40),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }
}
