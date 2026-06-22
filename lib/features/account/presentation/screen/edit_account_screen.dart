import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form.dart';

class EditAccountScreen extends StatelessWidget {
  final AccountViewModel viewModel;
  final AccountEntity account;

  const EditAccountScreen({
    super.key,
    required this.viewModel,
    required this.account,
  });

  // get default icon
  IconData _getDefaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.wallet;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.eWallet:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      default:
        return Icons.help_outline;
    }
  }

  void _showStatusSnackBar({
    required ScaffoldMessengerState messenger,
    required String message,
    required Color backgroundColor,
    required double topMargin,
  }) {
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyNormal.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: topMargin,
          left: AppSizes.md,
          right: AppSizes.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: 'Edit Account',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.md),

              // account form context layout
              AccountForm(
                account: account,
                title: 'Account Settings',
                actionLabel: 'Update',
                onSubmit: (name, type, balance) async {
                  final icon = _getDefaultIcon(type);

                  final updatedAccount = AccountEntity(
                    id: account.id,
                    userId: account.userId,
                    name: name,
                    type: type,
                    balance: balance,
                    currencyCode: account.currencyCode,
                    icon: icon,
                    createdAt: account.createdAt,
                    updatedAt: DateTime.now(),
                    deletedAt: account.deletedAt,
                  );

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  final double statusBarHeight =
                      MediaQuery.of(context).padding.top;
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  final double headerHeight = kToolbarHeight + statusBarHeight;
                  final double calculatedTopMargin =
                      screenHeight - (headerHeight + 60);

                  try {
                    final localId = account.userId;
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final String remoteUid = currentUser?.uid ?? '';

                    final success = await viewModel.updateAccount(
                      localId,
                      remoteUid,
                      updatedAccount,
                    );

                    if (success) {
                      _showStatusSnackBar(
                        messenger: messenger,
                        message: 'Account updated successfully!',
                        backgroundColor: AppColors.success,
                        topMargin: calculatedTopMargin,
                      );
                      navigator.pop(true);
                    } else {
                      if (viewModel.updateAccountError != null) {
                        _showStatusSnackBar(
                          messenger: messenger,
                          message: viewModel.updateAccountError!,
                          backgroundColor: AppColors.error,
                          topMargin: calculatedTopMargin,
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint(
                        '[Edit Account Screen] Failed to execute update pipeline: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
