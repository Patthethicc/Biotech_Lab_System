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
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
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
                    //fill ts out
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
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