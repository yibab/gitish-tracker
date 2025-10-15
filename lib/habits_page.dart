import 'package:flutter/material.dart';
import 'package:gitish_tracker/database.dart';

// A global instance of the database
final AppDatabase appDatabase = AppDatabase();

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            onPressed: () => _showAddHabitDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Habit>>(
        stream: appDatabase.watchAllHabits(),
        builder: (context, snapshot) {
          final habits = snapshot.data ?? [];

          if (habits.isEmpty) {
            return const Center(
              child: Text('No habits yet. Add one!'),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return ListTile(
                title: Text(habit.name),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Habit'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Name of your habit'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = controller.text.trim();
                if (name.isNotEmpty) {
                  appDatabase.addHabit(name);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
