import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/school_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/sign_up_request.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/visit_route.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/school_search_dialog.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/view/signup_consent_page.dart';

class SignupExtraSecondPage extends StatefulWidget {
  const SignupExtraSecondPage({super.key, required this.request});

  final SignUpRequest request; // 앞 화면까지 적은 값

  @override
  State<SignupExtraSecondPage> createState() => _SignupExtraSecondPageState();
}

class _SignupExtraSecondPageState extends State<SignupExtraSecondPage> {
  VisitRoute? _visitRoute;

  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();
  final _addressController = TextEditingController();
  final _otherRouteController = TextEditingController(); // 방문 경로 기타

  List<TextEditingController> get _controllers =>
      [_schoolController, _gradeController, _addressController, _otherRouteController];

  // 칸을 다 채우고 방문 경로를 골라야 다음 (기타면 내용까지)
  bool get _isValid =>
      _schoolController.text.trim().isNotEmpty &&
      _gradeController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _visitRoute != null &&
      (_visitRoute != VisitRoute.other ||
          _otherRouteController.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(() => setState(() {})); // 입력할 때마다 버튼 상태 갱신
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 학교 검색 팝업에서 고른 학교를 학교 칸에 넣음
  SchoolPick? _pickedSchool; // 팝업에서 고른 학교 (종류를 요청에 넣으려고 기억)

  Future<void> _searchSchool() async {
    final school = await SchoolSearchDialog.show(
      context,
      selectedName: _schoolController.text,
    );
    if (school == null) return;
    _pickedSchool = school;
    _schoolController.text = school.name;
    if (school.name == noSchoolName) _gradeController.text = '0'; // 학교 안 다님 → 학년 0
  }

  /// 이 화면에서 적은 값을 요청에 담아 동의 화면으로
  void _next() {
    final school = _schoolController.text.trim();
    final picked = _pickedSchool;
    final request = widget.request.copyWith(
      school: school,
      // 고른 뒤 칸을 직접 고쳤으면 종류를 모르니 보내지 않음
      schoolType: picked?.name == school ? picked?.type : null,
      // 학교 안 다님이면 학년 칸을 고쳤어도 0 (명세: 무교 + 학년 0)
      grade: school == noSchoolName ? 0 : int.parse(_gradeController.text.trim()),
      address: _addressController.text.trim(),
      route: _visitRoute,
      routeDetail: _visitRoute == VisitRoute.other
          ? _otherRouteController.text.trim() // 기타면 직접 적은 내용
          : null,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignupConsentPage(request: request)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SignupHeader(title: '처음 방문하셨나요?', currentStep: 2),
          const SizedBox(height: BubdongSpacing.s40),
          BubdongContentCard(
            width: BubdongLayout.formCardWidth,
            padding: BubdongLayout.signupCardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 줄: 학교 | 학교 검색 | 학년
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 4,
                      child: BubdongInput(
                        label: '학교가 뭐야?',
                        hintText: '친구의 학교를 알려줘',
                        controller: _schoolController,
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s20),
                    BubdongButton(
                      label: '학교 검색',
                      onPressed: _searchSchool,
                      variant: BubdongButtonVariant.outlineSmall,
                    ),
                    const SizedBox(width: BubdongLayout.signupSchoolGradeGap),
                    Expanded(
                      flex: 1,
                      child: BubdongInput(
                        label: '학년이 뭐야?',
                        hintText: '3',
                        suffixText: '학년',
                        controller: _gradeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BubdongSpacing.s40),

                // 주소
                BubdongInput(
                  label: '어디에 살아?',
                  hintText: '주소를 입력해줘',
                  controller: _addressController,
                ),
                const SizedBox(height: BubdongLayout.signupAddressGap),

                // 방문 경로
                Text('문화 센터를 어떻게 알게 되었어?', style: BubdongTypography.fieldLabel),
                const SizedBox(height: BubdongSpacing.s24),
                Row(
                  children: [
                    Expanded(
                      child: BubdongSelectCard(
                        label: VisitRoute.friend.label,
                        icon: Icons.people_outline,
                        color: BubdongCardColor.orange,
                        selected: _visitRoute == VisitRoute.friend,
                        onTap: () =>
                            setState(() => _visitRoute = VisitRoute.friend),
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s20),
                    Expanded(
                      child: BubdongSelectCard(
                        label: VisitRoute.parent.label,
                        icon: Icons.family_restroom,
                        color: BubdongCardColor.mint,
                        selected: _visitRoute == VisitRoute.parent,
                        onTap: () =>
                            setState(() => _visitRoute = VisitRoute.parent),
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s20),
                    Expanded(
                      child: BubdongSelectCard(
                        label: VisitRoute.other.label,
                        icon: Icons.edit,
                        color: BubdongCardColor.blue,
                        selected: _visitRoute == VisitRoute.other,
                        onTap: () =>
                            setState(() => _visitRoute = VisitRoute.other),
                      ),
                    ),
                  ],
                ),

                // 기타를 골랐을 때만 보이는 입력칸
                if (_visitRoute == VisitRoute.other) ...[
                  const SizedBox(height: BubdongSpacing.s40),
                  BubdongInput(
                    label: '기타 (어떻게 알게 됐어?)',
                    hintText: '기타',
                    controller: _otherRouteController,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: BubdongSpacing.s64),
          BubdongActionRow(
            onPrevious: () => Navigator.of(context).pop(),
            onNext: _isValid ? _next : null, // 다 채워야 누를 수 있음
          ),
        ],
      ),
    );
  }
}
