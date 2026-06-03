import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String displayName;

  const AppHeader({
    super.key,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Good morning, $displayName',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),

        // Avatar
        InkWell(
          onTap: () {
            // TODO: Điều hướng qua màn hình Profile cá nhân
          },
          borderRadius: BorderRadius.circular(20),
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.dividerLight,
            child: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
