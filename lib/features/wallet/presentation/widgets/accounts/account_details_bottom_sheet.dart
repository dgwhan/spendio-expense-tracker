import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';

class AccountDetailsBottomSheet extends StatelessWidget {
  final AccountEntity account;

  const AccountDetailsBottomSheet({super.key, required this.account});

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

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Representation
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

                  // Inflow / Outflow Row
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

                  // Transaction List
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
}