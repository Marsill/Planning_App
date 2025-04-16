import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planningapp/features/user_auth/present/task.dart';
import 'profile.dart';
import 'login_page.dart';
import 'add_edit_note_page.dart';
import 'calander.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final String userEmail = currentUser?.email ?? "default@example.com";
    final String userName = currentUser?.displayName ?? "Default User";

    final CollectionReference notesRef = FirebaseFirestore.instance.collection('notes');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[300],
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Icon(
                  Icons.menu,
                  size: 64,
                ),
              ),
            ),
            // Home Navigation
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Calendar"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box),
              title: const Text("Task"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskPage(),
                  ),
                );
              },
            ),
            // Profile Navigation
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      email: userEmail,
                      name: userName,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            // Logout Option
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false, // This clears the entire navigation stack
                );
                print("User Logged Out");
              },
            ),
          ],
        ),
      ),



      body: Column(
        children: [
          // StreamBuilder to display notes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: notesRef.where('uid', isEqualTo: currentUser?.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data?.docs ?? [];

                return notes.isEmpty
                    ? const Center(child: Text('No notes yet. Add a new one!'))
                    : ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          var note = notes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              title: Text(note['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(note['content'], maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditNotePage(noteId: note.id, note: note),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditNotePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
