// lib/src/styles/input_styles.dart
import 'package:flutter/material.dart';

class InputStyles {
  static BoxDecoration inputBoxDecoration = BoxDecoration(
    border: Border.all(color: const Color(0xFFCFD4DC)),
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
    boxShadow: const [
      BoxShadow(color: Color(0x0D101828), blurRadius: 2, offset: Offset(0, 1)),
    ],
  );

  static InputDecoration inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: InputBorder.none,
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF667084)),
      suffixIcon: suffixIcon,
    );
  }
}
