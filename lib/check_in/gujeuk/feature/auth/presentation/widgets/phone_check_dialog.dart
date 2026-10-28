import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';

/// 같은 이름의 회원이 있을 때 전화번호로 본인을 확인하는 모달.
/// 화면에 띄울 때는 [PhoneCheckDialog.show]를 사용합니다.
class PhoneCheckDialog extends StatefulWidget {
  /// 처음부터 입력칸 아래에 띄울 에러 (예: 서버에 있는 번호와 다를 때).
  final String? initialError;

  const PhoneCheckDialog({super.key, this.initialError});

  /// 확인 → 입력한 번호(`010-1234-5678`), 바깥을 눌러 닫으면 null.
  /// 다시 입력은 모달을 닫지 않고 입력칸만 비웁니다.
  static Future<String?> show(BuildContext context, {String? errorText}) {
    return showDialog<String>(
      context: context,
      builder: (_) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: PhoneCheckDialog(initialError: errorText),
        ),
      ),
    );
  }

  @override
  State<PhoneCheckDialog> createState() => _PhoneCheckDialogState();
}

class _PhoneCheckDialogState extends State<PhoneCheckDialog> {
  final TextEditingController _phoneController = TextEditingController();
  late String? _phoneError = widget.initialError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String _) {
    if (_phoneError != null) setState(() => _phoneError = null);
  }

  /// 모달은 그대로 두고 입력한 번호와 에러만 비웁니다.
  void _onRetry() {
    _phoneController.clear();
    setState(() => _phoneError = null);
  }

  void _onConfirm() {
    final phone = _phoneController.text;
    final String? error;
    if (PhoneNumberFormatter.digitsOf(phone).isEmpty) {
      error = '전화번호를 적어주세요';
    } else if (!PhoneNumberFormatter.isValid(phone)) {
      error = '전화번호를 다시 확인해주세요';
    } else {
      error = null;
    }
    setState(() => _phoneError = error);
    if (error != null) return;

    Navigator.of(context).pop(phone);
  }

  @override
  Widget build(BuildContext context) {
    return GujeukDialog(
      title: '같은 이름의 친구가 있어!',
      description: '누구인지 알 수 있게 전화번호를 입력해줘',
      icon: GujeukIcons.wave,
      cancelLabel: '다시 입력',
      confirmLabel: '확인',
      onCancel: _onRetry,
      onConfirm: _onConfirm,
      child: GujeukInput(
        hintText: '전화번호를 입력해주세요',
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: const [PhoneNumberFormatter()],
        onChanged: _onPhoneChanged,
        errorText: _phoneError,
      ),
    );
  }
}
