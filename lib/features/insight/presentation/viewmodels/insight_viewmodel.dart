import 'package:flutter/material.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/insight/data/models/insight_spending_item.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_state.dart';
import 'package:spend_io_app/core/currency/convert_currency_use_case.dart';
import 'package:spend_io_app/core/currency/exchange_rate_provider.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class InsightViewModel extends ChangeNotifier {
  final ConvertCurrencyUseCase _convertCurrency = const ConvertCurrencyUseCase(LocalExchangeRateProvider());
  String _activeFilter = 'Month';
  DateTimeRange? _customRange;
  
  String get activeFilter => _activeFilter;
  DateTimeRange? get customRange => _customRange;

  void changeFilter(String newFilter, {DateTimeRange? range}) {
    if (newFilter == 'Custom' && range != null) {
      _customRange = range;
    }
    _activeFilter = newFilter;
    notifyListeners();
  }

  // Pure logic mapping to compute the dynamic state to be consumed by the view
  InsightState getCalculatedState(
      BuildContext context, List<TransactionEntity> transactions, List<CategoryEntity> categories) {
    final preferredCurrencyCode = context.currencyContext.preferredCurrencyCode;
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (_activeFilter == 'Day') {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (_activeFilter == 'Year') {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
    } else if (_activeFilter == 'Custom') {
      if (_customRange != null) {
        start = DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day, 0, 0, 0);
        end = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
      } else {
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
      }
    } else {
      // Month
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    }

    final filteredTxs = transactions.where((t) {
      return t.transactionDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
             t.transactionDate.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    for (final tx in filteredTxs) {
      final double convertedAmount = _convertCurrency.execute(
        amount: tx.amount,
        from: tx.currencyCode,
        to: preferredCurrencyCode,
      );
      if (tx.type == TransactionType.income) {
        totalIncome += convertedAmount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += convertedAmount;
      }
    }

    final expenses = filteredTxs.where((t) => t.type == TransactionType.expense).toList();
    
    double totalExpenseAmount = 0.0;
    final Map<String, double> grouped = {};
    for (final t in expenses) {
      final double convertedAmount = _convertCurrency.execute(
        amount: t.amount,
        from: t.currencyCode,
        to: preferredCurrencyCode,
      );
      totalExpenseAmount += convertedAmount;
      grouped[t.categoryId] = (grouped[t.categoryId] ?? 0) + convertedAmount;
    }

    final List<InsightSpendingItem> listItems = [];
    grouped.forEach((catId, amount) {
      CategoryEntity? category;
      for (final c in categories) {
        if (c.id == catId) {
          category = c;
          break;
        }
      }

      final resolvedName = category?.name ?? catId;
      final resolvedColor = category != null ? Color(category.colorValue) : Colors.grey;
      final resolvedIconCode = category?.iconCodePoint ?? Icons.receipt_long_outlined.codePoint;
      final resolvedIconFamily = category?.iconFontFamily;

      final percentage = totalExpenseAmount == 0 ? 0.0 : amount / totalExpenseAmount;

      listItems.add(
        InsightSpendingItem(
          name: resolvedName,
          amount: amount,
          percentage: percentage,
          color: resolvedColor,
          iconCodePoint: resolvedIconCode,
          iconFontFamily: resolvedIconFamily,
        ),
      );
    });

    listItems.sort((a, b) => b.amount.compareTo(a.amount));

    // Calculate Bar Chart trend datasets
    final List<BarChartItem> barItems = [];

    if (_activeFilter == 'Day') {
      final Map<String, double> dayGroups = {
        "00-06": 0.0,
        "06-12": 0.0,
        "12-18": 0.0,
        "18-24": 0.0,
      };
      for (final t in expenses) {
        final hour = t.transactionDate.hour;
        final double convertedAmount = _convertCurrency.execute(
          amount: t.amount,
          from: t.currencyCode,
          to: preferredCurrencyCode,
        );
        if (hour >= 0 && hour < 6) {
          dayGroups["00-06"] = dayGroups["00-06"]! + convertedAmount;
        } else if (hour >= 6 && hour < 12) {
          dayGroups["06-12"] = dayGroups["06-12"]! + convertedAmount;
        } else if (hour >= 12 && hour < 18) {
          dayGroups["12-18"] = dayGroups["12-18"]! + convertedAmount;
        } else {
          dayGroups["18-24"] = dayGroups["18-24"]! + convertedAmount;
        }
      }
      for (final entry in dayGroups.entries) {
        barItems.add(BarChartItem(label: entry.key, value: entry.value));
      }
    } else if (_activeFilter == 'Month') {
      final Map<String, double> monthGroups = {
        "W1": 0.0,
        "W2": 0.0,
        "W3": 0.0,
        "W4": 0.0,
        "W5": 0.0,
      };
      for (final t in expenses) {
        final day = t.transactionDate.day;
        final double convertedAmount = _convertCurrency.execute(
          amount: t.amount,
          from: t.currencyCode,
          to: preferredCurrencyCode,
        );
        if (day <= 7) {
          monthGroups["W1"] = monthGroups["W1"]! + convertedAmount;
        } else if (day <= 14) {
          monthGroups["W2"] = monthGroups["W2"]! + convertedAmount;
        } else if (day <= 21) {
          monthGroups["W3"] = monthGroups["W3"]! + convertedAmount;
        } else if (day <= 28) {
          monthGroups["W4"] = monthGroups["W4"]! + convertedAmount;
        } else {
          monthGroups["W5"] = monthGroups["W5"]! + convertedAmount;
        }
      }
      for (final entry in monthGroups.entries) {
        barItems.add(BarChartItem(label: entry.key, value: entry.value));
      }
    } else if (_activeFilter == 'Year') {
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final Map<String, double> yearGroups = {
        for (var m in months) m: 0.0,
      };
      for (final t in expenses) {
        final mIdx = t.transactionDate.month - 1;
        if (mIdx >= 0 && mIdx < 12) {
          final mLabel = months[mIdx];
          final double convertedAmount = _convertCurrency.execute(
            amount: t.amount,
            from: t.currencyCode,
            to: preferredCurrencyCode,
          );
          yearGroups[mLabel] = yearGroups[mLabel]! + convertedAmount;
        }
      }
      for (final entry in yearGroups.entries) {
        barItems.add(BarChartItem(label: entry.key, value: entry.value));
      }
    } else if (_activeFilter == 'Custom') {
      final diffDays = DateTime(end.year, end.month, end.day).difference(DateTime(start.year, start.month, start.day)).inDays + 1;
      if (diffDays <= 7) {
        final List<String> dayLabels = [];
        final Map<String, double> customGroups = {};
        for (int i = 0; i < diffDays; i++) {
          final d = start.add(Duration(days: i));
          final label = "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";
          dayLabels.add(label);
          customGroups[label] = 0.0;
        }
        for (final t in expenses) {
          final d = t.transactionDate;
          final label = "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";
          if (customGroups.containsKey(label)) {
            final double convertedAmount = _convertCurrency.execute(
              amount: t.amount,
              from: t.currencyCode,
              to: preferredCurrencyCode,
            );
            customGroups[label] = customGroups[label]! + convertedAmount;
          }
        }
        for (final label in dayLabels) {
          barItems.add(BarChartItem(label: label, value: customGroups[label]!));
        }
      } else {
        final totalMs = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
        final intervalMs = totalMs / 5;
        final List<String> intervalLabels = [];
        final List<DateTimeRange> ranges = [];
        for (int i = 0; i < 5; i++) {
          final istart = start.add(Duration(milliseconds: (i * intervalMs).toInt()));
          final iend = start.add(Duration(milliseconds: ((i + 1) * intervalMs).toInt()));
          ranges.add(DateTimeRange(start: istart, end: iend));
          
          final sLabel = "${istart.day.toString().padLeft(2, '0')}/${istart.month.toString().padLeft(2, '0')}";
          final eLabel = "${iend.day.toString().padLeft(2, '0')}/${iend.month.toString().padLeft(2, '0')}";
          intervalLabels.add("$sLabel-$eLabel");
        }
        final Map<String, double> intervalGroups = {
          for (var label in intervalLabels) label: 0.0,
        };
        for (final t in expenses) {
          final tMs = t.transactionDate.millisecondsSinceEpoch;
          for (int i = 0; i < 5; i++) {
            final range = ranges[i];
            if (tMs >= range.start.millisecondsSinceEpoch && tMs <= range.end.millisecondsSinceEpoch) {
              final double convertedAmount = _convertCurrency.execute(
                amount: t.amount,
                from: t.currencyCode,
                to: preferredCurrencyCode,
              );
              intervalGroups[intervalLabels[i]] = intervalGroups[intervalLabels[i]]! + convertedAmount;
              break;
            }
          }
        }
        for (final label in intervalLabels) {
          barItems.add(BarChartItem(label: label, value: intervalGroups[label]!));
        }
      }
    }

    return InsightState(
      activeFilter: _activeFilter,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: totalIncome - totalExpense,
      spendingItems: listItems,
      barItems: barItems,
    );
  }
}
