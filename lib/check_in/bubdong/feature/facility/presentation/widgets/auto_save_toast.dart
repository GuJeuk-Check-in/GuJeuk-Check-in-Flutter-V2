import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 자동 저장 토스트 상태
enum AutoSaveStatus {
  /// 저장까지 남은 시간을 세는 중
  counting,

  /// 저장 끝
  saved,
}

/// 오른쪽 위 자동 저장 토스트 (Figma 자동 저장까지 / 저장됨)
class AutoSaveToast extends StatelessWidget {
  const AutoSaveToast({
    super.key,
    required this.status,
    required this.secondsLeft,
    required this.progress,
  });

  final AutoSaveStatus status;
  final int secondsLeft; // "3초"
  final double progress; // 남은 시간 줄 길이 (1 → 0)

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      AutoSaveStatus.counting => _buildCounting(),
      AutoSaveStatus.saved => _buildSaved(),
    };
  }

  Widget _buildCounting() {
    return Container(
      width: BubdongLayout.autoSaveToastWidth,
      height: BubdongLayout.toastHeight,
      padding: BubdongLayout.toastPadding,
      decoration: const BoxDecoration(
        color: BubdongColors.toastAutoSaveBg,
        borderRadius: BubdongRadius.r15All,
      ),
      child: Row(
        children: [
          Expanded(
            // 글자 묶음 + 아래 줄까지가 Figma 한 묶음 (줄 위치 72 + 높이 3)
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight:
                    BubdongLayout.toastProgressTop +
                    BubdongLayout.toastProgressHeight,
              ),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: BubdongSpacing.s10, // Figma 제목과 설명 사이
                    children: [
                      Text(
                        '자동 저장까지',
                        style: BubdongTypography.toastTitle.copyWith(
                          color: BubdongColors.toastAutoSaveTitle,
                        ),
                      ),
                      Text(
                        '저장 후 이용을 시작할 수 있어',
                        style: BubdongTypography.toastBody.copyWith(
                          color: BubdongColors.toastAutoSaveBody,
                        ),
                      ),
                    ],
                  ),
                  // 남은 시간만큼 줄어드는 줄 (Figma 직사각형 Y 72, 높이 3)
                  Positioned(
                    top: BubdongLayout.toastProgressTop,
                    left: 0,
                    right: 0,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0, 1),
                      child: Container(
                        height: BubdongLayout.toastProgressHeight,
                        color: BubdongColors.toastAutoSaveProgress,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '$secondsLeft초',
            style: BubdongTypography.toastTitle.copyWith(
              color: BubdongColors.toastAutoSaveTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaved() {
    return Container(
      width: BubdongLayout.savedToastWidth,
      height: BubdongLayout.toastHeight,
      // TODO: 저장됨 토스트 안쪽 여백 Figma 값 확인 (지금은 자동 저장 토스트와 같음)
      padding: BubdongLayout.toastPadding,
      decoration: BoxDecoration(
        color: BubdongColors.toastSavedBg,
        borderRadius: BubdongRadius.r15All,
      ),
      // 테두리를 위에 덮어 그림 (Figma 안쪽 테두리 2)
      foregroundDecoration: BoxDecoration(
        borderRadius: BubdongRadius.r15All,
        border: Border.all(color: BubdongColors.toastSavedBorder, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '저장됨',
            style: BubdongTypography.toastTitle.copyWith(
              color: BubdongColors.toastSavedTitle,
            ),
          ),
          Text(
            '이제 가서 놀아도 돼!',
            style: BubdongTypography.toastBody.copyWith(
              color: BubdongColors.toastSavedBody,
            ),
          ),
        ],
      ),
    );
  }
}
