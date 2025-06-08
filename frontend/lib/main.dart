import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'home.dart';

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
      });
  }
}