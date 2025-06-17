import 'dart:ffi';

class ExistingUser {
  final Long user_id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  ExistingUser({
    required this.user_id,
    required this.firstName, 
    required this.lastName,
    required this.email,
    required this.password});

  factory ExistingUser.fromJson(Map<String, dynamic> json) {
    return ExistingUser(
      user_id: json['user_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password']
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': user_id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password
  };
}