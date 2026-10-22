import 'package:flutter/material.dart';

import 'color.dart';
import 'typography.dart';

export 'radius.dart';
export 'spacing.dart';
export 'color.dart';
export 'typography.dart';

abstract final class BubdongTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: BubdongTypography.pretendard,
    scaffoldBackgroundColor: BubdongColors.bgPage,
    colorScheme: ColorScheme.fromSeed(
        seedColor: BubdongColors.actionPrimary,
      onPrimary: BubdongColors.actionPrimary,
      onSurface: BubdongColors.textPrimary,
    )
  );
}