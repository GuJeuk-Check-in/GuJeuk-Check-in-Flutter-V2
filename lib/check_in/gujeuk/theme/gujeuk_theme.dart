import 'package:flutter/material.dart';

import 'color.dart';
import 'typography.dart';

export 'color.dart';
export 'radius.dart';
export 'shadow.dart';
export 'spacing.dart';
export 'typography.dart';

/// 구즉 앱 [ThemeData]. 화면에서는 이 파일 하나만 import 하면 모든 토큰을 쓸 수 있습니다.
abstract final class GujeukTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: GujeukTypography.pretendard,
    scaffoldBackgroundColor: GujeukColors.bgPage,
    colorScheme: ColorScheme.fromSeed(
      seedColor: GujeukColors.actionPrimary,
      primary: GujeukColors.actionPrimary,
      onPrimary: GujeukColors.actionOnPrimary,
      surface: GujeukColors.bgSurface,
      onSurface: GujeukColors.textPrimary,
    ),
  );
}
