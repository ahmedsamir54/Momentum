abstract class OnboardingRepository {
  Future<void> cacheFirstRun();
  Future<bool> isFirstRun();
}
