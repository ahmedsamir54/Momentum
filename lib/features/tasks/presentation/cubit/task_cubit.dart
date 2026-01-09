import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../../../core/services/notification_service.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final NotificationService notificationService;

  TaskCubit({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.notificationService,
  }) : super(TaskInitial());

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> addNewTask(Task task) async {
    try {
      await addTask(task);

      // Schedule notifications
      final taskId = task.id.hashCode;
      final taskIdString = task.id; // استخدام task.id كـ payload

      // Start time notification
      await notificationService.scheduleTaskNotification(
        id: taskId,
        title: 'Task Started: ${task.title}',
        // **الإصلاح: استخدام علامات اقتباس مزدوجة لتبسيط الأمر**
        body: "It's time to start working on your task!",
        scheduledTime: task.startTime,
        payload: taskIdString,
      );

      // End time notification
      await notificationService.scheduleTaskNotification(
        id: taskId + 1,
        title: 'Task Ending: ${task.title}',
        // **الإصلاح: استخدام علامات اقتباس مزدوجة لتبسيط الأمر**
        body: "Your task time is up!",
        scheduledTime: task.endTime,
        payload: taskIdString,
      );

      await loadTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> updateExistingTask(Task task) async {
    try {
      await updateTask(task);

      // Reschedule notifications
      final taskId = task.id.hashCode;
      await notificationService.cancelNotification(taskId);
      await notificationService.cancelNotification(taskId + 1);

      if (!task.isCompleted) {
        final taskIdString = task.id; // استخدام task.id كـ payload

        // Start time notification
        await notificationService.scheduleTaskNotification(
          id: taskId,
          title: 'Task Started: ${task.title}',
          // **الإصلاح: استخدام علامات اقتباس مزدوجة لتبسيط الأمر**
          body: "It's time to start working on your task!",
          scheduledTime: task.startTime,
          payload: taskIdString,
        );

        // End time notification
        await notificationService.scheduleTaskNotification(
          id: taskId + 1,
          title: 'Task Ending: ${task.title}',
          // **الإصلاح: استخدام علامات اقتباس مزدوجة لتبسيط الأمر**
          body: "Your task time is up!",
          scheduledTime: task.endTime,
          payload: taskIdString,
        );
      }

      await loadTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> deleteExistingTask(String id) async {
    try {
      await deleteTask(id);

      // Cancel notifications
      final taskId = id.hashCode;
      await notificationService.cancelNotification(taskId);
      await notificationService.cancelNotification(taskId + 1);

      await loadTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
