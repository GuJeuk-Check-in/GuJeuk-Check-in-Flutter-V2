import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// 앱 버전과 지금 실행 중인 Shorebird 패치 번호를 작게 보여 줍니다. 예: v1.0.0 (1) · 패치 2
///
/// 기관에서 업데이트가 반영됐는지 화면만 보고 확인할 수 있게 합니다.
/// 패치는 내려받은 뒤 앱을 다시 켜야 실행되므로, 여기에는 실제로 돌고 있는 패치 번호가 나옵니다.
class AppVersionLabel extends StatefulWidget {
  const AppVersionLabel({super.key});

  @override
  State<AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<AppVersionLabel> {
  /// Flutter가 빌드할 때 pubspec의 version을 넣어 줍니다. 네이티브 플러그인 없이 읽을 수 있습니다.
  static const _buildName = String.fromEnvironment('FLUTTER_BUILD_NAME');
  static const _buildNumber = String.fromEnvironment('FLUTTER_BUILD_NUMBER');

  /// 앱이 켜져 있는 동안 실행 중인 패치는 바뀌지 않으므로 한 번만 읽습니다.
  static final Future<String?> _patchText = _readPatchText();

  static Future<String?> _readPatchText() async {
    final updater = ShorebirdUpdater();
    // shorebird release로 만들지 않은 빌드(flutter run 등)에서는 패치 정보가 없습니다.
    if (!updater.isAvailable) return null;
    try {
      final patch = await updater.readCurrentPatch();
      return patch == null ? '패치 없음' : '패치 ${patch.number}';
    } on ReadPatchException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = _buildNumber.isEmpty
        ? 'v$_buildName'
        : 'v$_buildName ($_buildNumber)';
    return FutureBuilder<String?>(
      future: _patchText,
      builder: (context, snapshot) {
        final patch = snapshot.data;
        return Text(
          patch == null ? version : '$version · $patch',
          style: GujeukTypography.caption.copyWith(
            color: GujeukColors.textMuted,
          ),
        );
      },
    );
  }
}
