import 'package:flutter/material.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';
import 'package:spend_io_app/shared/widgets/color_picker/app_color_picker_grid.dart';

class GoalColorPickerSection extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onChanged;
  final VoidCallback? onViewAll;

  const GoalColorPickerSection({
    super.key,
    required this.selectedColor,
    required this.onChanged,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewColors = AppColorPickerGrid.availableColors.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            AppTextButton(
              text: 'View all',
              onTap: onViewAll,
              fontSize: 13,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: previewColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final colorValue = previewColors[index];
              final isSelected = selectedColor == colorValue;
              final itemColor = Color(colorValue);

              return GestureDetector(
                onTap: () => onChanged(colorValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? itemColor.withValues(alpha: 0.18)
                        : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.03)),
                    border: Border.all(
                      color: isSelected ? itemColor : Colors.grey.shade300,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 30 : 34,
                      height: isSelected ? 30 : 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: itemColor,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
