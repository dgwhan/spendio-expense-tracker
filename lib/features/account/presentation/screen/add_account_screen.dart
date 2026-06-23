import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class AddAccountScreen extends StatefulWidget {
  final AccountViewModel viewModel;

  const AddAccountScreen({super.key, required this.viewModel});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
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

  Future<void> _handleSubmitAccount(
    String name,
    AccountType type,
    double balance,
    String currencyCode,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final currentUserEntity = authProvider.currentUser?.toEntity();
    final int activeLocalUserId = currentUserEntity?.id ?? 0;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (activeLocalUserId <= 0) {
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Critical Session Error: Access denied due to unauthenticated user session.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newAccount = AccountEntity(
      id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
      userId: activeLocalUserId,
      name: name,
      type: type,
      balance: balance,
      currencyCode: currencyCode,
      icon: _getDefaultIcon(type),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final String remoteUid = currentUser?.uid ?? '';

      final success = await widget.viewModel.createAccount(
        activeLocalUserId,
        remoteUid,
        newAccount,
      );

      if (success) {
        if (!mounted) return;
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!',
                style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        navigator.pop(true);
      }
    } catch (e) {
      debugPrint(
          '[Add Account Screen] Failed to execute creation pipeline: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const AppHeader(
        title: 'Create New Account',
        showBack: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AccountForm(
                actionLabel: 'Create',
                onSubmit: _handleSubmitAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
