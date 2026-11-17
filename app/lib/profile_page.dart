import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'user.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? photo = profilePhoto;

  void pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      photo = await picked.readAsBytes();
      setState(() {});
    }
  }

  void savePhoto() {
    if (photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo first')),
      );
      return;
    }

    profilePhoto = photo;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = registeredUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),

            CircleAvatar(
              radius: 60,
              backgroundImage: photo != null ? MemoryImage(photo!) : null,
              child: photo == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),

            TextButton(
              onPressed: pickImage,
              child: const Text('Change Photo'),
            ),

            ElevatedButton(
              onPressed: savePhoto,
              child: const Text('Save Photo'),
            ),

            const SizedBox(height: 25),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: Text(user.name),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone'),
                    subtitle: Text(user.phone),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
