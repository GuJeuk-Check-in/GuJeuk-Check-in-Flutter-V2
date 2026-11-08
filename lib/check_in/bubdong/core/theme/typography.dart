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

  // 시설 카드 이름 (Figma Heading/H3: 32 SemiBold 1.4)
  static const cardTitle = TextStyle(
    fontFamily: pretendard,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.4,
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
}