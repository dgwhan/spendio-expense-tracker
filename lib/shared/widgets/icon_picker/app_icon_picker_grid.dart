import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppIconPickerGrid extends StatelessWidget {
  final int selectedIconCode;
  final int activeColorValue;
  final ValueChanged<int> onIconSelected;

  const AppIconPickerGrid({
    super.key,
    required this.selectedIconCode,
    required this.activeColorValue,
    required this.onIconSelected,
  });

  static const List<IconData> _availableIcons = [
    Icons.local_atm_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.shopping_bag_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.movie_creation_rounded,
    Icons.school_rounded,
    Icons.medication_rounded,
    Icons.flight_rounded,
    Icons.fitness_center_rounded,
    Icons.celebration_rounded,
    Icons.build_rounded,
    Icons.phone_android_rounded,
    Icons.trending_up_rounded,
    Icons.card_giftcard_rounded,
    Icons.coffee_rounded,
    Icons.fastfood_rounded,
    Icons.electric_bolt_rounded,
    Icons.water_drop_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.dividerLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _availableIcons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 46,
        ),
        itemBuilder: (context, index) {
          final iconData = _availableIcons[index];
          final isSelected = selectedIconCode == iconData.codePoint;
          final baseColor = Color(activeColorValue);

          return GestureDetector(
            onTap: () => onIconSelected(iconData.codePoint),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? baseColor.withValues(alpha: 0.18)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border:
                    isSelected ? Border.all(color: baseColor, width: 2) : null,
              ),
              child: Icon(
                iconData,
                color: isSelected ? baseColor : Colors.grey.shade500,
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }
}
