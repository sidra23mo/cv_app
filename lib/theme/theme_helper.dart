// lib/theme/theme_helper.dart
import 'package:flutter/material.dart';

class ThemeHelper {
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0F0F0F)
        : Colors.white;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1A1A1A)
        : Colors.white;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF5F5F5)
        : const Color(0xFF1E1E1E);
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF5A5A5A);
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8ECF1);
  }

  static Color getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF242424)
        : const Color(0xFFE8F0FE);
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD0D0D0)
        : const Color(0xFF1A2B4C);
  }

  static Color getButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF5B7FC8)
        : const Color(0xFF1A2B4C);
  }

  static Color getButtonTextColor(BuildContext context) {
    return Colors.white;
  }

  static Color getAccentColor(BuildContext context) {
    return const Color(0xFFF4C542);
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
