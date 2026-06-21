import 'package:flutter/material.dart';

class IconPickerBottomSheet {
  static Future<int?> show({
    required BuildContext context,
    required int selectedIcon,
    required int activeColor,
  }) {
    final icons = <IconData>[
      Icons.local_atm_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.shopping_bag_rounded,
      Icons.restaurant_rounded,
      Icons.directions_car_rounded,
      Icons.home_rounded,
      Icons.flight_rounded,
      Icons.fitness_center_rounded,
      Icons.celebration_rounded,
      Icons.trending_up_rounded,
      Icons.coffee_rounded,
      Icons.fastfood_rounded,
      Icons.electric_bolt_rounded,
      Icons.water_drop_rounded,
      Icons.school_rounded,
      Icons.movie_creation_rounded,
    ];

    final baseColor = Color(activeColor);

    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: icons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 50,
            ),
            itemBuilder: (context, index) {
              final icon = icons[index];
              final isSelected = icon.codePoint == selectedIcon;

              return GestureDetector(
                onTap: () => Navigator.pop(context, icon.codePoint),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? baseColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? baseColor : Colors.grey.shade300,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? baseColor : Colors.grey,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
