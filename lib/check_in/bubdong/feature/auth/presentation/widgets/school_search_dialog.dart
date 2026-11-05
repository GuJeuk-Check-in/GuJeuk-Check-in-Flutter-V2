import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 학교 검색 팝업 (퍼블리싱용: 가짜 데이터)
class SchoolSearchDialog extends StatefulWidget {
  const SchoolSearchDialog({super.key});

  /// 팝업을 띄우고, 고른 학교 이름을 돌려줌 (닫으면 null)
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierColor: BubdongColors.overlay,
      builder: (_) => const SchoolSearchDialog(),
    );
  }

  @override
  State<SchoolSearchDialog> createState() => _SchoolSearchDialogState();
}

class _SchoolSearchDialogState extends State<SchoolSearchDialog> {
  // TODO: API 연결 시 검색 결과로 교체
  static const _results = [
    (name: '법동중학교', address: '대전 광역시 대덕구'),
    (name: '법동초등학교', address: '대전 광역시 대덕구'),
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // 뒤 화면 흐리게
      child: Center(
        child: Material(
          color: BubdongColors.bgSurface,
          borderRadius: BubdongRadius.r30All,
          child: Container(
            width: 700, // Figma 확인 후 조정
            padding: const EdgeInsets.all(BubdongSpacing.s40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 + 닫기
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '학교 검색',
                        style: BubdongTypography.h4.copyWith(color: BubdongColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: BubdongColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: BubdongSpacing.s24),

                // 검색칸
                Text('학교 이름', style: BubdongTypography.fieldLabel),
                const SizedBox(height: BubdongSpacing.s8),
                TextField(
                  style: BubdongTypography.bodyMd.copyWith(color: BubdongColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '학교 이름을 입력해줘',
                    hintStyle: BubdongTypography.bodyMd.copyWith(color: BubdongColors.textPlaceholder),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: BubdongSpacing.s24,
                      vertical: BubdongSpacing.s16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BubdongRadius.r9999All,
                      borderSide: const BorderSide(color: BubdongColors.borderCard, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BubdongRadius.r9999All,
                      borderSide: const BorderSide(color: BubdongColors.borderCard, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BubdongRadius.r9999All,
                      borderSide: const BorderSide(color: BubdongColors.brandPrimary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: BubdongSpacing.s24),

                // 결과 개수
                Text(
                  '검색 결과 ${_results.length}개',
                  style: BubdongTypography.bodySm.copyWith(color: BubdongColors.textPlaceholder),
                ),
                const SizedBox(height: BubdongSpacing.s16),

                // 결과 목록
                for (var i = 0; i < _results.length; i++) ...[
                  _SchoolResultItem(
                    name: _results[i].name,
                    address: _results[i].address,
                    selected: _selectedIndex == i,
                    onTap: () {
                      setState(() => _selectedIndex = i);
                      Navigator.of(context).pop(_results[i].name); // 고른 학교 이름 돌려주기
                    },
                  ),
                  if (i != _results.length - 1) const SizedBox(height: BubdongSpacing.s16),
                ],
              ],
            ),
          ),
        ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: BubdongSpacing.s24,
          vertical: BubdongSpacing.s16,
        ),
        decoration: BoxDecoration(
          color: selected ? BubdongColors.brandSubtle : BubdongColors.bgSurface,
          borderRadius: BubdongRadius.r15All,
          border: Border.all(
            color: selected ? BubdongColors.brandPrimary : BubdongColors.borderCard,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: BubdongTypography.subtitle.copyWith(color: BubdongColors.textPrimary)),
            const SizedBox(height: BubdongSpacing.s4),
            Text(address, style: BubdongTypography.bodySm.copyWith(color: BubdongColors.textPlaceholder)),
          ],
        ),
      ),
    );
  }
}