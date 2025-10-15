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
  // A map to store the checked state of each habit.
  final Map<int, bool> _checkedHabits = {};
  final bool _showMonth = true; // The month will now always be shown

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
              const SizedBox(height: 48.0), // Match headlineSmall height + padding

            AspectRatio(
              // This forces the container to a 6-wide by 7-high ratio,
              // which will keep the cells inside square.
              aspectRatio: 6 / 7,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 7 rows
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                ),
                itemBuilder: (context, index) {
                  // The grid now infinitely scrolls to the left (by reversing the list)
                  return Card(
                    color: Colors.green[700],
                    shadowColor: Colors.transparent,
                  );
                },
                // By not providing an itemCount, the grid becomes infinite.
                reverse: true, // This makes the grid scroll infinitely to the left.
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
