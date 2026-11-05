/// 회원 성별
enum Gender {
  male('남자'),
  female('여자');

  const Gender(this.label);

  /// 화면에 보이는 글자
  final String label;
}