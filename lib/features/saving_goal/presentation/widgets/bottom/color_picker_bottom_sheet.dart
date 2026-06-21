import 'package:flutter/material.dart';
import 'package:spend_io_app/shared/widgets/color_picker/app_color_picker_grid.dart';

class ColorPickerBottomSheet {
  static Future<int?> show({
    required BuildContext context,
    required int selectedColor,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      useSafeArea: true, // Tránh tai thỏ và các khu vực lỗi hệ thống
      isScrollControlled: true, // Giúp sheet ôm sát bọc khít theo Column
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              // FIX: Chống đè hoàn toàn bằng cách cộng thêm độ cao cản của Navigation Bar / Bàn phím ảo
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh kéo gạch xám trên đầu BottomSheet
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Hiển thị FULL màu lấy từ AppColorPickerGrid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      AppColorPickerGrid.availableColors.map((colorValue) {
                    final isSelected = selectedColor == colorValue;

                    return GestureDetector(
                      onTap: () => Navigator.pop(context, colorValue),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: isDark ? Colors.white : Colors.black,
                                  width: 3,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
