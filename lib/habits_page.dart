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
  int habitGoal = 1;

  void _incrementHabitGoal() {
    setState(() {
      if (habitGoal < 7) {
        habitGoal++;
      }
    });
  }

  void _decrementHabitGoal() {
    setState(() {
      if (habitGoal > 1) {
        habitGoal--;
      }
    });
  }

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
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                const Text(
                  'Habit Goal Maximum',
                  style: TextStyle(fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _decrementHabitGoal,
                      icon: const Icon(Icons.remove, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '$habitGoal',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: _incrementHabitGoal,
                      icon: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text("Habits", style: Theme.of(context).textTheme.headlineSmall),
          Expanded(
            child: StreamBuilder<List<Habit>>(
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
                    return Dismissible(
                      key: Key(habit.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // Do nothing for now
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        title: Text(habit.name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
