import 'package:flutter/material.dart';
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

    try {
      final response = await NewUserService.createUser(newUser);
      setState(() {
        user = response;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e, User registration unsuccessful')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('Biotech Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              //firstname textfied
              SizedBox(
                width: 400,
                child: TextField(
                  controller: firstNameInput,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your First Name...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

             //lastname textfied
              SizedBox(
                width: 400,
                child: TextField(
                  controller: lastNameInput,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your Last Name...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //email textfield
              SizedBox(
                width: 400,
                child: TextField(
                  controller: emailInput,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email address...',
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
                    hintText: 'Enter your password...',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),

              const SizedBox(height: 30),

              //register
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: () {
                    //for debugging
                    print('First Name: ${firstNameInput.text}');
                    print('Last Name: ${lastNameInput.text}');
                    print('Email: ${emailInput.text}');
                    print('Password: ${passwordInput.text}');
                    // backend / auth logic here
                    registerUser();
                  },
                  style: ElevatedButton.styleFrom(
                    //fill ts out
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //go to back to login page
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  //edit this
                ),
                child: const Text(
                  'Login Here',
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