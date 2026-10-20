import 'package:flutter/painting.dart';

/// Figma `App/Primitives` 원색 팔레트.
/// 화면에서는 직접 쓰지 말고 [GujeukColors]의 의미 토큰을 사용하세요.
abstract final class GujeukPalette {
  static const white = Color(0xFFFFFFFF);

  static const gray50 = Color(0xFFFBFBFF);
  static const gray100 = Color(0xFFEEEEF2);
  static const gray150 = Color(0xFFEAEAF0);
  static const gray300 = Color(0xFFC8CEDE);
  static const gray400 = Color(0xFFB4B4BC);
  static const gray500 = Color(0xFF96969E);
  static const gray600 = Color(0xFF6A6A6A);
  static const gray800 = Color(0xFF404040);
  static const gray900 = Color(0xFF2E2E32);

  static const slate700 = Color(0xFF323D4A);

  static const blue600 = Color(0xFF3D72B3);
  static const blue900 = Color(0xFF0F50A0);

  static const sky400 = Color(0xFF3AB9FF);
  static const sky500 = Color(0xFF2ABFEC);

  static const teal50 = Color(0xFFE8F5F3);
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF00897B);

  static const orange50 = Color(0xFFFFF3E6);
  static const orange400 = Color(0xFFF97316);
  static const orange500 = Color(0xFFF57F17);

  static const indigo50 = Color(0xFFE8EEF8);
  static const indigo800 = Color(0xFF0D47A1);

  static const rose500 = Color(0xFFF43F5E);
  static const royal600 = Color(0xFF2563EB);
  static const amber500 = Color(0xFFF59E0B);
  static const green600 = Color(0xFF16A34A);
  static const red500 = Color(0xFFE6222C);
  static const purple600 = Color(0xFFA1298C);
  static const yellow400 = Color(0xFFFBBC18);
}

/// Figma `App/Color` 의미 토큰.
abstract final class GujeukColors {
  // Background
  static const bgPage = GujeukPalette.white;
  static const bgSurface = GujeukPalette.white;
  static const bgField = GujeukPalette.gray50;
  static const bgDisabled = GujeukPalette.gray100;
  static const bgNeutral = GujeukPalette.gray100;
  static const bgOverlay = GujeukPalette.slate700;
  static const bgSelected = GujeukPalette.teal50;
  static const bgSelectedOrange = GujeukPalette.orange50;
  static const bgSelectedIndigo = GujeukPalette.indigo50;

  // Action
  static const actionPrimary = GujeukPalette.blue900;
  static const actionLanding = GujeukPalette.sky400;
  static const actionOnPrimary = GujeukPalette.white;
  static const actionMale = GujeukPalette.teal600;
  static const actionFemale = GujeukPalette.rose500;

  // Text
  static const textPrimary = GujeukPalette.gray900;
  static const textSecondary = GujeukPalette.gray800;
  static const textTertiary = GujeukPalette.gray600;
  static const textMuted = GujeukPalette.gray500;
  static const textDisabled = GujeukPalette.gray400;
  static const textBrand = GujeukPalette.blue600;
  static const textInverse = GujeukPalette.white;
  static const textAccent = GujeukPalette.sky500;
  static const textLanding = GujeukPalette.sky400;

  // Icon
  static const iconPrimary = GujeukPalette.gray900;
  static const iconBrand = GujeukPalette.blue600;
  static const iconAction = GujeukPalette.blue900;
  static const iconInverse = GujeukPalette.white;
  static const iconMale = GujeukPalette.teal600;
  static const iconFemale = GujeukPalette.rose500;
  static const iconAge1 = GujeukPalette.orange400;
  static const iconAge2 = GujeukPalette.teal600;
  static const iconAge3 = GujeukPalette.royal600;
  static const iconAge4 = GujeukPalette.amber500;
  static const iconAge5 = GujeukPalette.green600;

  // Border
  static const borderCard = GujeukPalette.gray150;
  static const borderSubtle = GujeukPalette.gray300;
  static const borderSelected = GujeukPalette.teal700;
  static const borderFocus = GujeukPalette.blue600;
  static const borderLanding = GujeukPalette.sky400;
  static const borderAccentOrange = GujeukPalette.orange500;
  static const borderAccentIndigo = GujeukPalette.indigo800;

  // Decoration (배경 도형)
  static const decorNavy = GujeukPalette.blue900;
  static const decorSky = GujeukPalette.sky500;
  static const decorRed = GujeukPalette.red500;
  static const decorPurple = GujeukPalette.purple600;
  static const decorYellow = GujeukPalette.yellow400;

  // List
  static const listSelected = GujeukPalette.blue600;
}
