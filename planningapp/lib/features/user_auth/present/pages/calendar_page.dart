import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Random _random = Random();

  CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  @override
  void initState() {
    super.initState();
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
    await eventsCollection.add({
      'title': title,
      'description': description,
      'color': color.value,
      'date': _selectedDay ?? _focusedDay,
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Enhanced Calendar'),
  
      ),
      body: Column(
        children: [
          // Calendar
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
          // Events for the selected day
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
    return StreamBuilder<QuerySnapshot>(
      stream: eventsCollection
          .where('date', isEqualTo: _selectedDay ?? _focusedDay)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final events = snapshot.data!.docs;
        return events.isEmpty
            ? Center(child: Text('No events for this day.'))
            : ListView.builder(
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
                            onPressed: () => _showEditEventDialog(event.id, event['title'], event['description']),
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

