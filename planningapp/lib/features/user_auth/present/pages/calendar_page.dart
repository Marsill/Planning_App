import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  final Random _random = Random();



  Color _generateRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enhanced Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
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
            eventLoader: (day) => _events[day] ?? [],
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
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
    final events = _events[_selectedDay] ?? [];
    return events.isEmpty
        ? Center(child: Text('No events for this day.'))
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Card(
                color: events[index]['color'],
                child: ListTile(
                  title: Text(events[index]['title']),
                  subtitle: Text(events[index]['description']),
                  trailing: IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      _scheduleNotification(
                        events[index]['title'],
                        _selectedDay!.add(Duration(minutes: 1)),
                      );
                    },
                  ),
                ),
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
                  setState(() {
                    final eventColor = _generateRandomColor();
                    final event = {
                      'title': title,
                      'description': description,
                      'color': eventColor,
                    };
                    if (_events[_selectedDay ?? _focusedDay] == null) {
                      _events[_selectedDay ?? _focusedDay] = [event];
                    } else {
                      _events[_selectedDay ?? _focusedDay]!.add(event);
                    }
                  });
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Events'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(labelText: 'Event Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final query = searchController.text.toLowerCase();
                final results = _events.values.expand((events) {
                  return events.where(
                    (event) => event['title'].toLowerCase().contains(query),
                  );
                }).toList();

                Navigator.pop(context);
                _showSearchResults(results);
              },
              child: Text('Search'),
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

  void _showSearchResults(List<Map<String, dynamic>> results) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Results'),
          content: results.isEmpty
              ? Text('No events found.')
              : SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(results[index]['title']),
                        subtitle: Text(results[index]['description']),
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
  }
}
