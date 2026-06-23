import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class AccountFormView extends StatefulWidget {
  final AccountEntity? account;
  final String title;
  final String actionLabel;

  const AccountFormView({
    super.key,
    this.account,
    required this.title,
    required this.actionLabel,
  });

  @override
  State<AccountFormView> createState() => _AccountFormViewState();
}

class _AccountFormViewState extends State<AccountFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account?.balance.toStringAsFixed(0) ?? '',
    );
    _selectedType = widget.account?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  IconData _getIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.payments_rounded;
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
      case AccountType.eWallet:
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final accountVM = context.read<AccountViewModel>();
    final authProvider = context.read<AuthProvider>();

    // Extract authentic verified local session ID safely
    final int resolvedLocalUserId =
        authProvider.currentUser?.id ?? widget.account?.userId ?? 0;

    if (resolvedLocalUserId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Critical Session Error: Unable to determine authenticated user context.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    final String remoteUid = currentUser?.uid ?? '';

    try {
      if (widget.account == null) {
        final String? detectedCurrency = accountVM.userCurrency;

        if (detectedCurrency == null || detectedCurrency.trim().isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Unable to detect active wallet currency. Please ensure configuration is loaded.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final account = AccountEntity(
          id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
          userId: resolvedLocalUserId,
          name: name,
          type: _selectedType,
          balance: balance,
          currencyCode: detectedCurrency,
          icon: _getIcon(_selectedType),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 🔥 FIXED: Invoked clean creation contract matching our minimalist Phase 02 scope
        await accountVM.createAccount(
          resolvedLocalUserId,
          remoteUid,
          account,
        );
      } else {
        final account = AccountEntity(
          id: widget.account!.id,
          userId: resolvedLocalUserId,
          name: name,
          type: _selectedType,
          balance: balance,
          currencyCode: widget.account!.currencyCode,
          icon: _getIcon(_selectedType),
          createdAt: widget.account!.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: widget.account!.deletedAt,
        );

        // 🔥 FIXED: Invoked clean update contract matching our minimalist Phase 02 scope
        await accountVM.updateAccount(
          resolvedLocalUserId,
          remoteUid,
          account,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Account submit runtime error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final inputFillColor = isDark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.cardRadiusLg),
          topRight: Radius.circular(AppRadius.cardRadiusLg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Account Name',
                      labelStyle: TextStyle(color: mutedTextColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Account name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _balanceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Balance',
                      labelStyle: TextStyle(color: mutedTextColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Balance is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  DropdownButtonFormField<AccountType>(
                    dropdownColor: backgroundColor,
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      labelStyle: TextStyle(color: mutedTextColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    items: AccountType.values.map((type) {
                      String nameDisplay = 'Other';
                      if (type == AccountType.cash) nameDisplay = 'Cash';
                      if (type == AccountType.bank) nameDisplay = 'Bank';
                      if (type == AccountType.creditCard) {
                        nameDisplay = 'Credit Card';
                      }
                      if (type == AccountType.eWallet) nameDisplay = 'E-Wallet';

                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          nameDisplay.toUpperCase(),
                          style: TextStyle(color: primaryTextColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Consumer<AccountViewModel>(
                    builder: (context, vm, _) {
                      final error = widget.account == null
                          ? vm.createAccountError
                          : vm.updateAccountError;
                      if (error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: Text(error,
                            style: const TextStyle(color: AppColors.error)),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Consumer<AccountViewModel>(
                          builder: (context, vm, _) {
                            final isLoading = widget.account == null
                                ? vm.isCreatingAccount
                                : vm.isUpdatingAccount;
                            return ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(widget.actionLabel),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
