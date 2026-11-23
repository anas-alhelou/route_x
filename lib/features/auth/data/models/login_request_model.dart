// lib/features/auth/data/models/login_request_model.dart

/// Body for `POST /auth/login`.
class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  final String email;
  final String password;

  /// Serializes the request body for `POST /auth/login`.
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
