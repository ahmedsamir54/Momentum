import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource dataSource;

  TaskRepositoryImpl(this.dataSource);

  @override
  Future<List<Task>> getTasks() async {
    return await dataSource.getTasks();
  }

  @override
  Future<void> addTask(Task task) async {
    await dataSource.addTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> updateTask(Task task) async {
    await dataSource.updateTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await dataSource.deleteTask(id);
  }
}
