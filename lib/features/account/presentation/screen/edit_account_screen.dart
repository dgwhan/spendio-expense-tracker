import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form.dart';

class EditAccountScreen extends StatefulWidget {
  final AccountViewModel viewModel;
  final AccountEntity account;

  const EditAccountScreen({
    super.key,
    required this.viewModel,
    required this.account,
  });

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  IconData _getDefaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.wallet_rounded;
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.eWallet:
        return Icons.account_balance_wallet_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
      default:
        return Icons.help_outline_rounded;
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

  Future<void> _handleUpdateAccount(
    String name,
    AccountType type,
    double balance,
    String currencyCode,
  ) async {
    final icon = _getDefaultIcon(type);

    final updatedAccount = AccountEntity(
      id: widget.account.id,
      userId: widget.account.userId,
      name: name,
      type: type,
      balance: balance,
      currencyCode: currencyCode,
      icon: icon,
      createdAt: widget.account.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: widget.account.deletedAt,
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = kToolbarHeight + statusBarHeight;
    final double calculatedTopMargin = screenHeight - (headerHeight + 60);

    try {
      final localId = widget.account.userId;
      final currentUser = FirebaseAuth.instance.currentUser;
      final String remoteUid = currentUser?.uid ?? '';

      final success = await widget.viewModel.updateAccount(
        localId,
        remoteUid,
        updatedAccount,
      );

      if (!mounted) return;

      if (success) {
        _showStatusSnackBar(
          messenger: messenger,
          message: 'Account updated successfully!',
          backgroundColor: AppColors.success,
          topMargin: calculatedTopMargin,
        );
        navigator.pop(true);
      } else {
        if (widget.viewModel.updateAccountError != null) {
          _showStatusSnackBar(
            messenger: messenger,
            message: widget.viewModel.updateAccountError!,
            backgroundColor: AppColors.error,
            topMargin: calculatedTopMargin,
          );
        }
      }
    } catch (e) {
      debugPrint('[Edit Account Screen] Failed to execute update pipeline: $e');
    }
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ĐỒNG BỘ SLIVER: Đưa AccountForm vào cuộn mượt mà chống tràn bàn phím ảo
            SliverToBoxAdapter(
              child: AccountForm(
                account: widget.account,
                actionLabel: 'Update',
                onSubmit: _handleUpdateAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
