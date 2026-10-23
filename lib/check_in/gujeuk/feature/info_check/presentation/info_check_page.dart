import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

class InfoCheckPage extends StatefulWidget {
  const InfoCheckPage({super.key});

  @override
  State<InfoCheckPage> createState() => _InfoCheckPageState();
}

class _InfoCheckPageState extends State<InfoCheckPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;

  /// 다이얼로그가 떠 있는 동안 버튼을 다시 눌러도 무시합니다.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String _) {
    if (_nameError != null) setState(() => _nameError = null);
  }

  Future<void> _onNext() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final error = name.isEmpty ? '이름을 적어주세요' : null;
    setState(() => _nameError = error);
    if (error != null) return;

    _isSubmitting = true;
    try {
      final isFirstVisit = await GujeukDialog.show(
        context,
        title: '시설에 혹시 처음 방문했니?',
        description: '정보를 잘못 입력했다면 아니요를 눌러서 이름을 다시 입력 할 수 있어',
      );
      if (!mounted || isFirstVisit != true) return;
      // TODO 다음 화면으로 이동
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 800;
    return BaseScaffold(
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GujeukSpacing.s20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            padding: EdgeInsets.all(
              isNarrow ? GujeukSpacing.s32 : GujeukSpacing.s64,
            ),
            decoration: BoxDecoration(
              color: GujeukColors.bgSurface,
              boxShadow: GujeukShadows.card,
              borderRadius: BorderRadius.circular(GujeukRadius.xl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '반가워! 청소년문화의집에 다시 와줘서 고마워',
                  textAlign: TextAlign.center,
                  style: GujeukTypography.titleLg.copyWith(
                    color: GujeukColors.textBrand,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s12),
                Text(
                  '시설을 이용하려면 작성해줘',
                  textAlign: TextAlign.center,
                  style: GujeukTypography.headingMd.copyWith(
                    color: GujeukColors.textBrand,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: GujeukFieldLabel(
                    label: '이름이 뭐야?',
                    icon: GujeukIcons.user,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s10),
                GujeukInput(
                  hintText: '친구의 이름을 알려줘',
                  controller: _nameController,
                  onChanged: _onNameChanged,
                  errorText: _nameError,
                  maxLength: 30,
                ),
                const SizedBox(height: GujeukSpacing.s40),
                GujeukButton(
                  onPressed: _onNext,
                  label: '넘어가기!  -->',
                  variant: GujeukButtonVariant.primaryLarge,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
