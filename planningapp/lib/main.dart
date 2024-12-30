import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planningapp/features/user_auth/present/pages/home_page.dart';
import 'package:planningapp/features/user_auth/present/pages/login_page.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Planning App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}