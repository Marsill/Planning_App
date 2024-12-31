import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_note_page.dart';// Import the sidebar component
import 'package:planningapp/features/user_auth/present/widget/custom_sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Reference to Firestore collection for notes
    final CollectionReference notesRef = FirebaseFirestore.instance.collection('notes');

    return CustomSidebar(
      title: 'Home Page',
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
