// lib/features/auth/data/models/refresh_token_request_model.dart

/// Body for `POST /auth/refresh`.
class RefreshTokenRequestModel {
  const RefreshTokenRequestModel({required this.refreshToken});

  final String refreshToken;

  /// Serializes the request body for `POST /auth/refresh`.
  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
