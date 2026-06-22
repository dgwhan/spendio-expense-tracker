import 'package:flutter/material.dart';
import 'package:spend_io_app/core/widgets/common/app_screen_title.dart';
import 'package:spend_io_app/core/utils/localization.dart';

class WalletHeader extends StatelessWidget {
  final DateTime? selectedMonth;
  final VoidCallback? onGenerateReport;
  final VoidCallback? onMonthTap;

  const WalletHeader({
    super.key,
    this.selectedMonth,
    this.onGenerateReport,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppScreenTitle(
      title: AppLocalizations.translate('wallet'),
      isCenter: true,
    );
  }
}

