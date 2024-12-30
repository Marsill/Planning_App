// import 'package:flutter/material.dart';
// import '../../firebase_auth/database_services.dart';

// class TaskPage extends StatelessWidget {
//   final DatabaseService _dbService = DatabaseService();

//   TaskPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tasks'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: _dbService.getTasks(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 final tasks = snapshot.data!;
//                 return ListView.builder(
//                   itemCount: tasks.length,
//                   itemBuilder: (context, index) {
//                     final task = tasks[index];
//                     return Card(
//                       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       elevation: 2,
//                       child: ListTile(
//                         title: Text(task['title']),
//                         subtitle: Text(
//                           'Due: ${DateTime.fromMillisecondsSinceEpoch(task['dueDate'])}',
//                           style: TextStyle(color: Colors.blue),
//                         ),
//                         trailing: Icon(
//                           task['isCompleted']
//                               ? Icons.check_circle
//                               : Icons.circle_outlined,
//                           color: task['isCompleted'] ? Colors.green : Colors.grey,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: () => _addTask(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue, // Button color
//                 foregroundColor: Colors.white, // Text color
//               ),
//               child: Text('Add Task'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _addTask(BuildContext context) async {
//     final taskData = {
//       'title': 'New Task',
//       'dueDate': DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch,
//       'isCompleted': false,
//       'priority': 'High',
//       'notes': 'Task notes',
//     };
//     await _dbService.addTask(taskData);
//   }
// }
