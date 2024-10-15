class Password {
  String accountUsername;
  String email;
  String imagePath;
  String password;

  Password({
    required this.accountUsername,
    required this.email,
    required this.imagePath,
    required this.password,
  });

  // Convert a Password object to a Map
  Map<String, dynamic> toJson() {
    return {
      'accountUsername': accountUsername,
      'email': email,
      'imagePath': imagePath,
      'password': password,
    };
  }

  // Create a Password object from a Map
  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      accountUsername: json['accountUsername'],
      email: json['email'],
      imagePath: json['imagePath'],
      password: json['password'],
    );
  }
}
