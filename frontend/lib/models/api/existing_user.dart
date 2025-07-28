import 'dart:ffi';

class ExistingUser {
  final Long userId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  ExistingUser({
    required this.userId,
    required this.firstName, 
    required this.lastName,
    required this.email,
    required this.password});

  factory ExistingUser.fromJson(Map<String, dynamic> json) {
    return ExistingUser(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password']
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password
  };
}