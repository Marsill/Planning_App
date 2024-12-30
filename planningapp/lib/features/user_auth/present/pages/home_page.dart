// import 'package:flutter/material.dart';
// import 'deadline_page.dart';
// import 'task.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//   final List<Widget> _pages = [
//     TaskPage(),
//     DeadlinePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
//           BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Deadlines'),
//         ],
//       ),
//     );
//   }
// }
