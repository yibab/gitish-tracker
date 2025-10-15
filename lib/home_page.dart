import 'package:flutter/material.dart';
import 'package:gitish_tracker/database.dart';
import 'package:gitish_tracker/settings_page.dart';
import 'habits_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<int, bool> _checkedHabits = {};
  final bool _showMonth = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HabitsPage()),
              );
            },
            icon: const Icon(Icons.list),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showMonth)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                child: Text(
                  'Oct 2025',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              )
            else
              const SizedBox(height: 48.0),

            AspectRatio(
              aspectRatio: 6 / 7,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                ),
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(Duration(days: index));
                  return DayBox(date: date);
                },
                reverse: true,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Habit>>(
              stream: appDatabase.watchAllHabits(),
              builder: (context, snapshot) {
                final habits = snapshot.data ?? [];
                if (habits.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No habits yet. Add one on the Habits page!'),
                    ),
                  );
                }
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final isChecked = _checkedHabits[habit.id] ?? false;

                    return ListTile(
                      leading: Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _checkedHabits[habit.id] = value ?? false;
                          });

                          if (value == true) {
                            appDatabase.addCompletion(habit.id, DateTime.now());
                          } else {
                            appDatabase.removeCompletion(habit.id, DateTime.now());
                          }
                        },
                      ),
                      title: Text(
                        habit.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// This is the new DayBox widget that handles its own color.
class DayBox extends StatelessWidget {
  final DateTime date;

  const DayBox({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: appDatabase.watchHabitGoal(),
      builder: (context, goalSnapshot) {
        final habitGoal = goalSnapshot.data ?? 1;

        return StreamBuilder<int>(
          stream: appDatabase.watchCompletionCountForDay(date),
          builder: (context, completionSnapshot) {
            final completions = completionSnapshot.data ?? 0;
            final color = _getColorForDay(completions, habitGoal);

            return Card(
              color: color,
              shadowColor: Colors.transparent,
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
    if (percentage >= 0.85) return Colors.green[600]!;
    if (percentage >= 0.7) return Colors.green[500]!;
    if (percentage >= 0.55) return Colors.green[400]!;
    if (percentage >= 0.4) return Colors.green[300]!;
    if (percentage >= 0.25) return Colors.green[200]!;
    return Colors.green[100]!;
  }
}
