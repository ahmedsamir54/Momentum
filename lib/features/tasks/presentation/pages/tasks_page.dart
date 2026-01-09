import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/task_cubit.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/task.dart';
import 'package:uuid/uuid.dart';

class TasksPage extends StatelessWidget {
  final String projectName;

  const TasksPage({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TaskCubit>()..loadTasks(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white, // Or specific color from design
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Task Detail',
                style: TextStyle(color: Colors.black),
              ), // Or "Planning Trip"
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Members
                  Row(
                    children: [
                      const Text(
                        'Member',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // Avatars placeholder
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                      ),
                      const SizedBox(width: -8),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Date picker placeholder (Horizontal list)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: index == 1
                                ? Theme.of(context).primaryColor
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                [
                                  'Mo',
                                  'Tu',
                                  'We',
                                  'Th',
                                  'Fr',
                                  'Sa',
                                  'Su',
                                ][index],
                                style: TextStyle(
                                  color: index == 1
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${10 + index}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: index == 1
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Total 26 Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<TaskCubit, TaskState>(
                      builder: (context, state) {
                        if (state is TaskLoaded) {
                          final tasks = state.tasks
                              .where((t) => t.project == projectName)
                              .toList();
                          if (tasks.isEmpty) {
                            return const Center(
                              child: Text('No tasks yet. Add one!'),
                            );
                          }
                          return ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 40,
                                      color: index % 2 == 0
                                          ? Colors.blue
                                          : Colors.purple,
                                      margin: const EdgeInsets.only(right: 16),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${task.startTime.hour}:${task.startTime.minute} - ${task.endTime.hour}:${task.endTime.minute}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: task.isCompleted,
                                      onChanged: (val) {
                                        // Update task
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  // Add dummy task for demo
                  final task = Task(
                    id: const Uuid().v4(),
                    title: 'New Task',
                    description: 'Description',
                    date: DateTime.now(),
                    startTime: DateTime.now(),
                    endTime: DateTime.now().add(const Duration(hours: 1)),
                    isCompleted: false,
                    project: projectName,
                  );
                  context.read<TaskCubit>().addNewTask(task);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Add New Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
