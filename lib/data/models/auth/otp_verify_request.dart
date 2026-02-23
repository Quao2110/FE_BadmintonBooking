class OtpVerifyRequest {
  final String email;
  final String otp;
  OtpVerifyRequest({required this.email, required this.otp});
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}
