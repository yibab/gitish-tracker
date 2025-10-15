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
  // The key is the habit's ID, and the value is whether it's checked.
  final Map<int, bool> _checkedHabits = {};
  bool _showMonth = true;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showMonth)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,),
                  child: Text(
                    'Oct',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                )
              else
                const SizedBox(height: 32.0),
              // Adjust height to match text style
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  setState(() {
                    _showMonth = !_showMonth;
                  });
                },
                child: GridView.count(
                  crossAxisCount: 6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(42, (index) {
                    return Card(
                      color: Colors.grey[200],
                      shadowColor: Colors.transparent,
                    );
                  }),
                ),
              ),
              StreamBuilder<List<Habit>>(
                stream: appDatabase.watchAllHabits(),
                // appDatabase is from habits_page
                builder: (context, snapshot) {
                  final habits = snapshot.data ?? [];

                  if (habits.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child:
                            Text('No habits yet. Add one on the Habits page!'),
                      ),
                    );
                  }

                  return ListView.builder(
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
                            habit.name, style: Theme.of(context).textTheme.headlineLarge), // Using default style for better fit
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
