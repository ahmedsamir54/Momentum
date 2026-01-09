import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource dataSource;

  OnboardingRepositoryImpl(this.dataSource);

  @override
  Future<void> cacheFirstRun() async {
    return await dataSource.cacheFirstRun();
  }

  @override
  Future<bool> isFirstRun() async {
    return await dataSource.isFirstRun();
  }
}
