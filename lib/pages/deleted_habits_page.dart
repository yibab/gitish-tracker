import 'package:flutter/material.dart';
import 'package:gitish_tracker/database.dart';

import 'habits_page.dart';

class DeletedHabitsPage extends StatelessWidget {
  const DeletedHabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deleted Habits'),
      ),
      body: StreamBuilder<List<Habit>>(
        stream: appDatabase.watchArchivedHabits(),
        builder: (context, snapshot) {
          final habits = snapshot.data ?? [];

          if (habits.isEmpty) {
            return const Center(
              child: Text('No deleted habits.'),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Dismissible(
                key: Key(habit.id.toString()),
                direction: DismissDirection.endToStart, // Right swipe
                onDismissed: (direction) {
                  appDatabase.restoreHabit(habit.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${habit.name} restored')),
                  );
                },
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.restore, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(habit.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
