import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_list_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_detail_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/saving_goal_detail_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/create_saving_goal_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/saving_goals_card.dart';

class SavingGoalListScreen extends StatefulWidget {
  const SavingGoalListScreen({super.key});

  @override
  State<SavingGoalListScreen> createState() => _SavingGoalListScreenState();
}

class _SavingGoalListScreenState extends State<SavingGoalListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;

    if (userId == null) return;

    await context.read<SavingGoalListViewModel>().loadGoals(
          userId: userId,
        );
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateSavingGoalScreen(),
      ),
    );

    if (result == true && context.mounted) {
      await _load();
    }
  }

  Future<void> _goToDetail(dynamic goal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (ctx) => SavingGoalDetailViewModel(
            getGoalByIdUseCase: ctx.read(),
            getGoalContributionsUseCase: ctx.read(),
            addGoalContributionUseCase: ctx.read(),
            updateGoalUseCase: ctx.read(),
            deleteGoalUseCase: ctx.read(),
          ),
          child: SavingGoalDetailScreen(goalId: goal.id),
        ),
      ),
    );

    if (result == true && context.mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingGoalListViewModel>();

    return Scaffold(
      appBar: AppHeader(
        title: 'Saving Goals',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : vm.goals.isEmpty
                ? _EmptyState(onCreate: _goToCreate)
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: vm.goals.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final goal = vm.goals[index];

                      return SavingGoalsCard(
                        goal: goal,
                        onTap: () => _goToDetail(goal),
                      );
                    },
                  ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flag_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'No Saving Goals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your first goal to start saving',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create Goal'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
