// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  /// Фон всего приложения (тёмный)
  static const Color backgroundDark = Color(0xFF050816);

  /// Фон для больших блоков / карточек
  static const Color surfaceDark = Color(0xFF0B1120);

  /// Фон для внутренних карточек (кошелёк, своп, история и т.д.)
  static const Color cardDark = Color(0xFF111827);

  /// Фиолетовый акцент (кнопки, активные элементы)
  static const Color accent = Color(0xFF6366F1);

  /// Текст
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;

  /// Статусы
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}

