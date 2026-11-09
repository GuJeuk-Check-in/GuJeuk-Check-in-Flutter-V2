import 'package:flutter/material.dart';

//화면에서는 직접 쓰지않는 변수명
abstract final class BubdongPalette {
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF2E2E32);
  static const inkSoft = Color(0xFF2F2F33);
  static const slate500 = Color(0xFF76767C);

  static const gray0 = Color(0xFF000000);
  static const gray10 = Color(0xFF1A1A1A);
  static const gray20 = Color(0xFF333333);
  static const gray25 = Color(0xFF404040); // Figma gray/30
  static const gray30 = Color(0xFF4D4D4D);
  static const gray40 = Color(0xFF666666);
  static const gray45 = Color(0xFF6A6A6A); // Figma gray/10
  static const gray50 = Color(0xFF808080);
  static const gray60 = Color(0xFF999999);
  static const gray70 = Color(0xFFA3A3A3);
  static const gray80 = Color(0xFFB2B2B2);
  static const gray90 = Color(0xFFB7B7B7);
  static const gray100 = Color(0xFFCCCCCC);

  static const orange500 = Color(0xFFFF9200);
  static const orange700 = Color(0xFFCE7600);
  static const orange900 = Color(0xFF9B4D00);
  static const amber400 = Color(0xFFF5C343);
  static const orange50 = Color(0xFFFFF4E4);
  static const orange100 = Color(0xFFFFE4C2);
  static const orange480 = Color(0xFFFF9000);

  static const red500 = Color(0xFFE8232C);
  static const pink500 = Color(0xFFEF4B75);
  static const blue500 = Color(0xFF2868D8);
  static const teal500 = Color(0xFF00A89D);
  static const yellow200 = Color(0xFFFFDA7E);

  static const red200 = Color(0xFFF79CA0);
  static const pink100 = Color(0xFFF8CBD5);
  static const blue100 = Color(0xFFCBD9F5);
  static const teal200 = Color(0xFFC5DEDB);
  static const teal300 = Color(0xFF91CEB3);

  static const teal50 = Color(0xFFEFF9F8);
  static const blue50 = Color(0xFFE1E6F2);
  static const pink50 = Color(0xFFFAD6DF);
  static const lavender50 = Color(0xFFFBFBFF);
  static const gray150 = Color(0xFFEAEAF0);
  static const stone100 = Color(0xFFE6E3DF); // Figma grey_white_tone
}

abstract final class BubdongColors {
  //메인
  static const brandPrimary = BubdongPalette.orange500;
  static const brandDark = BubdongPalette.orange900;
  static const brandLight = BubdongPalette.amber400;
  static const brandTint = BubdongPalette.orange50;

  //백그라운드
  static const bgPage = BubdongPalette.white;
  static const bgFieldSelected = BubdongPalette.lavender50;
  static const bgDisabled = BubdongPalette.gray100;
  static const bgHighlight = BubdongPalette.orange50;
  static const bgKaraoke = BubdongPalette.teal50;
  static const bgBoardGame = BubdongPalette.blue50;
  static const bgInternet = BubdongPalette.orange50;

  //버튼
  static const actionPrimaryPressed = BubdongPalette.orange700;
  static const actionPrimary = BubdongPalette.orange500;
  static const actionDisabled = BubdongPalette.gray60;

  //텍스트
  static const textPrimary = BubdongPalette.gray0;
  static const textOnAction = BubdongPalette.ink;
  static const textAccent = BubdongPalette.orange500;
  static const textAccentDark = BubdongPalette.orange900;
  static const textPlaceholder = BubdongPalette.gray40;
  static const textEmphasis4 = BubdongPalette.gray40;
  static const textPasswordReset = BubdongPalette.yellow200;
  static const textDisabled = BubdongPalette.gray30;
  static const textSecondary = BubdongPalette.gray45; // 신청 완료 부제, 학교 주소 (Figma #6A6A6A)

  //원컬러, 그림자
  static const decorRed = BubdongPalette.red500;
  static const decorPink = BubdongPalette.pink500;
  static const decorBlue = BubdongPalette.blue500;
  static const decorTeal = BubdongPalette.teal500;
  static const decorYellow = BubdongPalette.yellow200;

  static const decorRedLight = BubdongPalette.red200;
  static const decorPinkLight = BubdongPalette.pink100;
  static const decorBlueLight = BubdongPalette.blue100;
  static const decorTealLight = BubdongPalette.teal200;

  //인풋
  static const borderError = BubdongPalette.red500;
  static const textError = BubdongPalette.red500;
  static const bgFieldDisabled = BubdongPalette.gray40;
  static const textFieldDisabled = BubdongPalette.gray80;

  static const borderCard = BubdongPalette.gray150;

  static final overlay = BubdongPalette.gray0.withValues(alpha: 0.3);

  //팝업창
  static const bgSurface = BubdongPalette.white;
  static const brandSubtle = BubdongPalette.orange50;

  // 지금 단계가 아닌 단계 동그라미
  static const stepInactive = BubdongPalette.gray100;

  // 주황 등 진한 배경 위의 흰 글자
  static const textOnPrimary = BubdongPalette.white;

  // 진입 화면 카드 테두리 (Figma 진입 화면 카드)
  static const homeMenuLedgerBorder = BubdongPalette.orange500; // 이용 대장 조회 (MainColor)
  static const homeMenuChildBorder = BubdongPalette.yellow200; // 아이들 방문 기록 (주황색/yellow)
  static const homeMenuAdultBorder = BubdongPalette.blue500; // 어른 방문 기록 (파랑/blue)

