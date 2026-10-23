import 'package:flutter/painting.dart';

/// Figma `App/Radius` 토큰.
abstract final class GujeukRadius {
  static const double xs = 5;
  static const double md = 20;
  static const double lg = 32;
  static const double xl = 48;
  static const double xxl = 55;
  static const double full = 9999;

  static const xsAll = BorderRadius.all(Radius.circular(xs));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
  static const xlAll = BorderRadius.all(Radius.circular(xl));
  static const xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const fullAll = BorderRadius.all(Radius.circular(full));
}
