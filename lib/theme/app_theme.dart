// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Centralized design tokens: colors, typography, radii.
class AppColors {
  // Dark
  static const Color black = Color(0xFF111111);
  static const Color unreadyGrey = Color(0xFF535353);
  static const Color darkGrey = Color(0xFF353535);

  // Bright
  static const Color white = Color(0xFFFFFFFF);
  static const Color warmGrey = Color(0xFFF1FEEB);
  static const Color selectedWarmGrey = Color(0xFFC9C1B1);
  static const Color lightGrey = Color(0xFFE5E5E5);

  // Primary accent
  static const Color primary = Color(0xFF60BC81);

  // Status
  static const Color openLight = Color(0xFFD4F2DA);
  static const Color openDark = Color(0xFF60BC81);
  static const Color closeLight = Color(0xFFF2D7D4);
  static const Color closeDark = Color(0xFFD3695E);

  // Overlay/back button
  static const Color darkOverlay = Color.fromRGBO(0, 0, 0, 0.45);
}

/// Font families and text styles according to design spec
class AppTextStyles {
  static const String sans = 'InriaSans';
  static const String serif = 'InriaSerif';

  // Title on detail page
  static final TextStyle title = TextStyle(
    fontFamily: serif,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  // Subtitle under title
  static final TextStyle subtitle = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGrey,
  );

  // Button text
  static final TextStyle button = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  // Chip/tag text
  static final TextStyle tag = TextStyle(
    fontFamily: sans,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGrey,
  );

  // Section titles (Type, À propos...)
  static final TextStyle sectionTitle = TextStyle(
    fontFamily: sans,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  // Body text for descriptions
  static final TextStyle body = TextStyle(
    fontFamily: serif,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGrey,
  );
}

/// General theme constants
class AppTheme {
  static const double borderRadius = 8.0;
}
