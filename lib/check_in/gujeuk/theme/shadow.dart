import 'package:flutter/painting.dart';

/// Figma `App/Shadow`, `App/Glow` 이펙트.
/// 3D 그림자(블러 0, 아래로 6~10px)가 이 앱의 기본 입체 표현입니다.
abstract final class GujeukShadows {
  // 3D Blue
  static const blue3d10 = [
    BoxShadow(color: Color(0x330F50A0), offset: Offset(0, 10)),
  ];
  static const blue3d8 = [
    BoxShadow(color: Color(0x330F50A0), offset: Offset(0, 8)),
  ];
  static const blue3d6 = [
    BoxShadow(color: Color(0x330F50A0), offset: Offset(0, 6)),
  ];
  static const blue3dSoft = [
    BoxShadow(color: Color(0x1A0F50A0), offset: Offset(0, 10)),
  ];
  static const blue3dStrong = [
    BoxShadow(color: Color(0x660F50A0), offset: Offset(0, 10)),
  ];
  static const navy3dPressed = [
    BoxShadow(color: Color(0x59093469), offset: Offset(0, 8)),
  ];

  // 3D 강조색
  static const orange3d = [
    BoxShadow(color: Color(0x33F57F17), offset: Offset(0, 10)),
  ];
  static const orange3dStrong = [
    BoxShadow(color: Color(0x66F57F17), offset: Offset(0, 10)),
  ];
  static const teal3d = [
    BoxShadow(color: Color(0x3300695C), offset: Offset(0, 10)),
  ];
  static const teal3dStrong = [
    BoxShadow(color: Color(0x6600695C), offset: Offset(0, 10)),
  ];
  static const indigo3d = [
    BoxShadow(color: Color(0x330D47A1), offset: Offset(0, 10)),
  ];
  static const indigo3dStrong = [
    BoxShadow(color: Color(0x660D47A1), offset: Offset(0, 10)),
  ];
  static const rose3d = [
    BoxShadow(color: Color(0x33F43F5E), offset: Offset(0, 10)),
  ];
  static const rose3dStrong = [
    BoxShadow(color: Color(0x66F43F5E), offset: Offset(0, 10)),
  ];

  // Elevation
  static const card = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 25), blurRadius: 50),
  ];
  static const modal = [
    BoxShadow(color: Color(0x40000000), blurRadius: 20),
  ];

  // Glow
  static const glowSky = [
    BoxShadow(color: Color(0x803AB9FF), blurRadius: 20),
  ];
  static const glowSkySoft = [
    BoxShadow(color: Color(0x593AB9FF), blurRadius: 20),
  ];

  /// 텍스트용 글로우. `TextStyle(shadows: GujeukShadows.glowText)`로 사용합니다.
  static const glowText = [
    Shadow(color: Color(0x800972B8), offset: Offset(0, 2), blurRadius: 4),
  ];
}
