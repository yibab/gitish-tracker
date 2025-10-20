import 'dart:math';

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
  final ScrollController _gridScrollController = ScrollController();
  String _leftMonthText = '';
  String _rightMonthText = '';

  @override
  void initState() {
    super.initState();
    _gridScrollController.addListener(_updateMonthRange);
    // Calculate the initial range after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMonthRange());
  }

  @override
  void dispose() {
    _gridScrollController.removeListener(_updateMonthRange);
    _gridScrollController.dispose();
    super.dispose();
  }

  void _updateMonthRange() {
    if (!_gridScrollController.hasClients || !context.mounted) return;

    final position = _gridScrollController.position;
    final viewportWidth = position.viewportDimension;

    // Calculate the width of a single column in the grid.
    final gridWidth = viewportWidth;
    const double aspectRatio = 6 / 7;
    final gridHeight = gridWidth / aspectRatio;
    final cellHeight = (gridHeight - (7 - 1) * 4.0) / 7;
    final columnWidth = cellHeight + 4.0; // Cell is square, add spacing

    if (columnWidth <= 0) return;

    // Find the index of the first visible column on the right.
    final firstColIdx = (position.pixels / columnWidth).floor();

    // Determine the date for the rightmost visible column.
    final sundayOfThisWeek = DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: DateTime.now().weekday % 7));
    final dateRight = sundayOfThisWeek.subtract(Duration(days: 7 * firstColIdx));

    // Determine the month before.
    final datePrev = DateTime(dateRight.year, dateRight.month - 1, 1);

    // Format the date range string.
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthPrevName = months[datePrev.month - 1];
    final monthRightName = months[dateRight.month - 1];

    if (_leftMonthText != monthPrevName || _rightMonthText != monthRightName) {
      setState(() {
        _leftMonthText = monthPrevName;
        _rightMonthText = monthRightName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final sundayOfThisWeek = today.subtract(Duration(days: today.weekday % 7));

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    _leftMonthText,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  Text(
                    _rightMonthText,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 6 / 7,
              child: Transform.rotate(
                angle: pi,
                child: GridView.builder(
                  controller: _gridScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 365,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                  itemBuilder: (context, index) {
                    final column = index ~/ 7;
                    final row = index % 7;
                    final date = sundayOfThisWeek.add(Duration(days: 6 - row)).subtract(Duration(days: 7 * column));
                    return DayBox(date: date);
                  },
                  reverse: false,
                ),
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
