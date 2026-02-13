import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00A2E9); // Modern Blue
  static const Color secondary = Color(0xFF00D2B8); // Cyan/Teal
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
