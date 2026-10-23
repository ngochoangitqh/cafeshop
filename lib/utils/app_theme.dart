import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const Color primary = Color(0xFF6E3B20); // Nâu cà phê đậm Highlands
  static const Color primaryDark = Color(0xFF4A2511);
  static const Color background = Color(0xFFFBF8F5); // Be nhạt ấm
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF2D1810);
  static const Color textGrey = Color(0xFF8A7A70);
  static const Color price = Color(0xFF7A3E1D);
  static const Color chipActive = Color(0xFF6E3B20);
  static const Color chipInactive = Color(0xFFF1EAE4);
  static const Color border = Color(0xFFEADBCE);
}

String formatCurrency(num price) {
  final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  return format.format(price).replaceAll(' ', '');
}
