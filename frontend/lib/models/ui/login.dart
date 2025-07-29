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
    // Validate input fields
    if (emailInput.text.trim().isEmpty) {
      _showErrorDialog(
        'Email Required', 
        'Please enter your email address.'
      );
      return;
    }

    if (passwordInput.text.trim().isEmpty) {
      _showErrorDialog(
        'Password Required', 
        'Please enter your password.'
      );
      return;
    }

    // Basic email format validation
    if (!_isValidEmail(emailInput.text.trim())) {
      _showErrorDialog(
        'Invalid Email', 
        'Please enter a valid email address.'
      );
      return;
    }

    // Show loading indicator
    _showLoadingDialog();

    // Use the new factory method for request
    final logInUser = LogInUser.forRequest(
      email: emailInput.text.trim(),
      password: passwordInput.text,
    );

    try {
      final response = await LogInUserService.logInUser(logInUser);

      // Hide loading dialog
      Navigator.of(context).pop();

      if(response.check == true) {
        await storage.write(key: 'jwt_token', value: response.token);
        
        // Show success message briefly
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Welcome back.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showErrorDialog(
          'Login Failed', 
          'The email address or password you entered is incorrect. Please check your credentials and try again.'
        );
      }
    } catch (e) {
      // Hide loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      String errorMessage = e.toString();
      String title = 'Login Error';
      String message = 'An unexpected error occurred. Please try again.';
      
      // Parse specific error messages
      if (errorMessage.contains('Invalid email address or password') || 
          errorMessage.contains('Invalid email or password') ||
          errorMessage.contains('Invalid credentials')) {
        title = 'Invalid Credentials';
        message = 'The email address or password you entered is incorrect.\n\nPlease check:\n• Your email address is spelled correctly\n• Your password is correct\n• Caps Lock is not turned on';
      } else if (errorMessage.contains('Email address is required') || 
                 errorMessage.contains('Email cannot be null or empty')) {
        title = 'Email Required';
        message = 'Please enter your email address.';
      } else if (errorMessage.contains('Password is required') || 
                 errorMessage.contains('Password cannot be null or empty')) {
        title = 'Password Required';
        message = 'Please enter your password.';
      } else if (errorMessage.contains('Please enter a valid email address')) {
        title = 'Invalid Email Format';
        message = 'Please enter a valid email address (e.g., user@example.com).';
      } else if (errorMessage.contains('Cannot connect to server')) {
        title = 'Connection Error';
        message = 'Unable to connect to the server. Please check your internet connection and try again.';
      } else if (errorMessage.contains('Server error')) {
        title = 'Server Error';
        message = 'The server is currently experiencing issues. Please try again in a few moments.';
      }
      
      _showErrorDialog(title, message);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Signing in...'),
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

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Forgot Password?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address and we\'ll help you reset your password.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: Password reset functionality is not yet implemented. Please contact your system administrator for assistance.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset feature coming soon. Please contact your administrator.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    ).then((_) {
      emailController.dispose();
    });
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