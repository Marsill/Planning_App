import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_note_page.dart';

class NotesPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser; // Get current user
 final CollectionReference notesRef = FirebaseFirestore.instance.collection('notes');

NotesPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesRef.where('uid', isEqualTo: user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data?.docs ?? [];

          return notes.isEmpty
              ? Center(child: Text('No notes yet. Add a new one!'))
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    var note = notes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(note['title'], style: TextStyle(fontWeight: FontWeight.bold)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditNotePage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
