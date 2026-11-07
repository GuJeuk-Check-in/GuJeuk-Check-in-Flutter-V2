import 'package:flutter/painting.dart';

/// Figma 화면 배치용 크기·간격 (한 화면에서만 쓰는 값)
abstract final class BubdongLayout {
  // 이용대장 선택 화면 (Figma 사이트 흐름 10장 카드 화면)
  static const double facilityGridWidth = 1340; // 카드 4장 줄 너비
  static const double facilityGridRowGap = 60; // 카드 줄 사이
  static const double facilityGridToSummaryGap = 168; // 카드 목록과 선택 요약 글자 사이
  static const double facilitySummaryToButtonGap = 56; // 선택 요약 글자와 버튼 줄 사이

  // 시설 카드 (Figma 305×188, 너비는 부모를 채움)
  static const double facilityCardHeight = 188;
  static const double facilityCardIconSize = 128; // 체크·손 그림

  // 드롭다운 목록 구분선 길이
  static const double dropdownDividerWidth = 100;

  // 학교 검색 팝업 너비 (Figma A15)
  static const double schoolSearchDialogWidth = 700;

  // 버튼 줄이 차지하는 최대 너비
  static const double homeActionRowWidth = 1240;
  static const double actionRowWidth = 680; // 이전/다음 버튼 줄

  // 홈
  static const double homeLogoGap = 109; // 로고와 안내 글자 사이

  // 회원가입 공통
  static const double signupStepGap = 111; // 단계 표시끼리 사이
  static const double signupStepLabelGap = 13; // 단계 번호와 단계 이름 사이
  static const signupCardPadding = EdgeInsets.fromLTRB(60, 40, 60, 180); // 추가정보 카드 안쪽 여백
  static const signupConsentCardPadding = EdgeInsets.fromLTRB(60, 40, 60, 80); // 동의 카드 안쪽 여백

  // 동의 화면 (Figma 프레임 9)
  static const double consentContentHeight = 296; // 펼친 조항 내용 영역 높이

  // 회원가입 1단계 (기본 정보)
  static const double signupBasicHeaderGap = 37; // 헤더와 카드 사이
  static const double signupBasicButtonGap = 100; // 입력칸과 다음 버튼 사이

  // 회원가입 2단계 두 번째 화면
  static const double signupSchoolGradeGap = 66; // 학교 검색 버튼과 학년 칸 사이
  static const double signupAddressGap = 54; // 주소 칸과 방문 경로 사이
}
