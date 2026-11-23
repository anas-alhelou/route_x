import 'package:flutter/foundation.dart';

/// Who is signed in, as far as the UI needs to draw them: the display name and
/// the profile picture (a server URL, or a file the driver just picked).
///
/// Whatever screen first learns these (Settings, Home, the join flow, all of
/// which read `/auth/me`) publishes them here, so every avatar in the app shows
/// the same picture and a change made in Edit profile reaches all of them at
/// once. Cleared on sign-out.
abstract final class DriverIdentity {
  static final ValueNotifier<({String name, String? photo})> current =
      ValueNotifier((name: '', photo: null));

  static void update({String? name, String? photo}) {
    final now = current.value;
    current.value = (
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : now.name,
      photo: (photo != null && photo.isNotEmpty) ? photo : now.photo,
    );
  }

  static void clear() => current.value = (name: '', photo: null);
}
