import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const AppHeader({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.dividerLight,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 22,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Good morning, $displayName',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),

        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.black87,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
