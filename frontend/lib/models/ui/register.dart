import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/new_user.dart';
import 'package:frontend/services/new_user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameInput = TextEditingController();
  final TextEditingController lastNameInput = TextEditingController();
  final TextEditingController emailInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();

  // REVERTED: Using the original style constants
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

  // ADDED: Dialog popups for feedback.
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the login page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // REWRITTEN: The registration logic now includes validation and uses the new popups.
  Future<void> registerUser() async {
    final String firstName = firstNameInput.text.trim();
    final String lastName = lastNameInput.text.trim();
    final String email = emailInput.text.trim();
    final String password = passwordInput.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog('Fields Required', 'Please fill in all fields.');
      return;
    }
    if (!_isValidEmail(email)) {
      _showErrorDialog('Invalid Email', 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showErrorDialog('Invalid Password', 'Password must be at least 6 characters long.');
      return;
    }

    _showLoadingDialog('Creating account...');

    try {
      final newUser = NewUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password
      );

      await NewUserService.createUser(newUser);
      
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessDialog('Registration Successful', 'Your account has been created. You can now log in.');

    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('Registration Failed', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( 
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          )
        ),
        child:Center(
        // REVERTED: Using the original layout structure without SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // REVERTED: Using original UI elements
              Image.asset('Assets/Images/logo.png',
                          height: 150,
                          fit: BoxFit.scaleDown ),
              const Text('Laboratory Inventory System',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23)
              ),
              const SizedBox(height: 20),
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
                    child: const Center(
                      child: Text(
                        'Register',
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
              const SizedBox(height: 2),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.blue;
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