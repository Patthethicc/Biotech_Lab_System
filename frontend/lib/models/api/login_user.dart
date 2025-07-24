class LogInUser {
  final String email;
  final String password;
  final String? token;
  final bool? check;

  LogInUser({
    required this.email,
    required this.password,
    this.token,
    this.check});

  // Factory for creating login request (only email and password)
  factory LogInUser.forRequest({required String email, required String password}) {
    return LogInUser(
      email: email,
      password: password,
    );
  }

  // Factory for parsing login response from backend
  factory LogInUser.fromJson(Map<String, dynamic> json) {
    // Handle the new response format with nested data
    if (json.containsKey('data')) {
      final data = json['data'];
      return LogInUser(
        email: data['email'],
        password: data['password'],
        token: data['token'],
        check: data['check']
      );
    } else {
      // Handle old flat format (fallback)
      return LogInUser(
        email: json['email'],
        password: json['password'],
        token: json['token'],
        check: json['check']
      );
    }
  }

  // Convert to JSON for request (only email and password)
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  // Convert to full JSON (for response)
  Map<String, dynamic> toFullJson() => {
    'email': email,
    'password': password,
    'token': token,
    'check': check
  };
}