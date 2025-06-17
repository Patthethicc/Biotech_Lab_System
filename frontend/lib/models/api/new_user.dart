class NewUser {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  NewUser({
    required this.firstName, 
    required this.lastName,
    required this.email,
    required this.password});

  factory NewUser.fromJson(Map<String, dynamic> json) {
    return NewUser(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password']
    );
  }

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password
  };
}