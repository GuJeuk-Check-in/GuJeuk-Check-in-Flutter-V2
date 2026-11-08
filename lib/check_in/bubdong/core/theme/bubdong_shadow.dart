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
}