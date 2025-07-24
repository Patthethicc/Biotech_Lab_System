import 'package:flutter/material.dart';
import 'home.dart';
import 'register.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/login_user.dart';
import 'package:frontend/services/login_user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();
  final storage = FlutterSecureStorage();
  bool _isHovered = false;

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

  @override
  void dispose() {
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }

  Future<void> logInUser() async {
    final logInUser = LogInUser(
      email: emailInput.text,
      password: passwordInput.text,
      token: "temp",
      check: false
    );

    try {
      final response = await LogInUserService.logInUser(logInUser);

        if(response.check) {
          await storage.write(key: 'jwt_token', value: response.token);
          setState(() {
            Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                  );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User Logged In successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e, User log in unsuccessful')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // common style constants
    // final OutlineInputBorder blueBorder = OutlineInputBorder(
    //   borderSide: const BorderSide(color: Color(0xFF01579B), width: 1.8), // dark blue
    //   borderRadius: BorderRadius.circular(12),
    // );

    return Scaffold(
      body: Container( 
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          )
        ),
        child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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

              const SizedBox(height: 30),

              // Email TextField
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
                      // labelText: 'Email Address',
                      hintText: 'Email',
                      border: InputBorder.none,
                      // labelStyle: labelStyle,
                      hintStyle: hintStyle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password TextField
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
                      // labelText: 'Password',
                      hintText: 'Password',
                      border: InputBorder.none,
                      labelStyle: labelStyle,
                      hintStyle: hintStyle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              //login
              SizedBox(
                width: 400,
                height: 40,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: NeumorphicButton(
                    onPressed: logInUser,
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
                        'Login',
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

              //go to register page
              Container(
                margin: const EdgeInsets.only(top: 8), // Space above the button
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent), // No grey on hover
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.blue; // Color on hover (optional)
                      }
                      return Color(0xFF01579B);
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
                  child: const Text('Create Account'),
                ),
              ),


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
     )
    );
  }
}