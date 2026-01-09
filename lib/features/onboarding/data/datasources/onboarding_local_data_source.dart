import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/app_constants.dart';

abstract class OnboardingLocalDataSource {
  Future<void> cacheFirstRun();
  Future<bool> isFirstRun();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final HiveInterface hive;

  OnboardingLocalDataSourceImpl(this.hive);

  @override
  Future<void> cacheFirstRun() async {
    final box = await hive.openBox(AppConstants.kOnboardingBox);
    await box.put('is_first_run', false);
  }

  @override
  Future<bool> isFirstRun() async {
    final box = await hive.openBox(AppConstants.kOnboardingBox);
    return box.get('is_first_run', defaultValue: true);
  }
}
