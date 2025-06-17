import 'package:flutter/material.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Profile')),
      body: Center(
        child: SizedBox(
          width: 650, 
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueGrey,
                      ),
                      child: const Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: const [
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24), // Reduced vertical padding
                          child: Text('Username:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('johndoe', style: TextStyle(fontSize: 18)),
                        ),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('Role:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('Lab Technician', style: TextStyle(fontSize: 18)),
                        ),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('Full Name:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('John Doe', style: TextStyle(fontSize: 18)),
                        ),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('Email:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('johndoe@biotech.com', style: TextStyle(fontSize: 18)),
                        ),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('Department:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('Genetics', style: TextStyle(fontSize: 18)),
                        ),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('Employee ID:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Text('BT12345', style: TextStyle(fontSize: 18)),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/edit_profile');
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}