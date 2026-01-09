import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class AnimatedNotificationIcon extends StatefulWidget {
  final int activeTasksCount;
  final VoidCallback onTap;
  final DateTime? lastTaskStartTime;

  const AnimatedNotificationIcon({
    super.key,
    required this.activeTasksCount,
    required this.onTap,
    this.lastTaskStartTime,
  });

  @override
  State<AnimatedNotificationIcon> createState() =>
      _AnimatedNotificationIconState();
}

class _AnimatedNotificationIconState extends State<AnimatedNotificationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Timer? _shakeTimer;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    _setupShakeAnimation();
  }

  void _setupShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedNotificationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger shake animation when a new task starts
    if (widget.lastTaskStartTime != null &&
        widget.lastTaskStartTime != oldWidget.lastTaskStartTime) {
      _triggerShakeAnimation();
    }
  }

  void _triggerShakeAnimation() {
    // Prevent multiple shakes in quick succession
    final now = DateTime.now();
    if (_lastShakeTime != null &&
        now.difference(_lastShakeTime!).inSeconds < 2) {
      return;
    }

    _lastShakeTime = now;
    _shakeTimer?.cancel();

    // Shake for 3 seconds
    int shakeCount = 0;
    _shakeTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (shakeCount < 5 && mounted) {
        // Shake 5 times in 3 seconds
        _shakeController.forward(from: 0.0);
        shakeCount++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _shakeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveTasks = widget.activeTasksCount > 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          // Calculate shake offset
          final shakeValue = math.sin(_shakeAnimation.value * math.pi * 4) * 8;

          return Transform.translate(
            offset: Offset(shakeValue, 0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Icon Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasActiveTasks
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasActiveTasks
                          ? Theme.of(context).primaryColor.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      hasActiveTasks
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      size: 24,
                      color: hasActiveTasks
                          ? Theme.of(context).primaryColor
                          : Colors.grey[700],
                      key: ValueKey(hasActiveTasks),
                    ),
                  ),
                ),

                // Badge with count
                if (hasActiveTasks)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.activeTasksCount > 9
                                    ? '9+'
                                    : '${widget.activeTasksCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
