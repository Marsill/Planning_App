import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Add a task
  Future<void> addTask(Map<String, dynamic> taskData) async {
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).collection('tasks').add(taskData);
  }

  // Fetch tasks
  Stream<List<Map<String, dynamic>>> getTasks() {
    if (userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                ...doc.data(),
                'id': doc.id,
              };
            }).toList());
  }

  // Update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> updatedTask) async {
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update(updatedTask);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}

class TaskPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data!;
          return tasks.isEmpty
              ? const Center(child: Text('No tasks available. Add a task to get started!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(context, task);
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    final dueDate = task['dueDate'] != null
        ? DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(task['dueDate']))
        : 'No deadline';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['title'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
              ),
            ),
            Text(
              'Due: $dueDate',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        children: [
          if (task['subTasks'] != null && task['subTasks'].isNotEmpty)
            ...task['subTasks'].map<Widget>((subTask) {
              return ListTile(
                title: Text(
                  subTask['title'],
                  style: TextStyle(
                    decoration: subTask['isCompleted'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    subTask['isCompleted'] ? Icons.check_circle : Icons.circle_outlined,
                    color: subTask['isCompleted'] ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => _toggleSubTaskCompletion(task, subTask),
                ),
              );
            }).toList(),
          TextButton(
            onPressed: () => _addSubTask(context, task),
            child: const Text('Add Sub-task'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editTask(context, task),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _firestoreService.deleteTask(task['id']),
              ),
              IconButton(
                icon: Icon(
                  task['isCompleted'] ? Icons.check_circle : Icons.circle_outlined,
                  color: task['isCompleted'] ? Colors.green : Colors.grey,
                ),
                onPressed: () => _toggleCompletion(task),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addTask(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    DateTime? dueDate;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    dueDate = pickedDate;
                  }
                },
                child: const Text('Select Deadline'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final taskData = {
                  'title': titleController.text.trim(),
                  'dueDate': dueDate?.millisecondsSinceEpoch,
                  'isCompleted': false,
                  'subTasks': [],
                };
                await _firestoreService.addTask(taskData);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSubTask(BuildContext context, Map<String, dynamic> task) async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Sub-task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Sub-task Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                final updatedSubTasks = List<Map<String, dynamic>>.from(task['subTasks'] ?? [])
                  ..add({
                    'title': controller.text.trim(),
                    'isCompleted': false,
                  });
                final updatedTask = {
                  ...task,
                  'subTasks': updatedSubTasks,
                };
                await _firestoreService.updateTask(task['id'], updatedTask);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTask(BuildContext context, Map<String, dynamic> task) async {
    final TextEditingController controller =
        TextEditingController(text: task['title']);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Task Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                final updatedTask = {
                  ...task,
                  'title': controller.text.trim(),
                };
                await _firestoreService.updateTask(task['id'], updatedTask);
                Navigator.pop(context);
              },
              child: const Text('Save'),
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
    await _firestoreService.updateTask(task['id'], updatedTask);
  }

  Future<void> _toggleSubTaskCompletion(Map<String, dynamic> task, Map<String, dynamic> subTask) async {
    final updatedSubTasks = List<Map<String, dynamic>>.from(task['subTasks']).map((st) {
      if (st == subTask) {
        return {
          ...st,
          'isCompleted': !st['isCompleted'],
        };
      }
      return st;
    }).toList();

    final updatedTask = {
      ...task,
      'subTasks': updatedSubTasks,
    };

    await _firestoreService.updateTask(task['id'], updatedTask);
  }
}
