import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gitish_tracker/database.dart';

import '../widgets/habit_day_box.dart';

class HabitHeatMap extends StatefulWidget {
  final Habit habit;

  const HabitHeatMap({super.key, required this.habit});

  @override
  State<HabitHeatMap> createState() => _HabitHeatMapState();
}

class _HabitHeatMapState extends State<HabitHeatMap> {
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

    final gridWidth = viewportWidth;
    const double aspectRatio = 6 / 7;
    final gridHeight = gridWidth / aspectRatio;
    final cellHeight = (gridHeight - (7 - 1) * 4.0) / 7;
    final columnWidth = cellHeight + 4.0;

    if (columnWidth <= 0) return;

    // Get the right-most and left-most visible dates
    final firstColIdx = (position.pixels / columnWidth).floor();
    final lastColIdx = ((position.pixels + viewportWidth) / columnWidth).ceil() - 1;
    final sundayOfThisWeek = DateUtils.dateOnly(DateTime.now())
        .subtract(Duration(days: DateTime.now().weekday % 7));
    final dateRight = sundayOfThisWeek.subtract(Duration(days: 7 * firstColIdx));
    final dateLeft = sundayOfThisWeek.subtract(Duration(days: 7 * lastColIdx));

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthLeftName = months[dateLeft.month - 1];
    final monthRightName = months[dateRight.month - 1];

    if (_leftMonthText != monthLeftName || _rightMonthText != monthRightName) {
      setState(() {
        _leftMonthText = monthLeftName;
        _rightMonthText = monthRightName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final sundayOfThisWeek =
        today.subtract(Duration(days: today.weekday % 7));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                      return HabitDayBox(
                        date: date,
                        habitId: widget.habit.id,
                      );
                    },
                    reverse: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

