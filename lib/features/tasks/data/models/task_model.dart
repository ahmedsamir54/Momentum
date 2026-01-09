import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends Task {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String title;

  @HiveField(2)
  @override
  final String description;

  @HiveField(3)
  @override
  final DateTime date;

  @HiveField(4)
  @override
  final DateTime startTime;

  @HiveField(5)
  @override
  final DateTime endTime;

  @HiveField(6)
  @override
  final bool isCompleted;

  @HiveField(7)
  @override
  final String project;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
    required this.project,
  }) : super(
         id: id,
         title: title,
         description: description,
         date: date,
         startTime: startTime,
         endTime: endTime,
         isCompleted: isCompleted,
         project: project,
       );

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      startTime: task.startTime,
      endTime: task.endTime,
      isCompleted: task.isCompleted,
      project: task.project,
    );
  }
}
