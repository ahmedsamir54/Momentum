import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/app_constants.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final HiveInterface hive;

  TaskLocalDataSourceImpl(this.hive);

  Future<Box<TaskModel>> get _box async =>
      await hive.openBox<TaskModel>(AppConstants.kTaskBox);

  @override
  Future<List<TaskModel>> getTasks() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    final box = await _box;
    await box.put(task.id, task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final box = await _box;
    await box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
