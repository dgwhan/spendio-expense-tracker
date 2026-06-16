import 'package:firebase_auth/firebase_auth.dart'; // 🔥 BỔ SUNG: Để lấy email user hiện tại làm tham số đồng bộ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
// 🔥 BỔ SUNG IMPORT: Để lấy OnboardingRepository nạp vào hàm ViewModel
import 'package:spend_io_app/features/onboarding/domain/repositories/onboarding_repository.dart';

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

    _nameController = TextEditingController(
      text: widget.account?.name ?? '',
    );

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
    // 🔥 BỐC REPO CỨU HỘ: Lấy OnboardingRepository đang được Provider cung cấp trong context
    final onboardingRepo = context.read<OnboardingRepository>();

    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    final int localId = widget.account?.userId ?? 0;

    // 🔥 BỐC SESSION EMAIL DỘNG: Lấy email của user hiện tại đang đăng nhập hệ thống từ Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;
    final String userEmail = currentUser?.email ?? '';
    final String remoteUid = currentUser?.uid ?? '';

    try {
      if (widget.account == null) {
        // 🔥 ĐỌC TIỀN TỆ ĐỘNG TỪ TRẠNG THÁI DANH SÁCH VÍ TRÊN RAM
        final String? detectedCurrency = accountVM.userCurrency;

        // 🔥 CHỐT CHẶN BẢO VỆ PHÒNG DỊCH: Nếu CSDL trống rỗng/chưa tải xong, chặn ghi dữ liệu rác
        if (detectedCurrency == null || detectedCurrency.trim().isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Unable to detect active wallet currency. Please ensure your configuration is loaded.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // TRƯỜNG HỢP THÊM VÍ MỚI: Khởi sinh thực thể hoàn chỉnh
        final account = AccountEntity(
          id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
          userId: localId,
          name: name,
          type: _selectedType,
          balance: balance,
          currencyCode:
              detectedCurrency, // Đã nạp động hoàn toàn không gán cứng
          icon: _getIcon(_selectedType),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 🔥 ĐÃ FIX: Truyền thêm 2 tham số bắt buộc onboardingRepo và userEmail vào hàm
        await accountVM.createAccount(
          localId,
          remoteUid,
          account,
          onboardingRepo: onboardingRepo,
          userEmail: userEmail,
        );
      } else {
        // TRƯỜNG HỢP CẬP NHẬT VÍ: Giữ nguyên vẹn mã tiền tệ gốc của ví, không ghi đè lung tung
        final account = AccountEntity(
          id: widget.account!.id,
          userId: widget.account!.userId,
          name: name,
          type: _selectedType,
          balance: balance,
          currencyCode: widget
              .account!.currencyCode, // Giữ vững liên kết tiền tệ của ví cũ
          icon: _getIcon(_selectedType),
          createdAt: widget.account!.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: widget.account!.deletedAt,
        );

        // 🔥 ĐÃ FIX: Truyền thêm 2 tham số bắt buộc onboardingRepo và userEmail vào hàm
        await accountVM.updateAccount(
          localId,
          remoteUid,
          account,
          onboardingRepo: onboardingRepo,
          userEmail: userEmail,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Account submit error: $e');
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                    value: _selectedType,
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
                        child: Text(
                          error,
                          style: const TextStyle(color: AppColors.error),
                        ),
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
