import 'dart:math';

import 'package:flutter/material.dart';

import '../database.dart';

class HabitDayBox extends StatelessWidget {
  final DateTime date;
  final int habitId;

  const HabitDayBox({required this.date, required this.habitId});

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final isFuture = date.isAfter(today);

    return StreamBuilder<bool>(
      stream: appDatabase.watchIsHabitCompletedOnDay(habitId, date),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        final color = isFuture
            ? Colors.white
            : isCompleted
            ? Colors.green[700]
            : Colors.grey[300];

        return Card(
          color: color,
          shadowColor: Colors.transparent,
          child: Transform.rotate(
            angle: pi,
          ),
        );
      },
    );
  }
}
