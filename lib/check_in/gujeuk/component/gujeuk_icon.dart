import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma `Icon/*` 컴포넌트. 색은 SVG에 토큰 색으로 들어가 있습니다.
enum GujeukIcons {
  arrowLeft('arrow_left', 24),
  rocket('rocket', 22),
  user('user', 16),
  phone('phone', 18),
  gender('gender', 24),
  boy('boy', 26),
  girl('girl', 30),
  cake('cake', 20),
  ageBaby('age_baby', 20),
  ageKid('age_kid', 24),
  ageTeen('age_teen', 28),
  ageYouth('age_youth', 22),
  ageAdult('age_adult', 22),
  home('home', 18),
  search('search', 24),
  friends('friends', 24),
  minus('minus', 16),
  plus('plus', 16),
  party('party', 34),
  wave('wave', 42),
  checkCircle('check_circle', 72),
  clock('clock', 20),

  /// 선택된 [GujeukGenderToggle]에 쓰는 흰색 아이콘
  boyInverse('boy_inverse', 26),
  girlInverse('girl_inverse', 30),

  /// [GujeukInput] 오른쪽 아이콘 (거주지 검색)
  inputTrailing('input_trailing', 24);

  const GujeukIcons(this._file, this.size);

  final String _file;

  /// Figma에 정의된 아이콘 크기
  final double size;

  String get assetPath => 'assets/icons/gujeuk/$_file.svg';
}

class GujeukIcon extends StatelessWidget {
  final GujeukIcons icon;
  const GujeukIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.assetPath,
      width: icon.size,
      height: icon.size,
    );
  }
}
