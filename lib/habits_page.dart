import 'package:flutter/material.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  int habitGoal = 1;

  void _incrementHabitGoal() {
    setState(() {
      if (habitGoal < 10) {
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
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Column(
            children: [
              const Text('Habit Goal Maximum', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
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
                      style: Theme.of(context).textTheme.headlineLarge,
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
          SizedBox(height: 15),
          Text('Your Habits', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
