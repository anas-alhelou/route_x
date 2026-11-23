// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import local core files
import 'core/bloc/language/language_bloc.dart';
import 'core/config/constants/app_env.dart';
import 'core/bloc/theme/theme_cubit.dart';
import 'core/config/constants/app_sizes.dart';
import 'core/notifications/app_notification_service.dart';
import 'core/services/local/app_preferences_service.dart';
import 'core/notifications/notification_action_handler.dart';
import 'core/notifications/notification_preferences.dart';
import 'core/notifications/notification_texts.dart';
import 'core/notifications/push_messaging_service.dart';
import 'core/di/injection.dart';
import 'core/l10n/app_localizations.dart';
import 'core/network/session_events.dart';
import 'core/session/driver_identity.dart';
import 'core/router/app_router.dart';
import 'core/router/routers_name.dart';
import 'core/theme/app_colors_sync.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/auth/presentation/controllers/auth_bloc.dart';
import 'firebase_options.dart';

// Global key for showing SnackBars from anywhere
final globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Logs a one-line hint when the Google server client ID is missing in debug.
///
/// This runs before any UI is built so a developer launching from the IDE
/// without `--dart-define-from-file=env/dev.json` sees immediately why the
/// "Continue with Google" button will fail fast with `errGoogleNotConfigured`.
void _logMissingGoogleClientIdIfNeeded() {
  if (!kDebugMode) return;
  if (AppEnv.googleServerClientId.trim().isNotEmpty) return;
  debugPrint(
    '[GoogleSignIn] GOOGLE_SERVER_CLIENT_ID is empty — '
    'create env/dev.json from env/dev.example.json and run with '
    '--dart-define-from-file=env/dev.json (see env/dev.example.json).',
  );
}

void main() async {
  // 1. Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase before anything that may register a service.
  // A failure is only logged: the app can still start without push, whereas
  // throwing here would leave the splash screen frozen.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    debugPrint('Firebase initialization error: $error');
  }

  // 2b. System notifications (new orders, the ongoing route) and push. Both
  // swallow their own errors: a failure must never block the app from starting.
  // Saved notification settings and language first, so the channels and the
  // first notification already use what the driver chose.
  await NotificationPreferences.load();
  await NotificationTexts.loadSavedLocale();
  await AppNotificationService.instance.init();
  await PushMessagingService.instance.init();

  // 3. Debug-only startup check for Google Sign-In configuration.
  _logMissingGoogleClientIdIfNeeded();

  bool isDiInitialized = false;

  // 4. Wrap async initialization in try-catch to prevent frozen splash screen
  try {
    await setupDependencyInjection();
    isDiInitialized = true;
    // Routes a tap on a notification to the screen the Figma prototype names.
    NotificationActionHandler.instance.start();
  } catch (error, stackTrace) {
    debugPrint('Dependency Injection error: $error\n$stackTrace');
  }

  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } catch (error) {
    debugPrint('SystemChrome error: $error');
  }

  // 5. Launch App UI with DI status flag
  SessionEvents.expired.addListener(() {
    DriverIdentity.clear();
    AppRouter.router.go(RoutersName.login);
  });

  runApp(MyApp(isDiInitialized: isDiInitialized));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isDiInitialized = true});

  final bool isDiInitialized;

  @override
  Widget build(BuildContext context) {
    // Render clean fallback Error UI if DI failed, avoiding GetIt StateError crashes
    if (!isDiInitialized) {
      return MaterialApp(
        title: 'RouteX',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.textBlack,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: Color(0xFF8FE600),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Initialization Failed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandWhite,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'RouteX could not initialize required services. Please restart the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (_) =>
              LanguageBloc(preferences: getIt<AppPreferencesService>()),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(
            getThemeUseCase: getIt(),
            setThemeUseCase: getIt(),
          )..load(),
        ),
        BlocProvider<SplashCubit>(
          create: (_) => getIt<SplashCubit>(),
        ),
        BlocProvider<OnboardingCubit>(
          create: (_) => getIt<OnboardingCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(
          AppSizes.figmaDesignWidth,
          AppSizes.figmaDesignHeight,
        ),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, state) {
                  // Notifications are built outside the widget tree and need to
                  // know which language the driver picked in the app.
                  NotificationTexts.currentLocale = Locale(state.languageCode);
                  return MaterialApp.router(
                    title: 'RouteX',
                    // The design-system theme carries the font stack: Satoshi for
                    // Latin with IBM Plex Sans Arabic as its fallback, so Arabic
                    // text is covered here too and not only in the styles that name
                    // a family explicitly.
                    theme: getLightTheme(isArabic: state.languageCode == 'ar'),
                    darkTheme: getDarkTheme(isArabic: state.languageCode == 'ar'),
                    themeMode: themeMode,
                    scaffoldMessengerKey: globalMessengerKey,
                    debugShowCheckedModeBanner: false,
                    routerConfig: AppRouter.router,
                    locale: Locale(state.languageCode),
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    builder: (context, child) {
                      return AppColorsSync(
                        child: MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaler: const TextScaler.linear(1.0)),
                          child: child!,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
