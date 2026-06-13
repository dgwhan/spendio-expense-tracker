import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'widgets/account_balance_card.dart';

class AccountDetailsBottomSheet extends StatelessWidget {
  final AccountEntity account;

  const AccountDetailsBottomSheet({super.key, required this.account});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AppConfirmationDialog(
          title: 'Delete Account',
          content: 'Are you sure you want to delete this account? This action cannot be undone.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          isDestructive: true,
          onConfirm: () {
            Navigator.pop(context, 'delete'); // Pop details sheet
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.cardRadiusLg),
          topRight: Radius.circular(AppRadius.cardRadiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: primaryTextColor),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                account.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Card Representation
          AccountBalanceCard(account: account),
          const SizedBox(height: AppSizes.md),

          // Edit & Delete Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, 'edit'); // Close details sheet
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                  label: const Text('Edit Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}