import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:planningapp/features/user_auth/present/widget/custom_sidebar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Random _random = Random();
  User? _currentUser;

  CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Color _generatePastelColor() {
    const int factor = 150;
    return Color.fromARGB(
      255,
      factor + _random.nextInt(106),
      factor + _random.nextInt(106),
      factor + _random.nextInt(106),
    );
  }

  Future<void> _addEvent(String title, String description, Color color) async {
    final userId = _currentUser?.uid;

    if (userId == null) {
      return;
    }

    final event = {
      'title': title,
      'description': description,
      'color': color.value,
      'date': Timestamp.fromDate(_selectedDay ?? _focusedDay),
      'day': DateFormat('yyyy-MM-dd').format(_selectedDay ?? _focusedDay),
      'userId': userId,
    };

    await eventsCollection.add(event);
  }

  Future<void> _editEvent(String id, String title, String description) async {
    await eventsCollection.doc(id).update({
      'title': title,
      'description': description,
    });
  }

  Future<void> _deleteEvent(String id) async {
    await eventsCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSidebar(
      title: 'Calendar',
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList() {
    if (_currentUser == null) {
      return Center(child: CircularProgressIndicator());
    }

    final selectedDayStr = DateFormat('yyyy-MM-dd').format(_selectedDay ?? _focusedDay);

    return StreamBuilder<QuerySnapshot>(
      stream: eventsCollection
          .where('day', isEqualTo: selectedDayStr)
          .where('userId', isEqualTo: _currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No events for this day.'));
        }
        final events = snapshot.data!.docs;
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final eventColor = Color(event['color']);
            return Card(
              color: eventColor,
              child: ListTile(
                title: Text(event['title']),
                subtitle: Text(event['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditEventDialog(
                          event.id, event['title'], event['description']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteEvent(event.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final description = descriptionController.text;
                if (title.isNotEmpty) {
                  _addEvent(title, description, _generatePastelColor());
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(String id, String title, String description) {
    final titleController = TextEditingController(text: title);
    final descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newTitle = titleController.text;
                final newDescription = descriptionController.text;
                if (newTitle.isNotEmpty) {
                  _editEvent(id, newTitle, newDescription);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();
    Timer? _debounce;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Events'),
          content: TextField(
            controller: searchController,
            onChanged: (query) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _showSearchResults(query);
              });
            },
            decoration: InputDecoration(labelText: 'Event Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(String query) {
    final userId = _currentUser?.uid;

    if (userId == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: eventsCollection
              .where('title', isGreaterThanOrEqualTo: query)
              .where('title', isLessThanOrEqualTo: query + '\uf8ff')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            final results = snapshot.data!.docs;
            return AlertDialog(
              title: Text('Search Results'),
              content: results.isEmpty
                  ? Text('No events found.')
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return ListTile(
                            title: Text(result['title']),
                            subtitle: Text(result['description']),
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
