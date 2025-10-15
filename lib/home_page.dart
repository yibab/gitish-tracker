import 'package:flutter/material.dart';
import 'package:gitish_tracker/settings_page.dart';
import 'habits_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            if (true)
              Row(
                children: [
                  Text(
                    'Oct',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              )
            else
              const SizedBox(height: 32.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 8,
                children: List.generate(56, (index) {
                  return Card(
                    color: Colors.grey[200],
                    shadowColor: Colors.transparent,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
