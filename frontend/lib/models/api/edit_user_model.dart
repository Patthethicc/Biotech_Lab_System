class EditUser {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  EditUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password});

  factory EditUser.fromJson(Map<String, dynamic> json) {
    return EditUser(
        userId: json['userId'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        password: json['password']
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password
  };
}