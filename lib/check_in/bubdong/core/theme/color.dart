import 'package:flutter/material.dart';

//화면에서는 직접 쓰지않는 변수명
abstract final class BubdongPalette {
  static const white = Color(0xFFFFFFFF);

  static const gray0 = Color(0xFF000000);
  static const gray10 = Color(0xFF1A1A1A);
  static const gray20 = Color(0xFF333333);
  static const gray30 = Color(0xFF4D4D4D);
  static const gray40 = Color(0xFF666666);
  static const gray50 = Color(0xFF808080);
  static const gray60 = Color(0xFF999999);
  static const gray70 = Color(0xFFA3A3A3);
  static const gray80 = Color(0xFFB2B2B2);
  static const gray90 = Color(0xFFB7B7B7);
  static const gray100 = Color(0xFFCCCCCC);

  static const orange500 = Color(0xFFFF9200);
  static const orange700 = Color(0xFFC27A2A);
  static const orange900 = Color(0xFF9B4D00);
  static const amber400 = Color(0xFFF5C343);
  static const orange50 = Color(0xFFFFF4E4);

  static const red500 = Color(0xFFE8232C);
  static const pink500 = Color(0xFFEF4B75);
  static const blue500 = Color(0xFF2868D8);
  static const teal500 = Color(0xFF00A89D);
  static const yellow200 = Color(0xFFFFDA7E);

  static const red200 = Color(0xFFF79CA0);
  static const pink100 = Color(0xFFF8CBD5);
  static const blue100 = Color(0xFFCBD9F5);
  static const teal200 = Color(0xFFC5DEDB);

  static const teal50 = Color(0xFFEFF9F8);
  static const blue50 = Color(0xFFE1E6F2);
  static const lavender50 = Color(0xFFFBFBFF);
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

  //텍스트
  static const textPrimary = BubdongPalette.gray0;
  static const textAccent = BubdongPalette.orange500;
  static const textAccentDark = BubdongPalette.orange900;
  static const textPlaceholder = BubdongPalette.gray40;
  static const textEmphasis4 = BubdongPalette.gray40;
  static const textPasswordReset = BubdongPalette.yellow200;
  static const textDisabled = BubdongPalette.gray30;

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
}