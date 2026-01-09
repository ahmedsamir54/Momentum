import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/di/injection_container.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/add_task_bottom_sheet.dart';
import 'calendar_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import '../widgets/animated_notification_icon.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _taskFilter = 'All';
  String? _selectedProject;
  DateTime? _selectedDate;

  final List<String> _filters = ['All', 'Completed', 'Incomplete'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TaskCubit>()..loadTasks(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNavigationBar(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final taskCubit = context.read<TaskCubit>();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (bottomSheetContext) => BlocProvider.value(
                    value: taskCubit,
                    child: const AddTaskBottomSheet(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) {
        switch (_currentIndex) {
          case 0:
            return _buildHomePage();
          case 1:
            return BlocProvider.value(
              value: context.read<TaskCubit>(),
              child: const CalendarPage(),
            );
          case 3:
            return BlocProvider.value(
              value: context.read<TaskCubit>(),
              child: const StatisticsPage(),
            );
          case 4:
            return const ProfilePage();
          default:
            return _buildHomePage();
        }
      },
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=12',
                      ),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'Arya Wijaya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // 🔔 Animated Notification Bell Icon
                BlocBuilder<TaskCubit, TaskState>(
                  builder: (builderContext, state) {
                    int activeTasksCount = 0;
                    DateTime? lastTaskStartTime;

                    if (state is TaskLoaded) {
                      final now = DateTime.now();

                      // Count both active AND ended tasks (waiting for completion)
                      final activeTasks = state.tasks.where((task) {
                        if (task.isCompleted) return false;

                        final taskStart = DateTime(
                          task.date.year,
                          task.date.month,
                          task.date.day,
                          task.startTime.hour,
                          task.startTime.minute,
                        );

                        // Task is "active" if:
                        // 1. Currently running (between start and end)
                        // 2. OR has ended but not completed (needs confirmation)
                        return now.isAfter(taskStart);
                      }).toList();

                      activeTasksCount = activeTasks.length;

                      // Get the most recent task start time for animation trigger
                      if (activeTasks.isNotEmpty) {
                        activeTasks.sort((a, b) {
                          final aStart = DateTime(
                            a.date.year,
                            a.date.month,
                            a.date.day,
                            a.startTime.hour,
                            a.startTime.minute,
                          );
                          final bStart = DateTime(
                            b.date.year,
                            b.date.month,
                            b.date.day,
                            b.startTime.hour,
                            b.startTime.minute,
                          );
                          return bStart.compareTo(aStart);
                        });

                        lastTaskStartTime = DateTime(
                          activeTasks.first.date.year,
                          activeTasks.first.date.month,
                          activeTasks.first.date.day,
                          activeTasks.first.startTime.hour,
                          activeTasks.first.startTime.minute,
                        );
                      }
                    }

                    return AnimatedNotificationIcon(
                      activeTasksCount: activeTasksCount,
                      lastTaskStartTime: lastTaskStartTime,
                      onTap: () {
                        final taskCubit = builderContext.read<TaskCubit>();
                        Navigator.push(
                          builderContext,
                          MaterialPageRoute(
                            builder: (navContext) => BlocProvider.value(
                              value: taskCubit,
                              child: const NotificationsPage(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search project',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    // Get available projects from tasks
                    final availableProjects = <String>{};
                    if (state is TaskLoaded) {
                      for (var task in state.tasks) {
                        if (task.project.isNotEmpty) {
                          availableProjects.add(task.project);
                        }
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FilterBottomSheet(
                            selectedProject: _selectedProject,
                            selectedDate: _selectedDate,
                            selectedStatus: _taskFilter,
                            availableProjects: availableProjects.toList()
                              ..sort(),
                            onApplyFilters: (project, date, status) {
                              setState(() {
                                _selectedProject = project;
                                _selectedDate = date;
                                _taskFilter = status;
                              });
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              (_selectedProject != null ||
                                  _selectedDate != null)
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 24,
                            ),
                            // Badge indicator when filters are active
                            if (_selectedProject != null ||
                                _selectedDate != null)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Your Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3; // Navigate to Statistics
                    });
                  },
                  child: Text(
                    'See Detail',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Chart
            BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoaded) {
                  return ProgressChart(tasks: state.tasks);
                }
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
            const SizedBox(height: 24),

            // Tasks Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _taskFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _taskFilter = filter;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Tasks List
            BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is TaskError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (state is TaskLoaded) {
                  var filteredTasks = state.tasks;

                  // Apply status filter
                  if (_taskFilter == 'Completed') {
                    filteredTasks = filteredTasks
                        .where((task) => task.isCompleted)
                        .toList();
                  } else if (_taskFilter == 'Incomplete') {
                    filteredTasks = filteredTasks
                        .where((task) => !task.isCompleted)
                        .toList();
                  }

                  // Apply project filter
                  if (_selectedProject != null) {
                    filteredTasks = filteredTasks
                        .where((task) => task.project == _selectedProject)
                        .toList();
                  }

                  // Apply date filter
                  if (_selectedDate != null) {
                    filteredTasks = filteredTasks.where((task) {
                      return task.date.year == _selectedDate!.year &&
                          task.date.month == _selectedDate!.month &&
                          task.date.day == _selectedDate!.day;
                    }).toList();
                  }

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add a new task',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredTasks.map((task) {
                      return TaskCard(
                        task: task,
                        onToggle: () {
                          final updatedTask = Task(
                            id: task.id,
                            title: task.title,
                            description: task.description,
                            date: task.date,
                            startTime: task.startTime,
                            endTime: task.endTime,
                            isCompleted: !task.isCompleted,
                            project: task.project,
                          );
                          context.read<TaskCubit>().updateExistingTask(
                            updatedTask,
                          );
                        },
                        onTap: () {
                          // TODO: Navigate to task details
                        },
                        onDelete: () {
                          context.read<TaskCubit>().deleteExistingTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task deleted'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                }

                return const SizedBox();
              },
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index != 2) {
          // Skip the FAB position
          setState(() {
            _currentIndex = index;
          });
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[400],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded, size: 28),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_rounded, size: 24),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(width: 48), // Space for FAB
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded, size: 28),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded, size: 28),
          label: 'Profile',
        ),
      ],
    );
  }
}
