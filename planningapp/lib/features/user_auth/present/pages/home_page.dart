import 'package:flutter/material.dart';
import 'package:planningapp/features/user_auth/present/pages/calendar_page.dart';
import 'package:planningapp/features/user_auth/present/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planningapp/features/user_auth/present/pages/task.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String name = user?.displayName ?? "Unknown User";
    final String email = user?.email ?? "No Email";
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
                      Navigator.push( context, MaterialPageRoute(builder: (context) => ProfilePage(email: email, name: name)), );
                    },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildOptionCard(
                    icon: Icons.task,
                    title: "Tasks",
                    onTap: () {
                      Navigator.push( context, MaterialPageRoute(builder: (context) => TaskPage()), );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildOptionCard(
                    icon: Icons.note,
                    title: "Notes",
                    onTap: () {
                      // Navigate to Notes Page
                    },
                  ),
                  SizedBox(height: 20),
                  _buildOptionCard(
                    icon: Icons.calendar_today,
                    title: "Calendar/Reminders",
                    onTap: () {
                      Navigator.push( context, MaterialPageRoute(builder: (context) => CalendarPage()), );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.blue[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue[900]),
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}
