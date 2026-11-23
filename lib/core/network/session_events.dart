import 'package:flutter/foundation.dart';

/// Raised when the API session is gone for good (the access token was refused
/// and the refresh token could not renew it). The app listens once and sends
/// the driver back to Login instead of leaving them on a screen that can no
/// longer load anything.
abstract final class SessionEvents {
  static final ValueNotifier<int> expired = ValueNotifier<int>(0);

  static void notifyExpired() => expired.value++;
}
