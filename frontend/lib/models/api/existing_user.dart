class ExistingUser {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;

  ExistingUser({
    required this.userId,
    required this.firstName, 
    required this.lastName,
    required this.email});

  factory ExistingUser.fromJson(Map<String, dynamic> json) {
    return ExistingUser(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  };
}