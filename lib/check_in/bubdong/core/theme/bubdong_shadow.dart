import 'package:flutter/painting.dart';

import 'color.dart';

abstract final class BubdongShadow {
  static final inputDefault = BoxShadow(
    color: BubdongPalette.orange500.withValues(alpha: 0.2),
    offset: const Offset(0, 10),
    blurRadius: 0,
    spreadRadius: 0,
  );

  static final inputError = BoxShadow(
    color: BubdongPalette.red500.withValues(alpha: 0.2),
    offset: const Offset(0, 10),
    blurRadius: 0,
    spreadRadius: 0,
  );

  // 큰 주황 버튼 아래 그림자
  static final buttonPrimary = BoxShadow(
    color: BubdongPalette.orange500.withValues(alpha: 0.2),
    offset: const Offset(0, 10),
  );

  // 버튼을 눌렀을 때 주변 빛
  static final buttonGlow = BoxShadow(
    color: BubdongPalette.orange500.withValues(alpha: 0.2),
    blurRadius: 12,
    spreadRadius: 8,
  );

  static final card = BoxShadow(
    color: BubdongPalette.gray0.withValues(alpha: 0.1),
    offset: const Offset(0, 25),
    blurRadius: 50,
  );
}