import 'package:flutter/material.dart';
import '../../../tasks/domain/entities/task.dart';

class ProgressChart extends StatelessWidget {
  final List<Task> tasks;

  const ProgressChart({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final weekData = _calculateWeeklyData();
    final maxTasks = weekData.values.fold<int>(
      0,
      (max, day) => day['planned']! > max ? day['planned']! : max,
    );

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Chart
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                  .map(
                    (day) => _buildBar(
                      context,
                      day,
                      weekData[day]!['planned']!,
                      weekData[day]!['completed']!,
                      maxTasks,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Legend and Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Legend
              Row(
                children: [
                  _buildLegendItem('Planned', Colors.grey[300]!),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    'Completed',
                    Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/$totalCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    String day,
    int planned,
    int completed,
    int maxTasks,
  ) {
    final maxHeight = 80.0; // Reduced from 100
    final plannedHeight = maxTasks > 0 ? (planned / maxTasks * maxHeight) : 0.0;
    final completedHeight = maxTasks > 0
        ? (completed / maxTasks * maxHeight)
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Task count badge
        if (planned > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$completed/$planned',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Bars
        SizedBox(
          height: maxHeight,
          width: 28,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Planned bar (background)
              Container(
                height: plannedHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Completed bar (foreground)
              Container(
                height: completedHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Day label
        Text(
          day,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Map<String, Map<String, int>> _calculateWeeklyData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final data = <String, Map<String, int>>{};
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayTasks = tasks.where((task) {
        return task.date.year == day.year &&
            task.date.month == day.month &&
            task.date.day == day.day;
      }).toList();

      data[days[i]] = {
        'planned': dayTasks.length,
        'completed': dayTasks.where((t) => t.isCompleted).length,
      };
    }

    return data;
  }
}
