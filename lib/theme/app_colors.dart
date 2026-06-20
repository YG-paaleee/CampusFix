import 'package:flutter/material.dart';

/// Central colour tokens for CampusFix.
///
/// Keeping every colour in one place is what makes the whole app feel like a
/// single, cohesive product instead of a set of separate screens.
class AppColors {
  AppColors._();

  // --- Brand (Palawan State University green) ---
  static const Color brand = Color(0xFF114B3A);
  static const Color brandDark = Color(0xFF0B3A2D);
  static const Color accent = Color(0xFF0D7C66);
  static const Color brandSoft = Color(0xFFEAF2EE); // light green tint

  // --- Neutrals ---
  static const Color ink = Color(0xFF17211C); // primary text
  static const Color inkSoft = Color(0xFF5B6B62); // secondary text
  static const Color surface = Colors.white;
  static const Color canvas = Color(0xFFF1F5F2); // page background
  static const Color border = Color(0xFFE3E9E4);

  // --- Status colours (foreground + soft background) ---
  static const Color statusSubmitted = Color(0xFF1769AA);
  static const Color statusSubmittedBg = Color(0xFFE7F0F8);
  static const Color statusInProgress = Color(0xFFB26A00);
  static const Color statusInProgressBg = Color(0xFFFBF0DC);
  static const Color statusResolved = Color(0xFF2F7D32);
  static const Color statusResolvedBg = Color(0xFFE7F2E7);
  static const Color statusRejected = Color(0xFFC62828);
  static const Color statusRejectedBg = Color(0xFFFBE7E7);

  // --- Urgency colours ---
  static const Color urgencyHigh = Color(0xFFC62828);
  static const Color urgencyHighBg = Color(0xFFFBE7E7);
  static const Color urgencyMedium = Color(0xFFB26A00);
  static const Color urgencyMediumBg = Color(0xFFFBF0DC);
  static const Color urgencyLow = Color(0xFF2F7D32);
  static const Color urgencyLowBg = Color(0xFFE7F2E7);
}
