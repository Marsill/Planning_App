import 'package:flutter/material.dart';
import '../../firebase_auth/database_services.dart';

class TaskPage extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  title: GestureDetector(
                    onTap: () => _editTask(context, task),
                    child: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: task['isCompleted']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(task['id']),
                      ),
                      IconButton(
                        icon: Icon(
                          task['isCompleted']
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task['isCompleted'] ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => _toggleCompletion(task),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _addTask(BuildContext context) async {
    final taskData = {
      'title': 'New Task',
      'dueDate': DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch,
      'isCompleted': false,
      'priority': 'High',
      'notes': 'Task notes',
    };
    await _dbService.addTask(taskData);
  }

  Future<void> _editTask(BuildContext context, Map<String, dynamic> task) async {
    final TextEditingController controller =
        TextEditingController(text: task['title']);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Task Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedTask = {
                  ...task,
                  'title': controller.text.trim(),
                };
                await _dbService.updateTask(task['id'], updatedTask);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleCompletion(Map<String, dynamic> task) async {
    final updatedTask = {
      ...task,
      'isCompleted': !task['isCompleted'],
    };
    await _dbService.updateTask(task['id'], updatedTask);
  }

  Future<void> _deleteTask(String taskId) async {
    await _dbService.deleteTask(taskId);
  }
}
