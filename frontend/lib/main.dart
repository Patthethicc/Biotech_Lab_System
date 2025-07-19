import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/ui/dashboard.dart';
import 'package:frontend/models/ui/stock_alert.dart';

import 'models/ui/login.dart';
import 'models/ui/register.dart';
import 'models/ui/home.dart';
import 'models/ui/view_profile.dart';
import 'models/ui/edit_profile.dart';
import 'models/ui/purchase_order.dart';
import 'models/ui/transaction_entry_page.dart';
import 'models/ui/inventory_page.dart';
import 'models/ui/item_details.dart';
import 'models/ui/stock_locator.dart';

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
        '/stock_alert': (context) => StockAlert(),
        '/purchase_order': (context) => const PurchaseOrderPage(),
        '/transaction_entry': (context) => TransactionEntryPage(),
        '/inventory': (context) => InventoryPage(),
      //  '/item_details': (context) => ItemDetails(item: item, headers: headers)
        '/stock_locator': (context) => StockLocator()
        //item details 
      },
    );
  }
}
