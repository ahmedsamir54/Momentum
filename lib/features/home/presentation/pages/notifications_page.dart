import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../../../tasks/domain/entities/task.dart';

/// ============================================================
/// 🔔 NOTIFICATIONS PAGE
/// ============================================================
/// This page shows all upcoming task notifications
/// - Start time notifications
/// - End time notifications
/// ============================================================

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          if (state is TaskLoaded) {
            // Filter only incomplete tasks (completed tasks don't need notifications)
            final incompleteTasks = state.tasks
                .where((task) => !task.isCompleted)
                .toList();

            if (incompleteTasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add tasks to see notifications here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            // Create notification items for each task (start + end)
            final notifications = _buildNotificationList(incompleteTasks);

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return notifications[index];
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// Build notification list from tasks
  List<Widget> _buildNotificationList(List<Task> tasks) {
    final List<Widget> notifications = [];
    final now = DateTime.now();

    for (final task in tasks) {
      final taskEnd = DateTime(
        task.date.year,
        task.date.month,
        task.date.day,
        task.endTime.hour,
        task.endTime.minute,
      );

      // Check if task has ended (needs completion confirmation)
      final hasEnded = now.isAfter(taskEnd);

      if (hasEnded) {
        // Show completion confirmation for ended tasks
        notifications.add(_CompletionConfirmationCard(task: task));
      } else {
        // Show upcoming notifications
        // Start time notification
        if (task.startTime.isAfter(now)) {
          notifications.add(
            _NotificationCard(
              task: task,
              isStartNotification: true,
              scheduledTime: task.startTime,
            ),
          );
        }

        // End time notification
        if (task.endTime.isAfter(now)) {
          notifications.add(
            _NotificationCard(
              task: task,
              isStartNotification: false,
              scheduledTime: task.endTime,
            ),
          );
        }
      }
    }

    // Sort: Ended tasks first, then by scheduled time
    notifications.sort((a, b) {
      if (a is _CompletionConfirmationCard &&
          b is! _CompletionConfirmationCard) {
        return -1; // Ended tasks first
      }
      if (a is! _CompletionConfirmationCard &&
          b is _CompletionConfirmationCard) {
        return 1;
      }
      if (a is _NotificationCard && b is _NotificationCard) {
        return a.scheduledTime.compareTo(b.scheduledTime);
      }
      return 0;
    });

    return notifications;
  }
}

/// ============================================================
/// 🔔 NOTIFICATION CARD WIDGET
/// ============================================================
class _NotificationCard extends StatelessWidget {
  final Task task;
  final bool isStartNotification;
  final DateTime scheduledTime;

  const _NotificationCard({
    required this.task,
    required this.isStartNotification,
    required this.scheduledTime,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    // Calculate time remaining
    String timeRemaining;
    if (difference.inMinutes < 60) {
      timeRemaining = 'in ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      timeRemaining = 'in ${difference.inHours} hours';
    } else {
      timeRemaining = 'in ${difference.inDays} days';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isStartNotification
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isStartNotification
                  ? Icons.play_circle_outline
                  : Icons.stop_circle_outlined,
              color: isStartNotification ? Colors.green : Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStartNotification ? 'Task Starting' : 'Task Ending',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${timeFormat.format(scheduledTime)} • ${dateFormat.format(scheduledTime)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time remaining badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              timeRemaining,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// ✅ COMPLETION CONFIRMATION CARD
/// ============================================================
/// Shows for tasks that have ended but not marked as complete
class _CompletionConfirmationCard extends StatelessWidget {
  final Task task;

  const _CompletionConfirmationCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Ended',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Did you complete this task?',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Task info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${timeFormat.format(task.startTime)} - ${timeFormat.format(task.endTime)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              // Mark as Complete button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final updatedTask = Task(
                      id: task.id,
                      title: task.title,
                      description: task.description,
                      date: task.date,
                      startTime: task.startTime,
                      endTime: task.endTime,
                      isCompleted: true,
                      project: task.project,
                    );
                    context.read<TaskCubit>().updateExistingTask(updatedTask);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('✅ "${task.title}" marked as complete!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text(
                    'Yes, Completed',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Keep as incomplete button
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task kept as incomplete'),
                      backgroundColor: Colors.grey[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.all(12),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
