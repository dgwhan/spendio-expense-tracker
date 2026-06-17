import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppColorPickerGrid extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  static final List<int> availableColors = [
    AppColors.primary.toARGB32(),
    AppColors.success.toARGB32(),
    AppColors.error.toARGB32(),
    AppColors.warning.toARGB32(),
    AppColors.info.toARGB32(),
    AppColors.investment.toARGB32(),
    AppColors.creditCardAccount.toARGB32(),
    AppColors.cashAccount.toARGB32(),
    AppColors.eWalletAccount.toARGB32(),
    AppColors.categoryFoodDrinkLight.toARGB32(),
    AppColors.categoryTransportLight.toARGB32(),
    AppColors.categoryGroceriesLight.toARGB32(),
  ];

  const AppColorPickerGrid({
    super.key,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableColors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, idx) {
        final colorValue = availableColors[idx];
        final isSelected = selectedColorValue == colorValue;

        return GestureDetector(
          onTap: () => onColorSelected(colorValue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
      },
    );
  }
}
