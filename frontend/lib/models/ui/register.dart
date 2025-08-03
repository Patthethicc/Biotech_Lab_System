import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'home.dart';
import 'package:frontend/models/api/new_user.dart';
import 'package:frontend/services/new_user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  NewUser? user;
  final TextEditingController firstNameInput = TextEditingController();
  final TextEditingController lastNameInput = TextEditingController();
  final TextEditingController emailInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();

  final NeumorphicStyle fieldStyle = NeumorphicStyle(
    depth: -3,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
    color: const Color(0xFFF2F4F8),
    intensity: 0.7,
    shadowDarkColor: Colors.grey.shade400,
    shadowLightColor: Colors.white,
  );

  final TextStyle labelStyle = const TextStyle(
    color: Color(0xFF01579B),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  final TextStyle hintStyle = TextStyle(
    color: Colors.blueGrey.shade300,
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  bool _isHovered = false;

  @override
  void dispose() {
    firstNameInput.dispose();
    lastNameInput.dispose();
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    final newUser = NewUser(
      firstName: firstNameInput.text,
      lastName: lastNameInput.text,
      email: emailInput.text,
      password: passwordInput.text
    );

      final response = await NewUserService.createUser(newUser);
      setState(() {
        user = response;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( 
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          )
        ),
        child:Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Image.asset('Assets/Images/logo.png',
                          height: 150,
                          fit: BoxFit.scaleDown ),
              Text('Laboratory Inventory System',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23)
              ),

              const SizedBox(height: 20),

              // First Name Field
              SizedBox(
                width: 400,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -4,
                    intensity: 0.6,
                    color: Colors.white,
                    shadowLightColorEmboss: const Color.fromARGB(255, 188, 206, 220),
                    shadowDarkColorEmboss: const Color.fromARGB(255, 63, 129, 186),
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
                  child: TextField(
                    controller: firstNameInput,
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      border: InputBorder.none,
                      hintStyle: hintStyle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Last Name Field
              SizedBox(
                width: 400,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -4,
                    intensity: 0.6,
                    color: Colors.white,
                    shadowLightColorEmboss: const Color.fromARGB(255, 188, 206, 220),
                    shadowDarkColorEmboss: const Color.fromARGB(255, 63, 129, 186),
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
                  child: TextField(
                    controller: lastNameInput,
                    decoration: InputDecoration(
                      hintText: 'Last Name',
                      border: InputBorder.none,
                      hintStyle: hintStyle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              SizedBox(
                width: 400,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -4,
                    intensity: 0.6,
                    color: Colors.white,
                    shadowLightColorEmboss: const Color.fromARGB(255, 188, 206, 220),
                    shadowDarkColorEmboss: const Color.fromARGB(255, 63, 129, 186),
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
                  child: TextField(
                    controller: emailInput,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      border: InputBorder.none,
                      hintStyle: hintStyle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Field
              SizedBox(
                width: 400,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -4,
                    intensity: 0.6,
                    color: Colors.white,
                    shadowLightColorEmboss: const Color.fromARGB(255, 188, 206, 220),
                    shadowDarkColorEmboss: const Color.fromARGB(255, 63, 129, 186),
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
                  child: TextField(
                    controller: passwordInput,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: InputBorder.none,
                      hintStyle: hintStyle,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 30),

              // Register
              SizedBox(
                width: 400,
                height: 40,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: NeumorphicButton(
                    onPressed: registerUser,
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
                    // padding: const EdgeInsets.symmetric(vertical: 10), // Shorter height
                    child: const Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF01579B), // Dark blue text
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              //go to back to login page
              Container(
                margin: const EdgeInsets.only(top: 8), // Add spacing above
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.blue; // Optional: hover color
                      }
                      return Colors.blue[800];
                    }),
                    textStyle: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        );
                      }
                      return const TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      );
                    }),
                  ),
                  child: const Text('Login Here'),
                ),
              ),


              const SizedBox(height: 20),
            ],
          ),
        ),
       ),
      ),
    );
  }
}