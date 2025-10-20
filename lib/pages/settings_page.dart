import 'package:flutter/material.dart';
import 'package:gitish_tracker/pages/deleted_habits_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Deleted Habits'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeletedHabitsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
