import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/user_name_formatter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        //thanh load
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              //Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning, ',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight),
                          )
                        ],
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceDark,
                        child: Icon(Icons.person, color: AppColors.disabled),
                      )
                    ],
                  ),
                ),
              ),

              //Componet: Summary total balance
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Component 2: Balance Summary Card',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),

              //Component: quick action
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 85,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Component 3: Quick Actions Grid',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),

              //Conponent: Spending Categories
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Component 4: Spending Categories (Grid 2x3)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),

              //Component: finacial pulse
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 270,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Component 5: Financial Pulse',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),

              //Componet: Spending breakdown
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 340,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Component 6: Spending Breakdown',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),

              //Component: recent activity
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0,
                    40.0), // Đáy đẩy cao 40.0 để tạo khoảng thở an toàn cho BottomNav
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Component 7: Recent Activity List',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
