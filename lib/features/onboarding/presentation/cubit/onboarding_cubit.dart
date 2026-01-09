import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/cache_first_run.dart';
import '../../domain/usecases/check_if_first_run.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CacheFirstRun cacheFirstRun;
  final CheckIfFirstRun checkIfFirstRun;

  OnboardingCubit({required this.cacheFirstRun, required this.checkIfFirstRun})
    : super(OnboardingInitial());

  Future<void> checkStatus() async {
    final isFirstRun = await checkIfFirstRun();
    if (isFirstRun) {
      emit(OnboardingShow());
    } else {
      emit(OnboardingSkip());
    }
  }

  Future<void> completeOnboarding() async {
    await cacheFirstRun();
    emit(OnboardingSkip());
  }
}
