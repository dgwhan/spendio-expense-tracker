import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// DATA LAYER
import 'package:spend_io_app/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:spend_io_app/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:spend_io_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:spend_io_app/features/onboarding/domain/repositories/onboarding_repository.dart';

// DOMAIN LAYER
import 'package:spend_io_app/features/onboarding/domain/usecases/save_onboarding_usecase.dart';
import 'package:spend_io_app/features/onboarding/domain/usecases/get_onboarding_usecase.dart';
import 'package:spend_io_app/features/onboarding/domain/usecases/check_onboarding_usecase.dart';
import 'package:spend_io_app/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';

// PRESENTATION LAYER
import 'package:spend_io_app/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';

class OnboardingModuleProvider {
  OnboardingModuleProvider._();

  static List<SingleChildWidget> get providers => [
        // 1. DATA LAYER
        Provider<OnboardingLocalDataSource>(
            create: (_) => OnboardingLocalDataSourceImpl()),
        Provider<OnboardingRemoteDataSource>(
            create: (_) => OnboardingRemoteDataSource()),
        ProxyProvider2<OnboardingLocalDataSource, OnboardingRemoteDataSource,
            OnboardingRepository>(
          update: (_, local, remote, __) => OnboardingRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        // 2. DOMAIN LAYER
        ProxyProvider<OnboardingRepository, SaveOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? SaveOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepository, GetOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? GetOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepository, CheckOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? CheckOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepository, CompleteOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? CompleteOnboardingUseCase(repository: repo),
        ),

        // 3. PRESENTATION LAYER
        ChangeNotifierProxyProvider4<
            SaveOnboardingUseCase,
            GetOnboardingUseCase,
            CheckOnboardingUseCase,
            CompleteOnboardingUseCase,
            OnboardingViewModel>(
          create: (context) => OnboardingViewModel(
            saveOnboardingUseCase: context.read<SaveOnboardingUseCase>(),
            getOnboardingUseCase: context.read<GetOnboardingUseCase>(),
            checkOnboardingUseCase: context.read<CheckOnboardingUseCase>(),
            completeOnboardingUseCase:
                context.read<CompleteOnboardingUseCase>(),
          ),
          update: (_, saveUC, getUC, checkUC, completeUC, vm) =>
              vm ??
              OnboardingViewModel(
                saveOnboardingUseCase: saveUC,
                getOnboardingUseCase: getUC,
                checkOnboardingUseCase: checkUC,
                completeOnboardingUseCase: completeUC,
              ),
        ),
      ];
}
