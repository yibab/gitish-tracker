import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gitish_tracker/database.dart';
import 'package:gitish_tracker/pages/settings_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../widgets/day_box.dart';
import 'habits_page.dart';

import 'package:home_widget/home_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _gridScrollController = ScrollController();
  String _leftMonthText = '';
  String _rightMonthText = '';
  
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _gridScrollController.addListener(_updateMonthRange);
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

    final gridWidth = viewportWidth;
    const double aspectRatio = 6 / 7;
    final gridHeight = gridWidth / aspectRatio;
    final cellHeight = (gridHeight - (7 - 1) * 4.0) / 7;
    final columnWidth = cellHeight + 4.0;

    if (columnWidth <= 0) return;

    final firstColIdx = (position.pixels / columnWidth).floor();
    final sundayOfThisWeek = DateUtils.dateOnly(DateTime.now())
        .subtract(Duration(days: DateTime.now().weekday % 7));
    final dateRight =
        sundayOfThisWeek.subtract(Duration(days: 7 * firstColIdx));

    final datePrev = DateTime(dateRight.year, dateRight.month - 1, 1);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HabitsPage())),
            icon: const Icon(Icons.list),
          ),
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsPage())),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: Row(
                children: [
                  Text(_leftMonthText,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Spacer(),
                  Text(_rightMonthText,
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Screenshot(
              controller: screenshotController,
              child: AspectRatio(
                aspectRatio: 6 / 7,
                child: Transform.rotate(
                  angle: pi,
                  child: GridView.builder(
                    controller: _gridScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 365,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                    itemBuilder: (context, index) {
                      final column = index ~/ 7;
                      final row = index % 7;
                      final date = sundayOfThisWeek
                          .add(Duration(days: 6 - row))
                          .subtract(Duration(days: 7 * column));
                      return DayBox(date: date);
                    },
                    reverse: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Habit>>(
              stream: appDatabase.watchAllHabits(),
              builder: (context, habitsSnapshot) {
                final habits = habitsSnapshot.data ?? [];
                if (habits.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No habits yet. Add one on the Habits page!'),
                    ),
                  );
                }
                return StreamBuilder<List<Completion>>(
                    stream: appDatabase.watchCompletionsForDay(today),
                    builder: (context, completionsSnapshot) {
                      final completions = completionsSnapshot.data ?? [];
                      final completedHabitIds =
                          completions.map((c) => c.habitId).toSet();

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          final isChecked =
                              completedHabitIds.contains(habit.id);

                          return ListTile(
                            leading: Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) async {
                                if (value == true) {
                                  appDatabase.addCompletion(habit.id, today);
                                } else {
                                  appDatabase.removeCompletion(habit.id, today);
                                }

                                final bytes = await screenshotController.capture();

                                if (bytes != null) {
                                  final directory =
                                      await getApplicationDocumentsDirectory(); // Use getApplicationDocumentsDirectory for persistent storage
                                  final path =
                                      "${directory.path}/${DateTime.now().toIso8601String()}.png";
                                  final tempFile = File(path);
                                  await tempFile.writeAsBytes(bytes);

                                  // Save the path to HomeWidget and update the widget.
                                  await HomeWidget.saveWidgetData<String>(
                                      'image_path', path);
                                  await HomeWidget.updateWidget(
                                    name: 'HeatmapWidgetProvider',
                                    iOSName:
                                        'HeatmapWidget', // Your iOS widget name
                                  );

                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(
                                  //       content: Text(
                                  //           'Image saved to $path and widget updated')),
                                  // );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Failed to capture image.')));
                                }
                              },
                            ),
                            title: Text(habit.name,
                                style: Theme.of(context).textTheme.headlineSmall),
                          );
                        },
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
