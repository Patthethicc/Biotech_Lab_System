import 'package:flutter/material.dart';
import 'login.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar( title: const Text('Biotech Home')),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[

            //top of the drawer
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 71, 129),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Biotech App', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              title: const Text('View Profile',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/view_profile');
              },
            ),
            ListTile(
              title: const Text('Log out',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()), 
                  (route) => false, // goes back to login, and removes this route from the route stack
                );
              },
            )
          ],
        )
      )
    );
  }
}