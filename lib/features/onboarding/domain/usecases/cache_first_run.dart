import '../repositories/onboarding_repository.dart';

class CacheFirstRun {
  final OnboardingRepository repository;

  CacheFirstRun(this.repository);

  Future<void> call() async {
    return await repository.cacheFirstRun();
  }
}
