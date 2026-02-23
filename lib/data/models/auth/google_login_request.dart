class GoogleLoginRequest {
  final String idToken;
  GoogleLoginRequest({required this.idToken});
  Map<String, dynamic> toJson() => {'idToken': idToken};
}
