import 'dart:math';

import 'package:flutter/material.dart';

import '../database.dart';

class DayBox extends StatelessWidget {
  final DateTime date;

  const DayBox({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final isFuture = date.isAfter(today);

    return StreamBuilder<int>(
      stream: appDatabase.watchHabitGoal(),
      builder: (context, goalSnapshot) {
        final habitGoal = goalSnapshot.data ?? 1;

        return StreamBuilder<int>(
          stream: appDatabase.watchCompletionCountForDay(date),
          builder: (context, completionSnapshot) {
            final completions = completionSnapshot.data ?? 0;
            final color = isFuture ? Colors.white : _getColorForDay(completions, habitGoal);

            return Card(
              color: color,
              shadowColor: Colors.transparent,
              child: Transform.rotate(
                angle: pi,
                child: Center(
                  child: Text(isFuture ? '' : '${date.day}'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getColorForDay(int completions, int goal) {
    if (completions == 0) {
      return Colors.grey[300]!;
    }

    final double percentage = completions / goal;

    if (percentage >= 1.0) return Colors.green[700]!;
    if (percentage >= 0.75) return Colors.green[600]!;
    if (percentage >= 0.6) return Colors.green[500]!;
    if (percentage >= 0.45) return Colors.green[400]!;
    if (percentage >= 0.3) return Colors.green[300]!;
    if (percentage >= 0.15) return Colors.green[200]!;
    return Colors.green[100]!;
  }
}