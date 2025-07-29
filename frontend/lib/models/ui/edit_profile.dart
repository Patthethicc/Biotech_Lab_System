import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/services/edit_profile_user_service.dart';
import 'package:frontend/services/edit_profile_service.dart';
import 'package:frontend/models/api/edit_user_model.dart';
import 'package:bcrypt/bcrypt.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final lastNameController = TextEditingController();
    final firstNameController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final NeumorphicStyle fieldStyle = NeumorphicStyle(
      depth: -4,
      intensity: 0.6,
      color: Colors.white,
      shadowLightColorEmboss: const Color.fromARGB(255, 188, 206, 220),
      shadowDarkColorEmboss: const Color.fromARGB(255, 63, 129, 186),
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: 4,
                    intensity: 0.8,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: const Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 400,
                          child: Neumorphic(
                            style: fieldStyle,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                            child: TextField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 400,
                          child: Neumorphic(
                            style: fieldStyle,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                            child: TextField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                hintText: 'Enter your First Name',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 400,
                          child: Neumorphic(
                            style: fieldStyle,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                            child: TextField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                hintText: 'Enter your Last Name',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 400,
                          child: NeumorphicButton(
                            onPressed: () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final currentUser = await ExistingEditUserService().getUser();

                              String username = usernameController.text.trim();
                              String firstName = firstNameController.text.trim();
                              String lastName = lastNameController.text.trim();

                              if (username.isEmpty || firstName.isEmpty || lastName.isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Please fill in all the fields.')),
                                );
                                return;
                              }

                              final userDetails = EditUser(
                                userId: currentUser.userId,
                                firstName: firstName,
                                lastName: lastName,
                                email: username,
                                password: currentUser.password,
                              );

                              final result = await EditProfileService().editUser(userDetails);

                              if (result != null) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('User Details updated successfully')),
                                );

                                usernameController.clear();
                                firstNameController.clear();
                                lastNameController.clear();
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Failed to update User Details')),
                                );
                              }
                            },
                            style: const NeumorphicStyle(
                              color: Color(0xFFE3F2FD),
                              depth: 4,
                              boxShape: NeumorphicBoxShape.stadium(),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF01579B)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Password card
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: 4,
                    intensity: 0.8,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Change Password',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 300,
                          child: Neumorphic(
                            style: fieldStyle,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                            child: TextField(
                              controller: newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'New Password',
                                hintText: 'Enter new password',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300,
                          child: Neumorphic(
                            style: fieldStyle,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                            child: TextField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
                                hintText: 'Confirm New Password',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300,
                          child: NeumorphicButton(
                            onPressed: () async {
                              final currentUser = await ExistingEditUserService().getUser();

                              String newPassword = newPasswordController.text.trim();
                              String confirmPassword = confirmPasswordController.text.trim();

                              final scaffoldMessenger = ScaffoldMessenger.of(context);

                              if (newPassword.isEmpty || confirmPassword.isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Please fill in all password fields.')),
                                );
                                return;
                              } else if (newPassword != confirmPassword) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('The passwords do not match.')),
                                );
                                return;
                              }

                              String hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt(logRounds: 10));

                              final userDetails = EditUser(
                                userId: currentUser.userId,
                                firstName: currentUser.firstName,
                                lastName: currentUser.lastName,
                                email: currentUser.email,
                                password: hashed,
                              );

                              final result = await EditProfileService().editUser(userDetails);

                              if (result != null) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Password updated successfully')),
                                );
                                newPasswordController.clear();
                                confirmPasswordController.clear();
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Failed to update password')),
                                );
                              }
                            },
                            style: const NeumorphicStyle(
                              color: Color(0xFFE3F2FD),
                              depth: 4,
                              boxShape: NeumorphicBoxShape.stadium(),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF01579B)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
