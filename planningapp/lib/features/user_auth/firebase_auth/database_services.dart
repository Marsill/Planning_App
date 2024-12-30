import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Add a task associated with the user
  Future<void> addTask(Map<String, dynamic> taskData) async {
    if (userId == null) return; // Ensure user is logged in
    await _dbRef.child('users/$userId/tasks').push().set(taskData);
  }

  // Fetch tasks associated with the user
  Stream<List<Map<String, dynamic>>> getTasks() {
    if (userId == null) return Stream.value([]);
    return _dbRef.child('users/$userId/tasks').onValue.map((event) {
      final tasks = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return tasks.entries.map((e) {
        final task = e.value as Map<dynamic, dynamic>;
        task['id'] = e.key;
        return Map<String, dynamic>.from(task);
      }).toList();
    });
  }

  // Add a deadline associated with a task
  Future<void> addDeadline(String taskId, Map<String, dynamic> deadlineData) async {
    if (userId == null) return; // Ensure user is logged in
    await _dbRef.child('users/$userId/tasks/$taskId/deadlines').push().set(deadlineData);
  }

  // Fetch deadlines for a specific task
  Stream<List<Map<String, dynamic>>> getDeadlines(String taskId) {
    if (userId == null) return Stream.value([]);
    return _dbRef.child('users/$userId/tasks/$taskId/deadlines').onValue.map((event) {
      final deadlines = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return deadlines.entries.map((e) {
        final deadline = e.value as Map<dynamic, dynamic>;
        deadline['id'] = e.key;
        return Map<String, dynamic>.from(deadline);
      }).toList();
    });
  }
}
