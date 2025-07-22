import 'package:flutter/material.dart';
import 'home.dart';
import 'register.dart';
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
  bool _obscurePassword = true;

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
    return Scaffold(
      appBar: AppBar( title: const Text('Biotech Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              //email textfield
              SizedBox(
                width: 400,
                child: TextField(
                  controller: emailInput,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              const SizedBox(height: 20),

              //password textfield
              SizedBox(
                width: 400,
                child: TextField(
                  controller: passwordInput,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
              ),

              const SizedBox(height: 30),

              //login
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: () {
                    print('Email: ${emailInput.text}');
                    print('Password: ${passwordInput.text}');
                    // backend / auth logic here
                    logInUser();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Forgot Password link
              TextButton(
                onPressed: () {
                  _showForgotPasswordDialog();
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //go to register page
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                style: TextButton.styleFrom(
                  //edit this
                ),
                child: const Text(
                  'Register Here',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              //temporary go to home
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: TextButton.styleFrom(
                  //edit this
                ),
                child: const Text(
                  'Go to home (temp)',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}