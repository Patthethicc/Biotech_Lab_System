import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/pages/Inventory.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/orders.dart';
import 'package:frontend/pages/purchase.dart';
import 'package:frontend/pages/reporting.dart';
import 'package:frontend/pages/settings.dart';
import 'package:frontend/pages/support.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final List<Widget> screens = [
    Dashboard(),
    Inventory(),
    Orders(),
    Purchases(),
    Reporting(),
    Support(),
    Settings()
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 640?BottomNavigationBar(
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blueAccent,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: SvgPicture.asset('Assets/Icons/Dashboard.svg', height: 30, width: 30,), label: "Dashboard"),
          BottomNavigationBarItem(icon: SvgPicture.asset('Assets/Icons/inventory.svg', height: 30, width: 30,), label: "Inventory"),
          BottomNavigationBarItem(icon: SvgPicture.asset('Assets/Icons/orders.svg', height: 30, width: 30,), label: "Orders"),
          BottomNavigationBarItem(icon: SvgPicture.asset('Assets/Icons/purchases.svg', height: 30, width: 30,), label: "Purchases"),
          BottomNavigationBarItem(icon: SvgPicture.asset('Assets/Icons/report.svg', height: 30, width: 30,), label: "Reporting"),
          BottomNavigationBarItem(icon: SvgPicture.asset('Assets/Icons/support.svg', height: 30, width: 30,), label: "Support"),
          BottomNavigationBarItem(icon: SvgPicture.asset('Assets/Icons/settings.svg', height: 30, width: 30,), label: "Settings"),
        ]
        ): null,
        body: Row(
            children: [
              if(MediaQuery.of(context).size.width >= 640)
              NavigationRail(
                onDestinationSelected: (int index) {
                  setState(() {
                    selectedIndex = index; 
                  });
                },
                destinations: [
                  NavigationRailDestination(icon: SvgPicture.asset('Assets/Icons/Dashboard.svg', height: 50, width: 50,), label: Text("Dashboard")),
                  NavigationRailDestination(icon: SvgPicture.asset('Assets/Icons/inventory.svg', height: 50, width: 50,), label: Text("Inventory")),
                  NavigationRailDestination(icon: SvgPicture.asset('Assets/Icons/orders.svg', height: 50, width: 50,), label: Text("Orders")),
                  NavigationRailDestination(icon: SvgPicture.asset('Assets/Icons/purchases.svg', height: 50, width: 50,), label: Text("Purchases")),
                  NavigationRailDestination(icon: SvgPicture.asset('Assets/Icons/report.svg', height: 50, width: 50,), label: Text("Reporting")),
                  NavigationRailDestination(icon: SvgPicture.asset('Assets/Icons/support.svg', height: 50, width: 50,), label: Text("Support")),
                  NavigationRailDestination(icon: SvgPicture.asset('Assets/Icons/settings.svg', height: 50, width: 50,), label: Text("Settings"))
                ], 
                selectedIndex: selectedIndex
                ),
                Expanded(child: screens[selectedIndex])
            ]
          ),
    );
  }
}
