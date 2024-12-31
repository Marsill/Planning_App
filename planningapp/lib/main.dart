import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planningapp/features/user_auth/present/pages/calendar_page.dart';
import 'package:planningapp/features/user_auth/present/pages/home_page.dart';
import 'package:planningapp/features/user_auth/present/pages/login_page.dart';
import 'package:planningapp/features/user_auth/present/pages/notes_page.dart';
import 'package:planningapp/features/user_auth/present/pages/profile.dart';
import 'package:planningapp/features/user_auth/present/pages/task.dart';

Future main() async{
  if(kIsWeb){
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAvsPGaJ5A9FTjfxv8PbvAYpDTnmG7RkNU", 
        appId: "1:1510453481:web:ecc04df799dd2f65970078", 
        messagingSenderId: "1510453481", 
        projectId: "planning-app-73010"));
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planning App',
      initialRoute: '/login_page',
      routes: {
        '/': (context) => HomePage(),
        '/task': (context) => TaskPage(),
        '/calendar_page': (context) => CalendarPage(),
        '/notes_page': (context) => NotesPage(),
        '/login_page': (context) => LoginPage(),
        '/profile_page': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return ProfilePage(
            email: args['email'],
            name: args['name'],
          );
        },
      },
      onGenerateRoute: (RouteSettings settings) {
        // Handle any undefined routes gracefully
        return null;
      },
    );
  }
}
