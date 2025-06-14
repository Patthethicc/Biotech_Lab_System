import 'package:flutter/material.dart';
import 'package:frontend/dashboard.dart';

import 'login.dart';
import 'register.dart';
import 'home.dart';
import 'view_profile.dart';
import 'edit_profile.dart';

void main (){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{ 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/view_profile': (context) => ViewProfilePage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/dashboard': (context) => Dashboard()
      },
    );
  }
}