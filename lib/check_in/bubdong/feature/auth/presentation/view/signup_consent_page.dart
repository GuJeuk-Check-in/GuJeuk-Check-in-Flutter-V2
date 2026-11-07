import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/agree_all_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/consent_article_item.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_action_row.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_card.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_header.dart';

class SignupConsentPage extends StatefulWidget {
  const SignupConsentPage({super.key});

  @override
  State<SignupConsentPage> createState() => _SignupConsentPageState();
}

class _SignupConsentPageState extends State<SignupConsentPage> {
  static const _articles = [
    (
    title: '제 1조 수집하려는 개인정보의 항목',
    content:
    '법동청소년문화센터는 본 시설 및 프로그램 이용에 필요한 정보를 수집하고 있습니다.\n'
        ': 이름, 생년월일, 학교, 학년, 성별, 본인 연락처, 보호자 연락처, 주소\n\n'
        '기본적 인권침해의 우려가 있는 개인정보(인종 및 민족, 사상 및 신조, 출신지 및 본적지, 정치적 성향 및 범죄기록 등)는 '
        '요구하지 않으며, 위의 항목 이외에 다른 어떠한 목적으로도 정보를 수집하거나 목적이외의 용도로 사용하지 않음을 알려드립니다.',
    ),
    (
    title: '제 2조 개인정보의 수집·이용 목적',
    content:
    '법동청소년문화센터는 수집한 개인정보를 다음의 목적을 위해 활용합니다.\n\n'
        '- 회원등록 및 관리 : 해당 회원에 대한 본 시설 및 프로그램 이용 권한 부여, 긴급 상황 발생 시 보호자 연락체계 확립\n'
        '- 정보전달 : 본 시설의 프로그램 및 기타 정보 전달',
    ),
    (
    title: '제 3조 개인정보 보유기간',
    content:
    '수집된 개인정보는 신청일로부터 1년 동안 보관합니다. '
        '매년 회원가입 신청서와 개인정보 수집 및 활용 동의서는 재작성하며, '
        '보유기간이 지난 신청자의 개인정보는 재생이 불가능한 방법으로 파기합니다.',
    ),
  ];

  /// 조항별 동의 (true: 동의함, false: 동의안함, null: 안 고름)
  final _agreements = List<bool?>.filled(3, null);

  /// 펼쳐진 조항 번호 (없으면 null)
  int? _openIndex;

  bool get _allAgreed => _agreements.every((agreed) => agreed == true);

  /// 모두 동의 누름: 전부 동의 ↔ 전부 해제
  void _toggleAll() {
    setState(() {
      final next = _allAgreed ? null : true;
      for (var i = 0; i < _agreements.length; i++) {
        _agreements[i] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SignupHeader(
            title: '개인정보 수집 및 활용 동의',
            subtitle: '조항을 눌러 자세한 내용을 확인해주세요',
            currentStep: 3,
          ),
          const SizedBox(height: BubdongSpacing.s40),
          SignupCard(
            width: 1080,
            padding: BubdongLayout.signupConsentCardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _articles.length; i++) ...[
                  ConsentArticleItem(
                    title: _articles[i].title,
                    content: _articles[i].content,
                    expanded: _openIndex == i,
                    agreed: _agreements[i],
                    onToggle: () => setState(() => _openIndex = _openIndex == i ? null : i),
                    onAgreeChanged: (value) => setState(() => _agreements[i] = value),
                  ),
                  if (i != _articles.length - 1) const SizedBox(height: BubdongSpacing.s16),
                ],
                const SizedBox(height: BubdongSpacing.s48),
                Text(
                  '약관동의',
                  style: BubdongTypography.h4.copyWith(color: BubdongColors.textPrimary),
                ),
                const SizedBox(height: BubdongSpacing.s16),
                AgreeAllBox(checked: _allAgreed, onTap: _toggleAll),
              ],
            ),
          ),
          const SizedBox(height: BubdongSpacing.s64),
          SignupActionRow(
            nextLabel: '동의',
            onPrevious: () => Navigator.of(context).pop(),
            onNext: _allAgreed ? () {} : null, // 전부 동의해야 누를 수 있음
          ),
        ],
      ),
    );
  }
}