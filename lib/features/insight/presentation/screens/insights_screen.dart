import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/insight/presentation/widgets/insight_detailed_breakdown_list.dart';
import 'package:spend_io_app/features/insight/presentation/widgets/insight_filter_segment.dart';
import 'package:spend_io_app/features/insight/presentation/widgets/net_flow_summary_card.dart';
import 'package:spend_io_app/features/insight/presentation/widgets/visual_chart_area.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_viewmodel.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final txVM = context.watch<TransactionViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();
    final insightVM = context.watch<InsightViewModel>();

    // Tính toán dữ liệu State phản hồi từ các tệp ViewModels
    final state = insightVM.getCalculatedState(
      context,
      txVM.state.transactions,
      categoryVM.state.categories,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const AppHeader(
        title: 'Insights',
        showBack: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => await txVM.loadAllTransactions(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              InsightFilterSegment(insightVM: insightVM),
              NetFlowSummaryCard(state: state),
              VisualChartArea(state: state),
              InsightDetailedBreakdownList(state: state),
            ],
          ),
        ),
      ),
    );
  }
}
