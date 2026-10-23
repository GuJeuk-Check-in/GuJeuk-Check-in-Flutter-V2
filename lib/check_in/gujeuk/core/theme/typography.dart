import 'package:flutter/painting.dart';

/// Figma 텍스트 스타일. 색상은 사용하는 곳에서 `copyWith(color: ...)`로 지정합니다.
/// Figma letterSpacing -2.5% → fontSize * -0.025 로 변환했습니다.
abstract final class GujeukTypography {
  static const jua = 'Jua';
  static const pretendard = 'Pretendard';

  /// App/title/header · Jua 72/88 · 첫 화면 큰 제목
  static const titleXl = TextStyle(
    fontFamily: jua,
    fontSize: 72,
    fontWeight: FontWeight.w400,
    height: 88 / 72,
  );

  /// desktop/header/Extrabold · Jua 52/64 · 카드 제목
  static const titleLg = TextStyle(
    fontFamily: jua,
    fontSize: 52,
    fontWeight: FontWeight.w400,
    height: 64 / 52,
  );

  /// App/title/subheader · Jua 40/48 · 보조 제목
  static const titleMd = TextStyle(
    fontFamily: jua,
    fontSize: 40,
    fontWeight: FontWeight.w400,
    height: 48 / 40,
  );

  /// desktop/header/bold · Pretendard SemiBold 40/48 · 첫 화면 안내·CTA 버튼
  static const headingLg = TextStyle(
    fontFamily: pretendard,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 48 / 40,
    letterSpacing: -1.0,
  );

  /// desktop/header/semibold · Pretendard SemiBold 32/36 · 부제목·Primary 버튼·숫자
  static const headingMd = TextStyle(
    fontFamily: pretendard,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 36 / 32,
    letterSpacing: -0.8,
  );

  /// desktop/body/bold · Pretendard Medium 28/36 · 모달 제목
  static const headingSm = TextStyle(
    fontFamily: pretendard,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 36 / 28,
    letterSpacing: -0.7,
  );

  /// desktop/body/medium · Pretendard SemiBold 24/32 · 모달 버튼·시간 슬롯·요약 값
  static const bodyLg = TextStyle(
    fontFamily: pretendard,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.6,
  );

  /// desktop/body/small · Pretendard Regular 20/32 · 필드 라벨·안내 문구
  static const bodyMd = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 32 / 20,
    letterSpacing: -0.5,
  );

  /// App/body/medium · Pretendard Medium 20/22 · 입력값·토글·리스트
  static const bodyMdMedium = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 22 / 20,
    letterSpacing: -0.5,
  );

  /// App/body/small · Pretendard Medium 16/22 · 선택 카드 라벨·모달 설명
  static const bodySm = TextStyle(
    fontFamily: pretendard,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    letterSpacing: -0.4,
  );

  /// App/body/xsmall · Pretendard SemiBold 12/16 · 캡션 (예약 마감)
  static const caption = TextStyle(
    fontFamily: pretendard,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: -0.3,
  );
}
