import 'package:flutter/material.dart';

// Shared palette
const Color cafeNoir = Color(0xFF4C3D19);
const Color kombuGreen = Color(0xFF354024);
const Color mossGreen = Color(0xFF889063);
const Color tanColor = Color(0xFFCFBB99);
const Color boneColor = Color(0xFFE5D7C4);

class AppColors {
  AppColors._();

  // Align store/category/product UI with admin/profile palette
  static const Color primary = kombuGreen;
  static const Color secondary = mossGreen;
  static const Color surface = tanColor;
  static const Color background = boneColor;
  static const Color accent = cafeNoir;
  static const Color textPrimary = cafeNoir;
  static const Color textSecondary = Color(0xFF6A5A3D);
  static const Color border = Color(0xFFB9AE89);
  static const Color success = mossGreen;
}
