import 'package:flutter/material.dart';
import '../../firebase_auth/database_services.dart';

class DeadlinePage extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deadlines')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dbService.getDeadlines(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final deadlines = snapshot.data!;
                return ListView.builder(
                  itemCount: deadlines.length,
                  itemBuilder: (context, index) {
                    final deadline = deadlines[index];
                    return ListTile(
                      title: Text(deadline['title']),
                      subtitle: Text(
                          'Due: ${DateTime.fromMillisecondsSinceEpoch(deadline['dueDate'])}'),
                      trailing: Icon(
                        deadline['isCompleted']
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color:
                            deadline['isCompleted'] ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _addDeadline(context),
            child: Text('Add Deadline'),
          ),
        ],
      ),
    );
  }

  Future<void> _addDeadline(BuildContext context) async {
    final deadlineData = {
      'title': 'New Deadline',
      'description': 'Deadline description',
      'dueDate': DateTime.now().add(Duration(days: 2)).millisecondsSinceEpoch,
      'isCompleted': false,
      'priority': 'Medium',
    };
    await _dbService.addDeadline(deadlineData);
  }
}
