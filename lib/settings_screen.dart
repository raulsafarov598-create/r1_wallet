import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Профиль'),
            subtitle: Text('Имя, аватар, язык'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Безопасность'),
            subtitle: Text('PIN, биометрия (позже)'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('О приложении'),
            subtitle: Text('R1 Wallet • beta'),
          ),
        ],
      ),
    );
  }
}

