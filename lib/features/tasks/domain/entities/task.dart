import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  final String project; // e.g., "Planning Trip", "Coding Games"

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
    required this.project,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    startTime,
    endTime,
    isCompleted,
    project,
  ];
}
