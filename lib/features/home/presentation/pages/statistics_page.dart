import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Statistics',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Overall Progress Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withAlpha(179),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoaded) {
                      final totalTasks = state.tasks.length;
                      final completedTasks = state.tasks
                          .where((task) => task.isCompleted)
                          .length;
                      final completionRate = totalTasks > 0
                          ? (completedTasks / totalTasks * 100).toStringAsFixed(
                              1,
                            )
                          : '0.0';

                      return Column(
                        children: [
                          const Text(
                            'Overall Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$completionRate%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$completedTasks of $totalTasks tasks completed',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoaded) {
                    final totalTasks = state.tasks.length;
                    final completedTasks = state.tasks
                        .where((task) => task.isCompleted)
                        .length;
                    final pendingTasks = totalTasks - completedTasks;
                    final todayTasks = state.tasks
                        .where(
                          (task) =>
                              task.date.year == DateTime.now().year &&
                              task.date.month == DateTime.now().month &&
                              task.date.day == DateTime.now().day,
                        )
                        .length;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          'Total Tasks',
                          totalTasks.toString(),
                          Icons.task_alt,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Completed',
                          completedTasks.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Pending',
                          pendingTasks.toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Today',
                          todayTasks.toString(),
                          Icons.today,
                          Colors.purple,
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 24),

              // Weekly Activity
              const Text(
                'Weekly Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoaded) {
                      return _buildWeeklyChart(state.tasks);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Project Breakdown
              const Text(
                'Tasks by Project',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoaded) {
                    final projectGroups = <String, int>{};
                    for (var task in state.tasks) {
                      projectGroups[task.project] =
                          (projectGroups[task.project] ?? 0) + 1;
                    }

                    return Column(
                      children: projectGroups.entries
                          .map(
                            (entry) => _buildProjectBar(
                              entry.key,
                              entry.value,
                              state.tasks.length,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List tasks) {
    final weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final dayCounts = List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      return tasks.where((task) {
        return task.date.year == day.year &&
            task.date.month == day.month &&
            task.date.day == day.day;
      }).length;
    });

    final maxCount = dayCounts.reduce((a, b) => a > b ? a : b);

    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final height = maxCount > 0
                ? (dayCounts[index] / maxCount * 120)
                : 0.0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (dayCounts[index] > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${dayCounts[index]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  width: 32,
                  height: height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(179),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weekDays[index],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildProjectBar(String project, int count, int total) {
    final percentage = (count / total * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                project,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '$count tasks ($percentage%)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / total,
              backgroundColor: Colors.grey[200],
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
