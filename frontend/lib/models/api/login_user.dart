class LogInUser {
  final String email;
  final String password;
  final bool check;

  LogInUser({
    required this.email,
    required this.password,
    required this.check});

  factory LogInUser.fromJson(Map<String, dynamic> json) {
    return LogInUser(
      email: json['email'],
      password: json['password'],
      check: json['check']
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'check': check
  };
}