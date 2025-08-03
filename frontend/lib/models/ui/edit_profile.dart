import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // profile card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      const SizedBox(height: 32),

                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter your username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            hintText: 'Enter your First Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            hintText: 'Enter your Last Name',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: 400,
                        child: ElevatedButton(
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final currentUser = await ExistingEditUserService().getUser();

                            String username = usernameController.text.trim();
                            String firstName = firstNameController.text.trim();
                            String lastName = lastNameController.text.trim();

                            if (username.isEmpty || firstName.isEmpty || lastName.isEmpty) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Please fill in all the fields.')),
                              );
                              return;
                            }

                              final userDetails = EditUser(
                                  userId: currentUser.userId,
                                  firstName: firstName,
                                  lastName: lastName,
                                  email: username,
                                  password: currentUser.password
                              );

                              final result = await EditProfileService().editUser(userDetails);

                              if (result != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('User Details updated successfully')),
                                );

                                usernameController.clear();
                                firstNameController.clear();
                                lastNameController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update User Details')),
                                );
                              }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // pass card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        child: TextField(
                          controller: newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            hintText: 'Enter new password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Confirm new password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () async {
                            final currentUser = await ExistingEditUserService().getUser();

                            String newPassword = newPasswordController.text.trim();
                            String confirmPassword = confirmPasswordController.text.trim();

                            final scaffoldMessenger = ScaffoldMessenger.of(context);

                            if (newPassword.isEmpty || confirmPassword.isEmpty) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Please fill in all password fields.')),
                              );
                              return;
                            } else if (newPassword != confirmPassword) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('The passwords do not match.')),
                              );
                              return;
                            }
                            String hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt(logRounds: 10));

                            final userDetails = EditUser(
                                  userId: currentUser.userId,
                                  firstName: currentUser.firstName,
                                  lastName: currentUser.lastName,
                                  email: currentUser.email,
                                  password: hashed
                              );

                              final result = await EditProfileService().editUser(userDetails);

                              if (result != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Password updated successfully')),
                                );

                                newPasswordController.clear();
                                confirmPasswordController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update password')),
                                );
                              }
                          },
                          child: const Text('Save'),
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
    );
  }
}