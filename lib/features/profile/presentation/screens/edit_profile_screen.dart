import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/core/widgets/common/app_input_decoration.dart';
import 'package:spend_io_app/core/widgets/common/app_screen_title.dart';
import '../viewmodels/profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late String _selectedOccupation;
  late List<String> _selectedGoals;
  late String _selectedCurrency;
  bool _isGoalDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ProfileViewModel>();
    _nameController =
        TextEditingController(text: viewModel.user?.displayName ?? '');

    const allowedOccupations = [
      'Student',
      'Employee',
      'Freelancer',
      'Business Owner',
      'Other'
    ];
    final userOcc = viewModel.user?.occupation;
    _selectedOccupation =
        allowedOccupations.contains(userOcc) ? userOcc! : 'Student';

    final rawGoals = viewModel.user?.financialGoal ?? '';
    _selectedGoals = rawGoals
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _selectedCurrency = viewModel.user?.currencyCode ?? 'VND';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final isDark = viewModel.isDarkMode;

    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderBoxColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppScreenTitle(
          title: AppLocalizations.translate('edit_profile'),
          isCenter: true,
          color: textPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                AppLocalizations.translate('full_name'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: textPrimary),
                decoration: AppInputDecoration.getFieldDecoration(
                  context: context,
                  labelText: '',
                  hintText: AppLocalizations.translate('onboarding_input_placeholder'),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                AppLocalizations.translate('profile_occupation_label'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedOccupation,
                decoration: AppInputDecoration.getFieldDecoration(
                  context: context,
                  labelText: '',
                  hintText: AppLocalizations.translate('onboarding_input_placeholder'),
                ),
                dropdownColor: surfaceColor,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
                items: ['Student', 'Employee', 'Freelancer', 'Business Owner', 'Other'].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val, style: TextStyle(color: textPrimary)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedOccupation = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              Text(
                AppLocalizations.translate('profile_goal_label'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isGoalDropdownOpen = !_isGoalDropdownOpen;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: borderBoxColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _selectedGoals.isEmpty
                            ? Text(
                                AppLocalizations.currentLanguage == 'vi'
                                    ? 'Chọn mục tiêu tài chính (tối đa 2)'
                                    : 'Select financial goals (max 2)',
                                style: TextStyle(color: textMuted, fontSize: 16),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: _selectedGoals.map((goal) {
                                  return Chip(
                                    label: Text(goal, style: TextStyle(color: textPrimary, fontSize: 12)),
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                    deleteIcon: Icon(Icons.close, size: 14, color: textSecondary),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedGoals.remove(goal);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                      ),
                      Icon(
                        _isGoalDropdownOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isGoalDropdownOpen) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: borderBoxColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      'Quick Notes',
                      'Savings Goals',
                      'Loan Tracking',
                      'Expense Management',
                      'Budget Planning'
                    ].map((goal) {
                      final isSelected = _selectedGoals.contains(goal);
                      return CheckboxListTile(
                        title: Text(goal, style: TextStyle(color: textPrimary)),
                        value: isSelected,
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              if (_selectedGoals.length >= 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.currentLanguage == 'vi'
                                          ? 'Chỉ được chọn tối đa 2 mục tiêu!'
                                          : 'You can only select up to 2 goals!',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              } else {
                                _selectedGoals.add(goal);
                              }
                            } else {
                              _selectedGoals.remove(goal);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              Text(
                AppLocalizations.translate('currency'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCurrencyCard(
                      code: 'VND',
                      flag: '🇻🇳',
                      name: 'Vietnam Dong',
                      isSelected: _selectedCurrency == 'VND',
                      surfaceColor: surfaceColor,
                      borderColor: borderBoxColor,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCurrencyCard(
                      code: 'USD',
                      flag: '🇺🇸',
                      name: 'US Dollar',
                      isSelected: _selectedCurrency == 'USD',
                      surfaceColor: surfaceColor,
                      borderColor: borderBoxColor,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: borderBoxColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.translate('cancel'),
                        style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await viewModel.updateUserProfile(
                          displayName: _nameController.text.trim(),
                          occupation: _selectedOccupation,
                          financialGoal: _selectedGoals.join(','),
                          currency: _selectedCurrency,
                        );
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.translate('update_success_msg'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.translate('update_fail_msg'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.translate('save'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyCard({
    required String code,
    required String flag,
    required String name,
    required bool isSelected,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final isUsd = code == 'USD';
    final cardName = isUsd
        ? '$name (${AppLocalizations.currentLanguage == 'vi' ? 'Sớm ra mắt' : 'Coming Soon'})'
        : name;

    return GestureDetector(
      onTap: isUsd
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.currentLanguage == 'vi'
                        ? 'Tính năng đổi sang USD sẽ sớm ra mắt!'
                        : 'USD currency switch is coming soon!',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          : () {
              setState(() {
                _selectedCurrency = code;
              });
            },
      child: Opacity(
        opacity: isUsd ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.primary : borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                code,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cardName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
