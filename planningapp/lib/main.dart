import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planningapp/features/app/splash_screen/splash_screen.dart';
//import 'package:planningapp/features/user_auth/present/pages/home_page.dart';
import 'package:planningapp/features/user_auth/present/pages/login_page.dart';


Future main() async{
  if(kIsWeb){
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBKCg5rXPk7flyziX2ldT5WX4NPls4BHS4", 
        appId: "1:641929499831:web:efc81c7e5594b71c1f2932", 
        messagingSenderId: "641929499831", 
        projectId: "papp-5ac0e"));
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planning',
      home: SplashScreen(
        child: LoginPage(),
      )
    );
  } 
}
