import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/notification_service.dart';
export '../services/notification_service.dart';
import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/cache_first_run.dart';
import '../../features/onboarding/domain/usecases/check_if_first_run.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/tasks/data/datasources/task_local_data_source.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/add_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
import '../../features/tasks/presentation/cubit/task_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  await Hive.initFlutter();

  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskModelAdapter());
  }

  // Register NotificationService
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // Register Hive instance
  sl.registerLazySingleton<HiveInterface>(() => Hive);

  // Features - Onboarding
  // Bloc
  sl.registerFactory(
    () => OnboardingCubit(cacheFirstRun: sl(), checkIfFirstRun: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => CacheFirstRun(sl()));
  sl.registerLazySingleton(() => CheckIfFirstRun(sl()));

  // Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );

  // Data Source
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl()),
  );

  // Features - Tasks
  // Bloc
  sl.registerFactory(
    () => TaskCubit(
      getTasks: sl(),
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      notificationService: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  // Data Source
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );
}
