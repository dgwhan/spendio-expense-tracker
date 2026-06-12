import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_item_card.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

class AccountsScreen extends StatelessWidget {
  final List<AccountEntity> accounts;

  const AccountsScreen({super.key, required this.accounts});

  // Generates simulated/mock transactions specific to this account's type
  List<Map<String, dynamic>> _getSimulatedTransactions(AccountEntity account) {
    final now = DateTime.now();
    switch (account.type) {
      case AccountType.bank:
        return [
          {
            'title': 'Salary Payment',
            'category': 'Income',
            'amount': 15000000.0,
            'date': now.subtract(const Duration(days: 2)),
            'isExpense': false,
            'icon': Icons.payment,
            'color': Colors.green.shade800,
            'bgColor': Colors.green.shade50,
          },
          {
            'title': 'Electricity Bill',
            'category': 'Bills',
            'amount': 1200000.0,
            'date': now.subtract(const Duration(days: 5)),
            'isExpense': true,
            'icon': Icons.electrical_services,
            'color': Colors.orange.shade800,
            'bgColor': Colors.orange.shade50,
          },
          {
            'title': 'Office Lunch',
            'category': 'Food & Drink',
            'amount': 150000.0,
            'date': now.subtract(const Duration(days: 6)),
            'isExpense': true,
            'icon': Icons.local_dining,
            'color': Colors.amber.shade800,
            'bgColor': Colors.amber.shade50,
          },
        ];
      case AccountType.creditCard:
        return [
          {
            'title': 'Zara Shopping Mall',
            'category': 'Shopping',
            'amount': 2400000.0,
            'date': now.subtract(const Duration(days: 1)),
            'isExpense': true,
            'icon': Icons.shopping_bag,
            'color': Colors.blue.shade800,
            'bgColor': Colors.blue.shade50,
          },
          {
            'title': 'Netflix Subscription',
            'category': 'Entertainment',
            'amount': 260000.0,
            'date': now.subtract(const Duration(days: 4)),
            'isExpense': true,
            'icon': Icons.movie,
            'color': Colors.red.shade800,
            'bgColor': Colors.red.shade50,
          },
          {
            'title': 'Fuel Refill Station',
            'category': 'Transport',
            'amount': 500000.0,
            'date': now.subtract(const Duration(days: 8)),
            'isExpense': true,
            'icon': Icons.local_gas_station,
            'color': Colors.purple.shade800,
            'bgColor': Colors.purple.shade50,
          },
        ];
      case AccountType.eWallet:
        return [
          {
            'title': 'Shopee Online Store',
            'category': 'Shopping',
            'amount': 450000.0,
            'date': now.subtract(const Duration(hours: 4)),
            'isExpense': true,
            'icon': Icons.shopping_cart,
            'color': Colors.orange.shade800,
            'bgColor': Colors.orange.shade50,
          },
          {
            'title': 'CGV Cinema Tickets',
            'category': 'Entertainment',
            'amount': 220000.0,
            'date': now.subtract(const Duration(days: 3)),
            'isExpense': true,
            'icon': Icons.theaters,
            'color': Colors.red.shade800,
            'bgColor': Colors.red.shade50,
          },
          {
            'title': 'Transfer from Vietcombank',
            'category': 'Income',
            'amount': 1000000.0,
            'date': now.subtract(const Duration(days: 5)),
            'isExpense': false,
            'icon': Icons.swap_horiz,
            'color': Colors.green.shade800,
            'bgColor': Colors.green.shade50,
          },
        ];
      case AccountType.cash:
        return [
          {
            'title': 'Highlands Coffee',
            'category': 'Food & Drink',
            'amount': 65000.0,
            'date': now.subtract(const Duration(hours: 2)),
            'isExpense': true,
            'icon': Icons.coffee,
            'color': Colors.brown.shade800,
            'bgColor': Colors.brown.shade50,
          },
          {
            'title': 'Grab Bike Ride',
            'category': 'Transport',
            'amount': 35000.0,
            'date': now.subtract(const Duration(hours: 5)),
            'isExpense': true,
            'icon': Icons.motorcycle,
            'color': Colors.teal.shade800,
            'bgColor': Colors.teal.shade50,
          },
          {
            'title': 'Street Food Lunch',
            'category': 'Food & Drink',
            'amount': 120000.0,
            'date': now.subtract(const Duration(days: 1)),
            'isExpense': true,
            'icon': Icons.restaurant,
            'color': Colors.amber.shade800,
            'bgColor': Colors.amber.shade50,
          },
        ];
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (txDate == yesterday) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  void _showAddAccountDialog(BuildContext context, WalletViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final balanceController = TextEditingController();
        AccountType selectedType = AccountType.cash;

        IconData getDefaultIcon(AccountType type) {
          switch (type) {
            case AccountType.cash:
              return Icons.wallet;
            case AccountType.bank:
              return Icons.account_balance;
            case AccountType.eWallet:
              return Icons.account_balance_wallet;
            case AccountType.creditCard:
              return Icons.credit_card;
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg + keyboardPadding,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.cardRadiusLg),
                  topRight: Radius.circular(AppRadius.cardRadiusLg),
                ),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
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
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Text(
                        'Create New Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Text(
                        'Add a new wallet to track your expenses and balances.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      
                      // Name input
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Account Name',
                          hintText: 'e.g. My Savings, Daily Cash',
                          labelStyle: const TextStyle(color: AppColors.textMutedLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter account name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Balance input
                      TextFormField(
                        controller: balanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Initial Balance',
                          hintText: '0.00',
                          labelStyle: const TextStyle(color: AppColors.textMutedLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (double.tryParse(value.trim()) == null) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),

                      const Text(
                        'Account Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      // Account Type Selector
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSizes.sm,
                          mainAxisSpacing: AppSizes.sm,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: AccountType.values.length,
                        itemBuilder: (context, index) {
                          final type = AccountType.values[index];
                          final isSelected = selectedType == type;
                          final Color typeColor = type.mainColor;
                          final Color bgColor = type.bgColor;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = type;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                              decoration: BoxDecoration(
                                color: isSelected ? bgColor : Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isSelected ? typeColor : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    getDefaultIcon(type),
                                    color: isSelected ? typeColor : Colors.grey,
                                    size: 24,
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    type.displayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.textPrimaryLight : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // Actions buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                final name = nameController.text.trim();
                                final balance = double.tryParse(balanceController.text.trim()) ?? 0.0;
                                final icon = getDefaultIcon(selectedType);

                                final newAccount = AccountEntity(
                                  id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
                                  name: name,
                                  type: selectedType,
                                  balance: balance,
                                  icon: icon,
                                );

                                viewModel.addNewAccount(newAccount);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              child: const Text('Create'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  void _showAccountDetailsDialog(BuildContext context, AccountEntity account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final Color typeColor = account.type.mainColor;
        final transactions = _getSimulatedTransactions(account);

        double totalIncome = 0.0;
        double totalExpense = 0.0;

        for (var tx in transactions) {
          final amt = tx['amount'] as double;
          if (tx['isExpense'] as bool) {
            totalExpense += amt;
          } else {
            totalIncome += amt;
          }
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.cardRadiusLg),
              topRight: Radius.circular(AppRadius.cardRadiusLg),
                ),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimaryLight),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 48), // spacer to center the title
                ],
              ),
              const SizedBox(height: AppSizes.md),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card representation
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.lg * 1.2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              typeColor,
                              typeColor.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
                          boxShadow: [
                            BoxShadow(
                              color: typeColor.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSizes.sm),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Icon(
                                    account.icon,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                Text(
                                  account.type.displayName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.xl * 1.2),
                            const Text(
                              'CURRENT BALANCE',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(account.balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Inflow / Outflow summary row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.arrow_downward, color: Colors.green.shade700, size: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Inflow', style: TextStyle(color: AppColors.textMutedLight, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    CurrencyFormatter.format(totalIncome),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.arrow_upward, color: Colors.red.shade700, size: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Outflow', style: TextStyle(color: AppColors.textMutedLight, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    CurrencyFormatter.format(totalExpense),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.xl),

                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Transaction list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final isExpense = tx['isExpense'] as bool;
                          final amt = tx['amount'] as double;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: tx['bgColor'] as Color,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Icon(
                                    tx['icon'] as IconData,
                                    color: tx['color'] as Color,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${tx['category']} • ${_formatDateTime(tx['date'] as DateTime)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isExpense ? "-" : "+"}${CurrencyFormatter.format(amt)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isExpense ? AppColors.textPrimaryLight : Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WalletViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.backgroundLight,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsetsDirectional.only(
                  start: AppSizes.md,
                  bottom: AppSizes.md,
                ),
                title: const Text(
                  'My Accounts',
                  style: TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: AppTextButton(
                    text: 'Add',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    onTap: () {
                      _showAddAccountDialog(context, viewModel);
                    },
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSizes.md,
                  crossAxisSpacing: AppSizes.md,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final account = accounts[index];
                    return AccountItemCard(
                      account: account,
                      onTap: () {
                        _showAccountDetailsDialog(context, account);
                      },
                    );
                  },
                  childCount: accounts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
