import '../repositories/onboarding_repository.dart';

class CheckIfFirstRun {
  final OnboardingRepository repository;

  CheckIfFirstRun(this.repository);

  Future<bool> call() async {
    return await repository.isFirstRun();
  }
}
