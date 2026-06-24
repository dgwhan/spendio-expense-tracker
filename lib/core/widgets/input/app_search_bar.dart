import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onClear,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final fillColor = isDark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondaryLight;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        // ✅ ĐÃ XOÁ: Bỏ hoàn toàn thuộc tính border để thanh search phẳng lì, không bao giờ hiện viền nữa
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: mutedTextColor,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontSize: 14,
                color: primaryTextColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: mutedTextColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              if (widget.controller.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                  if (widget.onClear != null) widget.onClear!();
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.cancel_rounded,
                    size: 18,
                    color: mutedTextColor.withValues(alpha: 0.6),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
