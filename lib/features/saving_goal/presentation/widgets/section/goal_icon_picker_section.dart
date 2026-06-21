import 'package:flutter/material.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';

class GoalIconPickerSection extends StatelessWidget {
  final int selectedIcon;
  final int activeColor;
  final ValueChanged<int> onChanged;
  final VoidCallback? onViewAll;

  const GoalIconPickerSection({
    super.key,
    required this.selectedIcon,
    required this.activeColor,
    required this.onChanged,
    this.onViewAll,
  });

  static const List<IconData> _icons = [
    Icons.local_atm_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.shopping_bag_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.movie_creation_rounded,
    Icons.school_rounded,
    Icons.flight_rounded,
    Icons.fitness_center_rounded,
    Icons.celebration_rounded,
    Icons.trending_up_rounded,
    Icons.coffee_rounded,
    Icons.fastfood_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final baseColor = Color(activeColor);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Icon',
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
            itemCount: _icons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final icon = _icons[index];
              final isSelected = selectedIcon == icon.codePoint;

              return GestureDetector(
                onTap: () => onChanged(icon.codePoint),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? baseColor.withValues(alpha: 0.18)
                        : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.03)),
                    border: Border.all(
                      color: isSelected ? baseColor : Colors.grey.shade300,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? baseColor : Colors.grey,
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
