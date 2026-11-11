import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/data/remote_school_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/school_repository.dart';

/// 학교 검색 팝업
class SchoolSearchDialog extends StatefulWidget {
  const SchoolSearchDialog({super.key, this.selectedName});

  final String? selectedName; // 전에 고른 학교 (목록에서 주황으로 표시)

  /// 팝업을 띄우고, 고른 학교 이름을 돌려줌 (닫으면 null)
  static Future<String?> show(BuildContext context, {String? selectedName}) {
    return showDialog<String>(
      context: context,
      barrierColor: BubdongColors.overlay,
      builder: (_) => SchoolSearchDialog(selectedName: selectedName),
    );
  }

  @override
  State<SchoolSearchDialog> createState() => _SchoolSearchDialogState();
}

class _SchoolSearchDialogState extends State<SchoolSearchDialog> {
  final _queryController = TextEditingController();
  final _repository = RemoteSchoolRepository(bubdongApiClient);

  List<School> _schools = []; // 서버가 준 검색 결과
  bool _isLoading = false; // 검색 중
  String? _error; // 실패했을 때 보여줄 문구

  /// 검색어로 서버에 학교를 찾음 (엔터 누를 때)
  Future<void> _search(String keyword) async {
    final name = keyword.trim();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _repository.search(name: name);
      if (!mounted) return; // 기다리는 동안 팝업이 닫혔으면 멈춤
      setState(() => _schools = result.schools);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '학교를 불러오지 못했어요. 다시 검색해줘');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static const _fieldBorder = OutlineInputBorder(
    borderRadius: BubdongRadius.r24All,
    borderSide: BorderSide(color: BubdongColors.borderSearchField, width: 1),
  );

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // 뒤 화면 흐리게
      child: Center(
        child: Material(
          color: BubdongColors.bgSurface,
          borderRadius: BubdongRadius.r30All,
          child: Container(
            width: BubdongLayout.schoolSearchDialogWidth,
            height: BubdongLayout.schoolSearchDialogHeight,
            padding: const EdgeInsets.all(BubdongSpacing.s40),
            // 좌우 40 (Figma 700 - 칸 620)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 + 닫기
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '학교 검색',
                        style: BubdongTypography.dialogTitle.copyWith(
                          color: BubdongColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(
                        Icons.close,
                        size: BubdongLayout.schoolSearchCloseSize,
                        // Figma 24×24
                        color: BubdongColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BubdongSpacing.s24),

                // 검색칸
                Text(
                  '학교 이름',
                  style: BubdongTypography.dialogFieldLabel.copyWith(
                    color: BubdongColors.textDialogLabel,
                  ),
                ),
                const SizedBox(height: BubdongSpacing.s8),
                // Figma "법동중학교"는 입력한 모습 예시라, 처음에는 비우고 안내 글자를 보여줌
                TextField(
                  controller: _queryController,
                  onSubmitted: _search,
                  textInputAction: TextInputAction.search,
                  style: BubdongTypography.dialogInput.copyWith(
                    color: BubdongColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '학교 이름을 입력해줘',
                    hintStyle: BubdongTypography.dialogInput.copyWith(
                      color: BubdongColors.textPlaceholder,
                    ),
                    // Figma 검색칸: 높이 66, 좌우 33, 모서리 24, 검정 테두리 1
                    constraints: const BoxConstraints.tightFor(
                      height: BubdongLayout.schoolSearchFieldHeight,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: BubdongLayout.schoolSearchFieldPaddingX,
                    ),
                    border: _fieldBorder,
                    enabledBorder: _fieldBorder,
                    focusedBorder: _fieldBorder,
                  ),
                ),
                const SizedBox(height: BubdongSpacing.s24),

                // 결과 개수
                Text(
                  '검색 결과 ${_schools.length}개',
                  style: BubdongTypography.resultCount.copyWith(
                    color: BubdongColors.textResultCount,
                  ),
                ),
                const SizedBox(height: BubdongSpacing.s16),

                // 결과 목록 (팝업 높이가 고정이라 넘치면 목록만 스크롤)
                Expanded(child: _buildResults()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 결과 자리: 검색 중 / 실패 / 결과 없음 / 목록
  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: BubdongColors.brandPrimary),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: BubdongTypography.bodySm.copyWith(
            color: BubdongColors.textSecondary,
          ),
        ),
      );
    }
    if (_schools.isEmpty) {
      return Center(
        child: Text(
          '학교 이름을 입력하고 검색해줘',
          style: BubdongTypography.bodySm.copyWith(
            color: BubdongColors.textSecondary,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _schools.length,
      separatorBuilder: (_, _) => const SizedBox(height: BubdongSpacing.s16),
      itemBuilder: (_, i) => _SchoolResultItem(
        name: _schools[i].name,
        address: _schools[i].address,
        selected: _schools[i].name == widget.selectedName,
        onTap: () =>
            Navigator.of(context).pop(_schools[i].name), // 누르면 바로 고르고 닫음
      ),
    );
  }
}

/// 검색 결과 한 줄
class _SchoolResultItem extends StatelessWidget {
  const _SchoolResultItem({
    required this.name,
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: BubdongLayout.schoolResultHeight,
        padding: BubdongLayout.schoolResultPadding,
        decoration: BoxDecoration(
          color: selected ? BubdongColors.brandSubtle : BubdongColors.bgSurface,
          borderRadius: BubdongRadius.r24All,
        ),
        // 테두리를 위에 덮어 그림 (Figma 안쪽 테두리처럼 글자 자리를 줄이지 않음)
        foregroundDecoration: BoxDecoration(
          borderRadius: BubdongRadius.r24All,
          border: Border.all(
            color: selected
                ? BubdongColors.brandPrimary
                : BubdongColors.borderSchoolResult,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Figma 세로 가운데
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: BubdongTypography.resultTitle.copyWith(
                color: BubdongColors.textPrimary,
              ),
            ),
            const SizedBox(height: BubdongSpacing.s10), // Figma 이름과 주소 사이
            // Figma Body/Large 18/160, color/grey/42
            Text(
              address,
              style: BubdongTypography.bodySm.copyWith(
                color: BubdongColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}