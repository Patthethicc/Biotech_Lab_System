import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/existing_user.dart';
import 'package:frontend/services/existing_user_service.dart';

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  ExistingUser? user;
  bool _isHovered = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    try {
      ExistingUserService existingUserService = ExistingUserService();
      final response = await existingUserService.getUser();
      setState(() {
        user = response;
        _isLoading = false;
        _errorMessage = null;
    });
    } catch (e) {
      setState(() {
        _isLoading = false;
         _errorMessage = 'Failed to load profile: ${e.toString()}';
      });
    }
  
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('View Profile',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
    body: Container( 
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('Assets/Images/bg.png'),
          fit: BoxFit.cover,
        )
      ),
      child:Center(
            child: SizedBox(
              width: 650, 
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: _isLoading
            ? const SizedBox( 
              width: 650,
              height: 280,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(),
              ),
            ),
            ): Column(
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
                        children:[
                          TableRow(children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                              child: Text('Full Name:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                              child: Text('${user!.firstName} ${user!.lastName}', style: TextStyle(fontSize: 18)),
                            ),
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                              child: Text('Email:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                              child: Text('${user!.email}', style: TextStyle(fontSize: 18)),
                            ),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isHovered = true),
                          onExit: (_) => setState(() => _isHovered = false),
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit_profile');
                            },
                            style: NeumorphicStyle(
                              depth: _isHovered ? -4 : 4,
                              intensity: 0.8,
                              surfaceIntensity: 0.2,
                              color: Colors.blue[50],
                              shadowDarkColorEmboss: const Color.fromARGB(255, 167, 208, 245),
                              shadowLightColorEmboss: const Color.fromARGB(255, 229, 236, 242),
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                              lightSource: LightSource.topLeft,
                            ),
                            child: const Center(
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF01579B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    ),
  );
}
}