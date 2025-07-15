import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/ui/dashboard.dart';
import 'package:frontend/models/ui/stock_alert.dart';

import 'models/ui/login.dart';
import 'models/ui/register.dart';
import 'models/ui/home.dart';
import 'models/ui/view_profile.dart';
import 'models/ui/edit_profile.dart';
import 'models/ui/data_recording.dart';
import 'models/ui/purchase_order.dart';

void main() async{
  await dotenv.load(fileName: ".env");
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
        '/dashboard': (context) => Dashboard(),
        '/data_recording': (context) => DataRecording(),
        '/stock_alert': (context) => StockAlert(),
        '/purchase_order': (context) => const PurchaseOrderPage(),
      },
    );
  }
}