  // 시설·선택 카드 색 묶음 (Figma 시설 카드 Default·Touched)
  // Bg: 기본 배경 / Shadow: 아래 그림자 / Border: 선택됐을 때 테두리 / Accent: 선택 카드 아이콘·테두리
  static const cardOrangeBg = BubdongPalette.orange50;
  static const cardOrangeShadow = BubdongPalette.orange100;
  static const cardOrangeBorder = BubdongPalette.orange480;
  static const cardOrangeAccent = BubdongPalette.orange500;
  static const cardMintBg = BubdongPalette.teal50;
  static const cardMintShadow = BubdongPalette.teal200;
  static const cardMintBorder = BubdongPalette.teal500;
  static const cardMintAccent = BubdongPalette.teal500;
  static const cardBlueBg = BubdongPalette.blue50;
  static const cardBlueShadow = BubdongPalette.blue100; // Figma 스타일 blue_shadow (그림자 창 값 확인 필요)
  static const cardBlueBorder = BubdongPalette.blue500; // Figma 법동/파랑/blue
  static const cardBlueAccent = BubdongPalette.blue500;
  static const cardPinkBg = BubdongPalette.pink50;
  static const cardPinkShadow = BubdongPalette.pink100; // pink_shadow로 추정 (그림자 창 값 확인 필요)
  static const cardPinkBorder = BubdongPalette.pink500; // Figma 법동/핑크/pink (hex 확인 필요)
  static const cardPinkAccent = BubdongPalette.pink500;
  static const cardSelectedBg = BubdongPalette.lavender50; // 선택됐을 때 배경

  // 시설 카드 글자
  static const textCardTitle = BubdongPalette.inkSoft; // 시설 이름
  static const textCardSubtitle = BubdongPalette.slate500; // 신청서 작성
  static const textCardUnavailable = BubdongPalette.gray50; // 남은 시간·자리 없음

  // 시설 카드 상태 (카드 색과 상관없이 고정)
  static const cardUnavailableBg = BubdongPalette.gray100; // 자리 없음
  static const cardCompletedBg = BubdongPalette.teal50; // 이용 완료 배경 (Figma 화면: 민트 카드 배경)
  static const cardCompletedBorder = BubdongPalette.orange500; // 이용 완료 테두리 (Figma 화면: MainColor)
  static const cardCompletedShadow = BubdongPalette.teal200; // 이용 완료 아래 그림자 (Figma 화면: green_shadow)
  static const textCardCompleted = BubdongPalette.orange500; // "이용 완료" 글자 (Figma MainColor)
  static const borderCardCompletedText = BubdongPalette.amber400; // "이용 완료" 글자 외곽선 (Figma F5C343)
  static const cardInUseBg = BubdongPalette.orange50; // 이용 중 배경
  static const cardInUseBorder = BubdongPalette.orange500; // 이용 중 테두리
  static const cardInUseBadgeBg = BubdongPalette.blue500; // 이용 중 뱃지 배경
  static const cardInUseBadgeText = BubdongPalette.blue100; // 이용 중 뱃지 글자

  // 신청서 안내
  static const bgNotice = BubdongPalette.orange50; // 안내 박스 바탕
  static const textNotice = BubdongPalette.orange900; // 안내 박스 글자
  static const textGuide = BubdongPalette.slate500; // 카드 아래 이용 규칙 글자
  static const textFieldLabel = BubdongPalette.gray25; // 입력칸 질문 글자
  static const textSectionTitle = BubdongPalette.inkSoft; // 신청서 카드 안 소제목 (좌석번호)

  // 방명록 리스트 카드
  static const borderGuestbookCard = BubdongPalette.stone100; // 외곽선 (Figma grey_white_tone)
  static const textGuestName = BubdongPalette.inkSoft; // 이름 (Figma #2F2F33)
  // 학교 검색 팝업
  static const borderSearchField = BubdongPalette.gray0; // 검색칸 테두리 (Figma #000000)
  static const borderSchoolResult = BubdongPalette.gray45; // 결과 기본 테두리 (Figma color/grey/42 #6A6A6A)
  static const textDialogLabel = BubdongPalette.inkSoft; // "학교 이름" (Figma #2F2F33)
  static const textResultCount = BubdongPalette.slate500; // "검색 결과 N개" (Figma #76767C)
  static const textCaption = BubdongPalette.gray50; // "선택한 이용대장", "이용한 시간" (Figma 법동/grey/50 #808080)

  // 자동 저장 토스트 (방명록에서 들어간 이용대장 선택)
  static const toastAutoSaveBg = BubdongPalette.orange50; // Figma Main_soft
  static const toastAutoSaveTitle = BubdongPalette.orange900; // "자동 저장까지", "3초" (Figma Main_dark)
  static const toastAutoSaveBody = BubdongPalette.gray40; // 설명 글자 (Figma 법동/grey/40 #666666)
  static const toastAutoSaveProgress = BubdongPalette.orange500; // 남은 시간 줄 (Figma MainColor)
  static const toastSavedBg = BubdongPalette.teal200; // 배경 (Figma 법동/초록/green_shadow #C5DEDB)
  static const toastSavedBorder = BubdongPalette.teal500; // 테두리 (Figma 법동/초록/green #00A89D)
  static const toastSavedTitle = BubdongPalette.teal500; // "저장됨" (Figma green #00A89D)
  static const toastSavedBody = BubdongPalette.gray0; // "이제 가서 놀아도 돼!" (Figma grey/0)

  // 드롭다운 목록 항목 사이 구분선 (Figma: #CCCCCC 위에 검정 20%)
  static const dividerDropdown = BubdongPalette.gray70;
}