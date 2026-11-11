import 'package:flutter/material.dart';

import 'api_service.dart' as api;
import 'profile_page.dart';
import 'user.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<dynamic> notes = [];
  bool loading = true;

  void loadNotes() async {
    try {
      notes = await api.getNotes();
      loading = false;
      setState(() {});
    } catch (e) {
      loading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load notes')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void showNoteDialog({Map? note}) {
    final controller = TextEditingController();

    if (note != null) {
      controller.text = note['content'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'New Note' : 'Edit Note'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Write your note here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.dispose();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String text = controller.text.trim();

                if (text.isEmpty) return;

                Navigator.pop(context);

                bool result;

                if (note == null) {
                  result = await api.createNote(text);
                } else {
                  result = await api.updateNote(note['_id'], text);
                }

                if (result) {
                  loadNotes();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Operation failed')),
                  );
                }

                controller.dispose();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteNote(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                bool result = await api.deleteNote(id);

                if (result) {
                  loadNotes();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delete failed')),
                  );
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              ).then((value) {
                setState(() {});
              });
            },
            icon: CircleAvatar(
              radius: 18,
              backgroundImage: profilePhoto != null
                  ? MemoryImage(profilePhoto!)
                  : null,
              child: profilePhoto == null
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(
                  child: Text(
                    'No notes yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    return Card(
                      child: ListTile(
                        title: Text(note['content']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                showNoteDialog(note: note);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteNote(note['_id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNoteDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
