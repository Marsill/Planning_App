import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditNotePage extends StatefulWidget {
  final String? noteId;
  final QueryDocumentSnapshot? note;

  const AddEditNotePage({this.noteId, this.note});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _content;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!['title'];
      _content = widget.note!['content'];
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final notesRef = FirebaseFirestore.instance.collection('notes');
      final user = FirebaseAuth.instance.currentUser;

      if (widget.noteId == null) {
        // Add new note
        await notesRef.add({
          'title': _title,
          'content': _content,
          'uid': user?.uid, // Associate note with the user
        });
      } else {
        // Update existing note
        await notesRef.doc(widget.noteId).update({
          'title': _title,
          'content': _content,
        });
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Add Note' : 'Edit Note'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Title cannot be empty' : null,
                onSaved: (value) => _title = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _content,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Content cannot be empty' : null,
                onSaved: (value) => _content = value,
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _saveNote,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
