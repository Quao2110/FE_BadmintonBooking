class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;

  RegisterRequest({required this.fullName, required this.email, required this.password, required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
  };
}
