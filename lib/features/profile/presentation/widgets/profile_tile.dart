import 'package:flutter/material.dart';
import 'package:spend_io_app/core/widgets/common/app_screen_title.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;
  final Color textPrimaryColor;
  final Color textSecondaryColor;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: AppScreenTitle(
              title: title, isCenter: false, color: textPrimaryColor),
        ),

        // Phần hiển thị giá trị bên phải (Value)
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
