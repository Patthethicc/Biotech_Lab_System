import 'package:flutter/material.dart';
import 'package:frontend/services/edit_profile_user_service.dart';
import 'package:frontend/services/edit_profile_service.dart';
import 'package:frontend/models/api/edit_user_model.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:bcrypt/bcrypt.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isDetailsHovered = false;
  bool _isPasswordHovered = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = await ExistingEditUserService().getUser();
      setState(() {
        firstNameController.text = currentUser.firstName;
        lastNameController.text = currentUser.lastName;
      });
    } catch (e) {
      _showErrorDialog('Failed to Load Data', 'Could not retrieve your profile information. Please try again later.');
    }
  }

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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Success'),
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

  Future<void> _updateUserDetails() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      _showErrorDialog('Fields Required', 'Please fill in both First Name and Last Name.');
      return;
    }

    _showLoadingDialog('Saving details...');

    try {
      final currentUser = await ExistingEditUserService().getUser();

      if (firstName == currentUser.firstName && lastName == currentUser.lastName) {
        Navigator.of(context).pop();
        _showErrorDialog('No Changes', 'You have not made any changes to your name.');
        return;
      }

      final userDetails = EditUser(
        userId: currentUser.userId,
        firstName: firstName,
        lastName: lastName,
        email: currentUser.email,
        password: ""
      );

      final result = await EditProfileService().editUser(userDetails);
      Navigator.of(context).pop(); 

      if (result != null) {
        _showSuccessDialog('User details updated successfully.');
      } else {
        _showErrorDialog('Update Failed', 'Failed to update user details. Please try again.');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog('An Error Occurred', 'An unexpected error occurred. Please try again later.');
    }
  }

  Future<void> _updatePassword() async {
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Fields Required', 'Please fill in all password fields.');
      return;
    } else if (newPassword != confirmPassword) {
      _showErrorDialog('Password Mismatch', 'The passwords do not match.');
      return;
    } else if (newPassword.length < 6) {
      _showErrorDialog('Invalid Password', 'Password must be at least 6 characters long.');
      return;
    }

    _showLoadingDialog('Updating password...');

    try {
      final currentUser = await ExistingEditUserService().getUser();
      
      if (BCrypt.checkpw(newPassword, currentUser.password)) {
        Navigator.of(context).pop(); 
        _showErrorDialog('Same Password', 'The new password cannot be the same as the current password.');
        return;
      }

      final userDetails = EditUser(
        userId: currentUser.userId,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        email: currentUser.email,
        password: newPassword
      );

      final result = await EditProfileService().editUser(userDetails);
      Navigator.of(context).pop(); 
      if (result != null) {
        _showSuccessDialog('Password updated successfully.');
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        _showErrorDialog('Update Failed', 'Failed to update password. Please try again.');
      }
    } catch (e) {
      Navigator.of(context).pop(); 
      _showErrorDialog('An Error Occurred', 'An unexpected error occurred. Please try again later.');
    }
  }
  
  Widget _buildNeumorphicTextField({required TextEditingController controller, required String hintText, bool obscureText = false}) {
    return Neumorphic(
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
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.blueGrey.shade300,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicButton({required VoidCallback onPressed, required String text, required bool isHovered, required ValueChanged<bool> onHover}) {
    return SizedBox(
      height: 40,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: NeumorphicButton(
          onPressed: onPressed,
          style: NeumorphicStyle(
            depth: isHovered ? -4 : 4,
            intensity: 0.8,
            surfaceIntensity: 0.2,
            color: Colors.blue[50],
            shadowDarkColorEmboss: const Color.fromARGB(255, 167, 208, 245),
            shadowLightColorEmboss: const Color.fromARGB(255, 229, 236, 242),
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF01579B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          )
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.6,
                  color: const Color(0xFFE3F2FD),
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                ),
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      const Text('User Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF01579B))),
                      const SizedBox(height: 24),
                      _buildNeumorphicTextField(controller: firstNameController, hintText: 'First Name'),
                      const SizedBox(height: 20),
                      _buildNeumorphicTextField(controller: lastNameController, hintText: 'Last Name'),
                      const SizedBox(height: 30),
                      _buildNeumorphicButton(
                        onPressed: _updateUserDetails,
                        text: 'Save Details',
                        isHovered: _isDetailsHovered,
                        onHover: (value) => setState(() => _isDetailsHovered = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.6,
                  color: const Color(0xFFE3F2FD),
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                ),
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF01579B))),
                      const SizedBox(height: 24),
                      _buildNeumorphicTextField(controller: newPasswordController, hintText: 'New Password', obscureText: true),
                      const SizedBox(height: 20),
                      _buildNeumorphicTextField(controller: confirmPasswordController, hintText: 'Confirm Password', obscureText: true),
                      const SizedBox(height: 30),
                      _buildNeumorphicButton(
                        onPressed: _updatePassword,
                        text: 'Update Password',
                        isHovered: _isPasswordHovered,
                        onHover: (value) => setState(() => _isPasswordHovered = value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}