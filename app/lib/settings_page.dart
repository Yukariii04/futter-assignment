import 'package:flutter/material.dart';
import 'login_page.dart';
import 'api_service.dart' as api;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsOn = true;
  bool soundOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            value: notificationsOn,
            onChanged: (value) {
              setState(() {
                notificationsOn = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Sound'),
            value: soundOn,
            onChanged: (value) {
              setState(() {
                soundOn = value;
              });
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () {
              api.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
