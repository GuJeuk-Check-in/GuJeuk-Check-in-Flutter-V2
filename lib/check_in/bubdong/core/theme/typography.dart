import 'package:flutter/painting.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

abstract final class BubdongTypography{
  static const pretendard = 'Pretendard';
  static const jua = 'Jua';
  //제목
  static const h1 = TextStyle(
    fontFamily: pretendard,
    fontSize: 52,
    fontWeight: FontWeight.w700,
    height: 1.6,
  );

  static const h2 = TextStyle(
    fontFamily: pretendard,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const h3 = TextStyle(
    fontFamily: pretendard,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const h4 = TextStyle(
    fontFamily: pretendard,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const h5 = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  //바디
  static const bodyLg = TextStyle(
    fontFamily: pretendard,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const bodyMd = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const bodySm = TextStyle(
    fontFamily: pretendard,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  //캡션
  static const caption = TextStyle(
    fontFamily: pretendard,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.6,
  );

  //버튼
  static const button = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const buttonBold = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );
  static const buttonSemibold = TextStyle(
    fontFamily: pretendard,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  //서브 제목
  static const subtitle = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  //라벨
  static const label = TextStyle(
    fontFamily: pretendard,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  //플레이스홀더
  static const placeHolder = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const titleLg = TextStyle(
    fontFamily: jua,
    fontSize: 52,
    fontWeight: FontWeight.w400,
    height: 64 / 52,
  );

  static const headingMd = TextStyle(
    fontFamily: pretendard,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 36 / 32,
    letterSpacing: -0.8,
  );

  // 시설 카드 이름, 진입 화면 카드 문구 (Figma Heading/H3: 32 SemiBold 1.4)
  static const cardTitle = TextStyle(
    fontFamily: pretendard,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0, // 테마 기본 자간(0.25)이 섞이지 않게
  );

  // 이용대장 선택 요약 글자 (Figma 26 Bold, 행간 32)
  static const selectionSummary = TextStyle(
    fontFamily: pretendard,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 32 / 26,
  );

  // 신청서 안내 박스 글자 (Figma 26 Regular, 글상자 높이 31)
  static const notice = TextStyle(
    fontFamily: pretendard,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 31 / 26,
  );

  // 신청서 이용 규칙 글자 (Figma 23 Regular, 글상자 높이 28)
  static const guide = TextStyle(
    fontFamily: pretendard,
    fontSize: 23,
    fontWeight: FontWeight.w400,
    height: 28 / 23,
  );

  // 신청서 카드 안 소제목 (Figma 좌석번호 25 Bold, 글상자 높이 30)
  static const sectionTitle = TextStyle(
    fontFamily: pretendard,
    fontSize: 25,
    fontWeight: FontWeight.w700,
    height: 30 / 25,
  );

  // 입력칸 질문 글자 (Figma Name Field 라벨: 20 Bold, 행간 32, 자간 -0.5, gray/30)
  static const fieldLabel = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 32 / 20,
    letterSpacing: -0.5,
    color: BubdongColors.textFieldLabel,
  );


  /// 작은 칩 글자 (방명록 이용대장 칩)
  static const tagLabel = TextStyle(
    fontFamily: pretendard,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0, // 테마 기본 자간(0.25)이 섞이지 않게
  );

  /// 작은 안내 글자 ("선택한 이용대장", "이용한 시간", Figma 19 Regular 행간 자동)
  static const captionSm = TextStyle(
    fontFamily: pretendard,
    fontSize: 19,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// 강조 숫자 ("1시간 20분", Figma 25 Bold 행간 자동)
  static const valueLg = TextStyle(
    fontFamily: pretendard,
    fontSize: 25,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// 팝업 제목 "학교 검색" (Figma Pretendard 32 Bold 행간 자동)
  static const dialogTitle = TextStyle(
    fontFamily: pretendard,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// 팝업 칸 이름 "학교 이름" (Figma Pretendard 24 Bold 행간 32 자간 -2.5%)
  static const dialogFieldLabel = TextStyle(
    fontFamily: pretendard,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.6,
  );

  /// 팝업 검색칸 글자 (Figma Pretendard SemiBold 20 행간 자동)
  static const dialogInput = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// 검색 결과 개수 (Figma Inter Regular 20 행간 자동 → Pretendard)
  static const resultCount = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// 검색 결과 학교 이름 (Figma Pretendard 24 Bold 행간 140%)
  static const resultTitle = TextStyle(
    fontFamily: pretendard,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0,
  );

  /// 방명록 이름 (Figma 32 Bold 행간 자동)
  static const guestName = TextStyle(
    fontFamily: pretendard,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
}