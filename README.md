# routex_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Sign-In setup

"Continue with Google" uses [`google_sign_in`](https://pub.dev/packages/google_sign_in)
(v7.2), which wraps Credential Manager on Android and GoogleSignIn for iOS. All
of the wiring lives in the backend: the app only ever obtains a Google **ID
token** and posts it to `POST /auth/google`, which verifies it.

Three values have to line up, and they are easy to mix up:

| Value | Where it comes from | Where it is used |
| --- | --- | --- |
| **Web client ID** (server client ID) | Google Cloud console → *APIs & Services* → Credentials → **OAuth client ID → Web application** | Passed to the SDK at runtime (`serverClientId`) **and** verified by the backend |
| **Android client ID** | Same page → *OAuth client ID → Android* | Resolved by Credential Manager from the app's package name + signing SHA-1 |
| **iOS client ID** | Same page → *OAuth client ID → iOS* | `GIDClientID` in `ios/Runner/Info.plist` |

> **The Web client ID must be the one the backend validates.** The backend
> verifies the ID token's `aud` claim against the client IDs it has been
> configured with. On Android and iOS the SDK mints the ID token for the
> *platform* client, and then exchanges it for one whose `aud` is the **Web**
> client — this is exactly what `serverClientId` triggers. If the value passed
> via `--dart-define=GOOGLE_SERVER_CLIENT_ID` is not registered as a Web
> client (or is not the Web client the backend trusts), the token arrives with
> the wrong audience and the backend rejects it. The symptom is a valid Google
> sign-in followed by a 401 from `/auth/google`; it is never a plugin error,
> so check this first.

### 1. Create the Web client ID (the `serverClientId`)

1. Open the [Credentials page](https://console.cloud.google.com/apis/credentials)
   of the Google Cloud project the backend uses.
2. **Create credentials → OAuth client ID → Web application**.
3. Copy the client ID (it looks like
   `1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`).
4. This is the value for `GOOGLE_SERVER_CLIENT_ID` below, and the same value
   for `GIDServerClientID` in `ios/Runner/Info.plist`.

### 2. Create the Android client

1. Same page → **Create credentials → OAuth client ID → Android**.
2. **Package name**: `com.routex.routex_mobile` — it must match
   `applicationId` in `android/app/build.gradle.kts` exactly.
3. Get the SHA-1 fingerprints of the keys that will actually sign the build:

   ```sh
   cd android
   ./gradlew signingReport
   ```

   `signingReport` prints a `SHA1:` line for every variant (`debug`, `release`,
   `profile`). Register **all** of them: registering only the debug SHA-1 is
   the usual reason sign-in works while developing and fails on a release
   build.

4. Paste the SHA-1 into the Android OAuth client's form and save.

### 3. Run and build

The Web client ID is injected at build time through a `dart-define` — it is
never committed to source. Without it, `GoogleSignInServiceImpl` passes `null`
to the SDK and sign-in falls back to whatever the platform configuration file
declares (which is `google-services.json` on Android).

Because the ID is needed by four different commands, keeping it in a local,
git-ignored file avoids re-typing (and accidentally pasting it into a shell
history or a CI log). Copy the example and fill it in:

```sh
cp env/dev.example.json env/dev.json   # then edit env/dev.json
```

```json
{ "GOOGLE_SERVER_CLIENT_ID": "1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com" }
```

Then pass the file instead of the inline define:

```sh
flutter run        --dart-define-from-file=env/dev.json
flutter build apk  --dart-define-from-file=env/dev.json
```

`env/dev.json` is git-ignored; `env/dev.example.json` is not. The equivalent
inline form still works, and wins if both are given:

```sh
flutter run   --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
flutter build apk     --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
flutter build appbundle --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
flutter build ipa     --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

Read by `AppEnv.googleServerClientId`
(`lib/core/config/constants/app_env.dart`). A release build without the define
will sign in and then fail at `/auth/google`.

### 4. Diagnosing a broken Google button

"Continue with Google" fails in three distinguishable ways, and each one has
its own message so a screenshot says which stage broke:

| Symptom | Meaning |
| --- | --- |
| *"Signing in with Google is unavailable right now"* | The app could not even reach Google: no `serverClientId` and no `google-services.json`, or the OAuth client is not registered for this package name / SHA-1. |
| *"No internet connection…"* | The request never reached the server. |
| *"We couldn't sign you in with Google…"* | The SDK or the API rejected the attempt; retrying is reasonable. |
| Nothing at all | The user dismissed the chooser. That is a cancellation, not an error, and is deliberately silent. |

Every failure also writes a line to the DevTools console (see the `GoogleSignIn`
and `AuthRepository.google` log names) — **debug builds only**, and never
including the ID token:

```
GoogleSignIn: GOOGLE_SERVER_CLIENT_ID is empty. Sign-in can only work if the
platform config supplies an OAuth web client (Android: google-services.json +
an OAuth client whose SHA-1 matches the debug keystore). Run with
--dart-define-from-file=env/dev.json, or copy env/dev.example.json to
env/dev.json and fill it in.
```

A `POST /auth/google` the server actually answered to logs its status and body
message, plus which optional vehicle fields were sent:

```
AuthRepository.google: POST /auth/google rejected the sign-in (status: 401,
message: Invalid Google token, sentVehicleType: none, sentVehicleNumber: none)
```

A valid Google sign-in followed by a **401** means the Web client ID is not the
one the backend trusts (see the note at the top of this section). A **4xx**
that only ever happens without `vehicleType`/`vehicleNumber` is the backend
asking for a driver profile the app cannot yet complete — see the `TODO(auth)`
in `auth_repository_impl.dart` for the open question to put to the backend.

### 5. iOS

`ios/Runner/Info.plist` carries placeholders that must be replaced with real
values (see the Google Sign-in section at the bottom of that file):

- `GIDClientID` → the **iOS** client ID.
- `GIDServerClientID` → the **Web** client ID (optional; the app already passes
  `serverClientId` from Dart).
- `CFBundleURLTypes` → `CFBundleURLSchemes` must contain the **reversed**
  client ID (the digits first, then `.apps.googleusercontent.com`) — the value
  `GoogleService-Info.plist` calls `REVERSED_CLIENT_ID`.

Both the `GIDClientID` entry and the URL scheme are required; a missing URL
scheme is the classic cause of the chooser closing immediately on iOS.

> **App Store note:** Apple's
> [App Review Guidelines 4.8](https://developer.apple.com/app-store/review/guidelines/#login-services)
> require apps that offer third-party login to also offer an equivalent
> privacy-preserving option (e.g. Sign in with Apple) unless the app falls into
> one of the listed exceptions. Worth settling before the first submission.

