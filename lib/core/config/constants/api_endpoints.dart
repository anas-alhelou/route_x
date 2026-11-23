// lib/core/constants/api_endpoints.dart

/// Central registry for every backend endpoint the app talks to.
///
/// The base URL is configurable at build/run time via `--dart-define` so it
/// never needs to be hardcoded in more than one place:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=https://staging.example.com
/// ```
class ApiEndpoints {
  ApiEndpoints._(); // prevent instantiation

  /// Render.com-hosted gateway. The instance may spin down when idle, so the
  /// first request after inactivity can take 30–50s (see DioClient timeouts).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Previous gateway used on feature/integration-all-features:
    //   https://backend-gateway-wdzv.onrender.com
    // Override at build time with --dart-define=API_BASE_URL=...
    defaultValue: 'https://backend-repo-0y6z.onrender.com',
  );

  // ── Auth ──────────────────────────────────────────────────────────────
  /// `POST /auth/register` — creates the account (inactive) and triggers the
  /// verification email. This is the one place to point the sign-up request at
  /// a different endpoint; nothing else hardcodes the path.
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/auth/logout';

  // ── Orders ────────────────────────────────────────────────────────────
  static const String orders = '/orders';
  static const String ordersMine = '/orders/mine';
  static const String ordersAccept = '/orders/accept';
  static const String ordersReject = '/orders/reject';
  static const String ordersStartDelivery = '/orders/start-delivery';
  static const String ordersDeliver = '/orders/deliver';
  static const String ordersStatus = '/orders/status';
  static String orderDeliveryProof(String id) => '/orders/$id/delivery-proof';

  // ── Live tracking ─────────────────────────────────────────────────────
  static const String trackingSession = '/tracking/session';
  static const String trackingLocation = '/tracking/location';
  static const String trackingSessionEnd = '/tracking/session/end';

  // ── Route & Fleet ─────────────────────────────────────────────────────
  static const String companiesSearch = '/companies/search';
  static const String driversJoin = '/drivers/join';
  static const String driversJoinByCode = '/drivers/join-by-code';
}
