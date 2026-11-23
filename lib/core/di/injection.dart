// lib/core/di/injection.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:dio/dio.dart';
import 'package:routex_mobile/core/notifications/push_messaging_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services & Storage
import 'package:routex_mobile/core/network/dio_client.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import 'package:routex_mobile/core/network/network_info.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';
import 'package:routex_mobile/core/services/local/media/image_picker_service.dart';
import 'package:routex_mobile/core/services/location/location_service.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';

// Core Use Cases
import 'package:routex_mobile/core/services/local/usecases/clear_user_preferences_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/get_language_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/get_remember_me_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/get_theme_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/set_language_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/set_remember_me_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/set_theme_usecase.dart';

// Auth Feature - Data Sources & Repositories
import 'package:routex_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:routex_mobile/features/auth/data/datasources/google_sign_in_service.dart';
import 'package:routex_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/repositories/login_repository.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';

// Auth Feature - Use Cases
import 'package:routex_mobile/features/auth/domain/usecases/check_remembered_session_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/pick_profile_image_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/validate_signup_step1_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/validate_signup_step3_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/get_google_id_token_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_reset_otp_usecase.dart';

// Auth Feature - BLoCs / Controllers
import 'package:routex_mobile/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/auth_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/login_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';

// Splash Feature
import 'package:routex_mobile/features/splash/domain/repositories/splash_repository.dart';
import 'package:routex_mobile/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:routex_mobile/features/splash/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:routex_mobile/features/splash/presentation/cubit/splash_cubit.dart';

// Onboarding Feature
import 'package:routex_mobile/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:routex_mobile/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:routex_mobile/features/onboarding/domain/usecases/set_onboarding_completed_usecase.dart';
import 'package:routex_mobile/features/onboarding/presentation/cubit/onboarding_cubit.dart';

// App Permissions Feature
import 'package:routex_mobile/features/app_permissions/data/datasources/app_permissions_local_data_source.dart';
import 'package:routex_mobile/features/app_permissions/data/datasources/app_permissions_remote_data_source.dart';
import 'package:routex_mobile/features/app_permissions/data/repositories/app_permissions_repository_impl.dart';
import 'package:routex_mobile/features/app_permissions/domain/repositories/app_permissions_repository.dart';
import 'package:routex_mobile/features/app_permissions/domain/usecases/check_permission_status_usecase.dart';
import 'package:routex_mobile/features/app_permissions/domain/usecases/request_permission_usecase.dart';
import 'package:routex_mobile/features/app_permissions/domain/usecases/submit_device_setup_usecase.dart';
import 'package:routex_mobile/features/app_permissions/presentation/controllers/permissions_cubit.dart';

// Orders — real backend
import 'package:routex_mobile/features/orders/data/datasources/driver_orders_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/proof_upload_queue.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_offer_api_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/orders_today_remote_data_source.dart';

import 'package:routex_mobile/features/route_fleet/data/datasources/route_fleet_api_data_source.dart';

import 'package:routex_mobile/features/settings/data/datasources/settings_api_data_source.dart';

import 'package:routex_mobile/features/orders/data/datasources/order_detail_api_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_search_api_data_source.dart';

// Live tracking
import 'package:routex_mobile/features/tracking/data/tracking_remote_data_source.dart';
import 'package:routex_mobile/features/tracking/domain/tracking_service.dart';

// Route & Fleet Feature
import 'package:routex_mobile/features/route_fleet/data/datasources/route_fleet_local_data_source.dart';
import 'package:routex_mobile/features/route_fleet/data/datasources/route_fleet_remote_data_source.dart';
import 'package:routex_mobile/features/route_fleet/data/repositories/route_fleet_repository_impl.dart';
import 'package:routex_mobile/features/route_fleet/domain/repositories/route_fleet_repository.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/get_active_route_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/reorder_stop_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/report_wrong_location_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/update_stop_status_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/search_fleets_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/join_fleet_usecase.dart' as rf_join;
import 'package:routex_mobile/features/route_fleet/domain/usecases/join_fleet_by_code_usecase.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/enter_fleet_code_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';

// Orders Feature
import 'package:routex_mobile/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_cubit.dart';
import 'package:routex_mobile/features/orders/data/datasources/orders_today_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/orders_today_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/orders_today_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_orders_today_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_today_cubit.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_detail_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_detail_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/order_detail_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_order_detail_usecase.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_search_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_search_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/order_search_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_history_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/sync_queue_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/sync_queue_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/sync_queue_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/sync_queue_usecases.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_offer_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_offer_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/order_offer_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/order_offer_usecases.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_history_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/order_history_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_order_history_usecase.dart';
import 'package:routex_mobile/features/orders/data/datasources/history_day_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/history_day_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/history_day_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_day_stops_usecase.dart';
import 'package:routex_mobile/features/orders/data/datasources/history_stop_record_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/history_stop_record_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/history_stop_record_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_stop_record_usecase.dart';
import 'package:routex_mobile/features/orders/data/datasources/stop_issue_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/stop_issue_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/stop_issue_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/report_stop_issue_usecase.dart';

// Settings Feature
import 'package:routex_mobile/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:routex_mobile/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:routex_mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:routex_mobile/features/settings/domain/usecases/get_profile_usecase.dart';
import 'package:routex_mobile/features/settings/domain/usecases/update_profile_usecase.dart';
import 'package:routex_mobile/features/settings/domain/usecases/logout_usecase.dart';
import 'package:routex_mobile/features/settings/presentation/controllers/settings_cubit.dart';

// Home Feature
import 'package:routex_mobile/features/home/data/datasources/find_fleet_local_data_source.dart';
import 'package:routex_mobile/features/home/data/datasources/home_debug_local_data_source.dart';
import 'package:routex_mobile/features/home/data/datasources/home_local_data_source.dart';
import 'package:routex_mobile/features/home/data/repositories/find_fleet_repository_impl.dart';
import 'package:routex_mobile/features/home/data/repositories/home_debug_repository_impl.dart';
import 'package:routex_mobile/features/home/data/repositories/home_repository_impl.dart';
import 'package:routex_mobile/features/home/data/stores/in_memory_fleet_request_store.dart';
import 'package:routex_mobile/features/home/domain/repositories/find_fleet_repository.dart';
import 'package:routex_mobile/features/home/domain/repositories/fleet_request_store.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_debug_repository.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_repository.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_available_filters_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_fleets_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_home_overview_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/join_find_fleet_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/join_fleet_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/set_online_status_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/find_fleet_bloc.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_bloc.dart';

// Notifications Feature
import 'package:routex_mobile/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:routex_mobile/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:routex_mobile/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/toggle_notifications_empty_usecase.dart';
import 'package:routex_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';

// Home Feature - Enter Fleet Code
import 'package:routex_mobile/features/home/data/datasources/enter_fleet_code_local_data_source.dart';
import 'package:routex_mobile/features/home/data/repositories/enter_fleet_code_repository_impl.dart';
import 'package:routex_mobile/features/home/domain/repositories/enter_fleet_code_repository.dart';
import 'package:routex_mobile/features/home/domain/usecases/verify_fleet_code_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/enter_fleet_code_bloc.dart';

// Home Feature - Delivery Dashboard (HM2, HM3, HM5, HM6)
import 'package:routex_mobile/features/home/data/datasources/delivery_dashboard_api_data_source.dart';
import 'package:routex_mobile/features/home/data/datasources/delivery_dashboard_local_data_source.dart';
import 'package:routex_mobile/features/home/data/repositories/delivery_dashboard_repository_impl.dart';
import 'package:routex_mobile/features/home/domain/repositories/delivery_dashboard_repository.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_delivery_dashboard_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/switch_delivery_scenario_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/delivery_dashboard_bloc.dart';

// Join Company Feature
import 'package:routex_mobile/features/join_company/data/datasources/join_company_remote_datasource.dart';
import 'package:routex_mobile/features/join_company/data/repositories/join_company_repository_impl.dart';
import 'package:routex_mobile/features/join_company/domain/repositories/join_company_repository.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/verify_company_code_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/send_company_request_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/get_request_status_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/cancel_company_request_usecase.dart';
import 'package:routex_mobile/features/join_company/presentation/bloc/join_company_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // ── 1. Core / External ──────────────────────────────────────────────────

  getIt.registerLazySingleton<ImagePickerService>(
    () => ImagePickerServiceImpl(),
  );

  getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );

  getIt.registerLazySingleton<ExceptionMapper>(() => const ExceptionMapper());

  getIt.registerLazySingleton<NetworkInfo>(() => ConnectivityNetworkInfo());

  getIt.registerLazySingleton<Dio>(
    () => DioClient.createClient(
      storage: getIt<SecureStorageService>(),
      logRequests: kDebugMode,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // ── 2. Core Services & Use Cases ────────────────────────────────────────

  getIt.registerLazySingleton<AppPreferencesService>(
    () => AppPreferencesServiceImpl(prefs: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton(
    () =>
        GetLanguageUseCase(preferencesService: getIt<AppPreferencesService>()),
  );
  getIt.registerLazySingleton(
    () =>
        SetLanguageUseCase(preferencesService: getIt<AppPreferencesService>()),
  );
  getIt.registerLazySingleton(
    () => GetThemeUseCase(preferencesService: getIt<AppPreferencesService>()),
  );
  getIt.registerLazySingleton(
    () => SetThemeUseCase(preferencesService: getIt<AppPreferencesService>()),
  );
  getIt.registerLazySingleton(
    () => GetRememberMeUseCase(
      preferencesService: getIt<AppPreferencesService>(),
    ),
  );
  getIt.registerLazySingleton(
    () => SetRememberMeUseCase(
      preferencesService: getIt<AppPreferencesService>(),
    ),
  );
  getIt.registerLazySingleton(
    () => ClearUserPreferencesUseCase(
      preferencesService: getIt<AppPreferencesService>(),
    ),
  );

  // ── 3. Feature: Auth (Data Sources & Repositories) ─────────────────────

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      getIt<Dio>(),
      fcmToken: () => PushMessagingService.instance.token(),
    ),
  );

  getIt.registerLazySingleton<GoogleSignInService>(
    () => GoogleSignInServiceImpl(),
  );

  // The single owner of the interactive Google call. Sharing one instance keeps
  // the SDK's "initialize once" guard effective across both screens.
  getIt.registerLazySingleton<GetGoogleIdTokenUseCase>(
    () => GetGoogleIdTokenUseCase(service: getIt<GoogleSignInService>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<SecureStorageService>(),
      googleSignInService: getIt<GoogleSignInService>(),
      exceptionMapper: getIt<ExceptionMapper>(),
    ),
  );

  getIt.registerLazySingleton<LoginRepository>(
    () => getIt<AuthRepository>() as AuthRepositoryImpl,
  );

  // ── 4. Feature: Auth (Use Cases) ────────────────────────────────────────

  getIt.registerLazySingleton(
    () => ValidateSignupStep1UseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => ValidateSignupStep3UseCase());
  getIt.registerLazySingleton(
    () => PickProfileImageUseCase(
      imagePickerService: getIt<ImagePickerService>(),
    ),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => LoginUseCase(repository: getIt<LoginRepository>()),
  );
  getIt.registerLazySingleton(
    () => GoogleSignInUseCase(repository: getIt<LoginRepository>()),
  );
  getIt.registerLazySingleton(
    () => ForgotPasswordUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => VerifyOtpUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => VerifyResetOtpUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => ResetPasswordUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => RefreshTokenUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
    () => CheckRememberedSessionUseCase(
      getRememberMeUseCase: getIt<GetRememberMeUseCase>(),
      setRememberMeUseCase: getIt<SetRememberMeUseCase>(),
      repository: getIt<AuthRepository>(),
    ),
  );

  // ── 5. Feature: Splash (Data, Domain, Presentation) ───────────────────

  getIt.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(getIt<AppPreferencesService>()),
  );

  getIt.registerLazySingleton(
    () => CheckOnboardingStatusUseCase(getIt<SplashRepository>()),
  );

  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(
      checkOnboardingStatusUseCase: getIt<CheckOnboardingStatusUseCase>(),
      checkRememberedSessionUseCase: getIt<CheckRememberedSessionUseCase>(),
      membershipChecker: () async {
        final me = await getIt<JoinCompanyRemoteDataSource>().fetchMemberships();
        final statuses = me.memberships.map((m) => m.status).toList();
        if (statuses.isEmpty || statuses.contains('APPROVED')) return null;
        return SplashNavigationState.navigateToCompanyRequest;
      },
    ),
  );

  // ── 5b. Feature: Onboarding (Data, Domain, Presentation) ──────────────

  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(getIt<AppPreferencesService>()),
  );

  getIt.registerLazySingleton(
    () => SetOnboardingCompletedUseCase(getIt<OnboardingRepository>()),
  );

  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(getIt<SetOnboardingCompletedUseCase>()),
  );

  // ── 6. Feature: App Permissions ────────────────────────────────────────

  getIt.registerLazySingleton<AppPermissionsLocalDataSource>(
    () => AppPermissionsLocalDataSourceImpl(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<AppPermissionsRemoteDataSource>(
    () => AppPermissionsRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<AppPermissionsRepository>(
    () => AppPermissionsRepositoryImpl(
      localDataSource: getIt<AppPermissionsLocalDataSource>(),
      remoteDataSource: getIt<AppPermissionsRemoteDataSource>(),
      exceptionMapper: getIt<ExceptionMapper>(),
    ),
  );

  getIt.registerLazySingleton(
    () => CheckPermissionStatusUseCase(getIt<AppPermissionsRepository>()),
  );

  getIt.registerLazySingleton(
    () => RequestPermissionUseCase(getIt<AppPermissionsRepository>()),
  );

  getIt.registerLazySingleton(
    () => SubmitDeviceSetupUseCase(getIt<AppPermissionsRepository>()),
  );

  getIt.registerFactory<PermissionsCubit>(
    () => PermissionsCubit(
      checkPermissionStatusUseCase: getIt<CheckPermissionStatusUseCase>(),
      requestPermissionUseCase: getIt<RequestPermissionUseCase>(),
      submitDeviceSetupUseCase: getIt<SubmitDeviceSetupUseCase>(),
      repository: getIt<AppPermissionsRepository>(),
    ),
  );

  // ── 7. Feature: Route & Fleet ──────────────────────────────────────────

  getIt.registerLazySingleton<RouteFleetLocalDataSource>(
    () => RouteFleetApiDataSource(getIt<DriverOrdersRemoteDataSource>()),
  );

  getIt.registerLazySingleton<RouteFleetRemoteDataSource>(
    () => RouteFleetRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<RouteFleetRepository>(
    () => RouteFleetRepositoryImpl(
      localDataSource: getIt<RouteFleetLocalDataSource>(),
      remoteDataSource: getIt<RouteFleetRemoteDataSource>(),
      exceptionMapper: getIt<ExceptionMapper>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetActiveRouteUseCase(getIt<RouteFleetRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdateStopStatusUseCase(getIt<RouteFleetRepository>()),
  );

  getIt.registerLazySingleton(
    () => ReorderStopUseCase(getIt<RouteFleetRepository>()),
  );

  getIt.registerLazySingleton(
    () => ReportWrongLocationUseCase(getIt<RouteFleetRepository>()),
  );

  getIt.registerLazySingleton(
    () => SearchFleetsUseCase(repository: getIt<RouteFleetRepository>()),
  );

  getIt.registerLazySingleton<rf_join.JoinFleetUseCase>(
    () => rf_join.JoinFleetUseCase(repository: getIt<RouteFleetRepository>()),
  );

  getIt.registerLazySingleton(
    () => JoinFleetByCodeUseCase(repository: getIt<RouteFleetRepository>()),
  );

  getIt.registerLazySingleton<TrackingRemoteDataSource>(
    () => TrackingRemoteDataSourceImpl(
      api: getIt<Dio>(),
      plain: TrackingRemoteDataSourceImpl.createPlainClient(),
    ),
  );

  getIt.registerLazySingleton<ProofUploadQueue>(
    () => ProofUploadQueue(
      orders: getIt<DriverOrdersRemoteDataSource>(),
      preferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<TrackingService>(
    () => TrackingService(
      remote: getIt<TrackingRemoteDataSource>(),
      preferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerFactory<RouteFleetCubit>(
    () => RouteFleetCubit(
      getActiveRouteUseCase: getIt<GetActiveRouteUseCase>(),
      updateStopStatusUseCase: getIt<UpdateStopStatusUseCase>(),
      reorderStopUseCase: getIt<ReorderStopUseCase>(),
      reportWrongLocationUseCase: getIt<ReportWrongLocationUseCase>(),
      searchFleetsUseCase: getIt<SearchFleetsUseCase>(),
      joinFleetUseCase: getIt<rf_join.JoinFleetUseCase>(),
    ),
  );

  getIt.registerFactory<EnterFleetCodeCubit>(
    () => EnterFleetCodeCubit(
      joinFleetByCodeUseCase: getIt<JoinFleetByCodeUseCase>(),
    ),
  );

  // ── 8. Feature: Home ───────────────────────────────────────────────────

  // Registered before the data sources that write to it, and as a singleton for
  // that reason: Home and Enter Fleet Code must be looking at the same join
  // request, so a code entered on one screen is still pending on the dashboard.
  getIt.registerLazySingleton<FleetRequestStore>(
    () => InMemoryFleetRequestStore(),
  );

  // The concrete type is registered first and both interfaces resolve from it, so
  // the production source and the debug source are the *same object*.
  // Registering them separately would give each its own dashboard state, and a
  // debug transition would appear to do nothing.
  getIt.registerLazySingleton<HomeLocalDataSourceImpl>(
    () => HomeLocalDataSourceImpl(requestStore: getIt<FleetRequestStore>()),
  );

  getIt.registerLazySingleton<HomeLocalDataSource>(
    () => getIt<HomeLocalDataSourceImpl>(),
  );

  getIt.registerLazySingleton<HomeDebugLocalDataSource>(
    () => getIt<HomeLocalDataSourceImpl>(),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: getIt<HomeLocalDataSource>()),
  );

  getIt.registerLazySingleton<HomeDebugRepository>(
    () => HomeDebugRepositoryImpl(
      localDataSource: getIt<HomeDebugLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetHomeOverviewUseCase(repository: getIt<HomeRepository>()),
  );

  getIt.registerLazySingleton(
    () => SetOnlineStatusUseCase(repository: getIt<HomeRepository>()),
  );

  getIt.registerLazySingleton(
    () => JoinFleetUseCase(repository: getIt<HomeRepository>()),
  );

  // A factory, not a singleton: HomeBloc owns a subscription to its own state,
  // so one instance per page instance is what lets a rebuilt page start clean.
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getHomeOverview: getIt<GetHomeOverviewUseCase>(),
      setOnlineStatus: getIt<SetOnlineStatusUseCase>(),
      joinFleet: getIt<JoinFleetUseCase>(),
      // The debug transitions are reachable in debug builds only; both the UI
      // gesture and HomeBloc's handler check kDebugMode as well.
      debugRepository: getIt<HomeDebugRepository>(),
    ),
  );

  // ── 8b. Feature: Home — Find a Fleet ───────────────────────────────────

  getIt.registerLazySingleton<FindFleetLocalDataSource>(
    () => FindFleetLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<FindFleetRepository>(
    () => FindFleetRepositoryImpl(
      localDataSource: getIt<FindFleetLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetFleetsUseCase(repository: getIt<FindFleetRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetAvailableFiltersUseCase(repository: getIt<FindFleetRepository>()),
  );

  getIt.registerLazySingleton(
    () => JoinFindFleetUseCase(repository: getIt<FindFleetRepository>()),
  );

  getIt.registerFactory<FindFleetBloc>(
    () => FindFleetBloc(
      getFleets: getIt<GetFleetsUseCase>(),
      getAvailableFilters: getIt<GetAvailableFiltersUseCase>(),
      joinFindFleet: getIt<JoinFindFleetUseCase>(),
    ),
  );

  // ── Feature: Notifications ───────────────────────────────────────────

  getIt.registerLazySingleton<NotificationsLocalDataSource>(
    () => NotificationsLocalDataSourceImpl(includeSamples: false),
  );

  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
      localDataSource: getIt<NotificationsLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetNotificationsUseCase(repository: getIt<NotificationsRepository>()),
  );

  getIt.registerLazySingleton(
    () => MarkAllNotificationsReadUseCase(
      repository: getIt<NotificationsRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => ToggleNotificationsEmptyUseCase(
      repository: getIt<NotificationsRepository>(),
    ),
  );

  getIt.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(
      getNotifications: getIt<GetNotificationsUseCase>(),
      markAllRead: getIt<MarkAllNotificationsReadUseCase>(),
      toggleEmpty: getIt<ToggleNotificationsEmptyUseCase>(),
    ),
  );

  // ── 8d. Feature: Home — Enter Fleet Code ──────────────────────────────

  getIt.registerLazySingleton<EnterFleetCodeLocalDataSource>(
    () => EnterFleetCodeLocalDataSourceImpl(
      requestStore: getIt<FleetRequestStore>(),
    ),
  );

  getIt.registerLazySingleton<EnterFleetCodeRepository>(
    () => EnterFleetCodeRepositoryImpl(
      localDataSource: getIt<EnterFleetCodeLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => VerifyFleetCodeUseCase(repository: getIt<EnterFleetCodeRepository>()),
  );

  getIt.registerFactory<EnterFleetCodeBloc>(
    () => EnterFleetCodeBloc(
      verifyFleetCodeUseCase: getIt<VerifyFleetCodeUseCase>(),
    ),
  );

  // ── 8e. Feature: Home — Delivery Dashboard (HM2, HM3, HM5, HM6) ────────

  getIt.registerLazySingleton<DeliveryDashboardLocalDataSource>(
    () => DeliveryDashboardApiDataSource(
      dio: getIt<Dio>(),
      orders: getIt<DriverOrdersRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<DeliveryDashboardRepository>(
    () => DeliveryDashboardRepositoryImpl(
      localDataSource: getIt<DeliveryDashboardLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetDeliveryDashboardUseCase(
      repository: getIt<DeliveryDashboardRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => SwitchDeliveryScenarioUseCase(
      repository: getIt<DeliveryDashboardRepository>(),
    ),
  );

  getIt.registerFactory<DeliveryDashboardBloc>(
    () => DeliveryDashboardBloc(
      getDeliveryDashboard: getIt<GetDeliveryDashboardUseCase>(),
      switchDeliveryScenario: getIt<SwitchDeliveryScenarioUseCase>(),
      locationService: getIt<LocationService>(),
    ),
  );

  // ── 9. Feature: Orders ─────────────────────────────────────────────────

  getIt.registerLazySingleton<OrdersLocalDataSource>(
    () => OrdersLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(localDataSource: getIt<OrdersLocalDataSource>()),
  );

  getIt.registerLazySingleton(
    () => GetOrdersUseCase(getIt<OrdersRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdateOrderStatusUseCase(getIt<OrdersRepository>()),
  );

  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(
      getOrdersUseCase: getIt<GetOrdersUseCase>(),
      updateOrderStatusUseCase: getIt<UpdateOrderStatusUseCase>(),
    ),
  );

  getIt.registerLazySingleton<DriverOrdersRemoteDataSource>(
    () => DriverOrdersRemoteDataSource(getIt<Dio>()),
  );

  // Orders / Today — the day-plan screen. Separate graph from the legacy
  // orders list above: it reads a different shape and will point at a
  // different endpoint once dispatch ships one.
  getIt.registerLazySingleton<OrdersTodayLocalDataSource>(
    // Pull to refresh once loaded: two orders arrive on tomorrow. For the
    // other designed days use
    // `const OrdersTodayLocalDataSourceImpl(scenario: OrdersTodayMockScenario.x)`
    // with normal, withCancellation or empty.
    () => OrdersTodayRemoteDataSource(getIt<DriverOrdersRemoteDataSource>()),
  );

  // A singleton on purpose: it holds the last good day in memory, which is
  // what the offline notice shows.
  getIt.registerLazySingleton<OrdersTodayRepository>(
    () => OrdersTodayRepositoryImpl(
      localDataSource: getIt<OrdersTodayLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetOrdersTodayUseCase(getIt<OrdersTodayRepository>()),
  );

  getIt.registerFactory<OrdersTodayCubit>(
    () => OrdersTodayCubit(
      getOrdersTodayUseCase: getIt<GetOrdersTodayUseCase>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Order detail — one stop, opened from a Today row.
  getIt.registerLazySingleton<OrderDetailLocalDataSource>(
    () => OrderDetailApiDataSource(getIt<DriverOrdersRemoteDataSource>()),
  );

  getIt.registerLazySingleton<OrderDetailRepository>(
    () => OrderDetailRepositoryImpl(
      localDataSource: getIt<OrderDetailLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetOrderDetailUseCase(getIt<OrderDetailRepository>()),
  );

  // Order history — the History segment of the Orders tab.
  getIt.registerLazySingleton<OrderHistoryLocalDataSource>(
    () => const OrderHistoryLocalDataSourceImpl(),
  );

  // Stop updates finished on this phone, waiting to upload. Empty until
  // stops are completed through the app.
  getIt.registerLazySingleton<SyncQueueLocalDataSource>(
    () => SyncQueueMockDataSource(),
  );

  getIt.registerLazySingleton<SyncQueueRepository>(
    () => SyncQueueRepositoryImpl(
      syncQueue: getIt<SyncQueueLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetPendingSyncUpdatesUseCase(getIt<SyncQueueRepository>()),
  );
  getIt.registerLazySingleton(
    () => SyncPendingUpdatesUseCase(getIt<SyncQueueRepository>()),
  );

  // Order offers — orders a fleet offers the driver to accept or decline.
  getIt.registerLazySingleton<OrderOfferRemoteDataSource>(
    () => OrderOfferApiDataSource(getIt<DriverOrdersRemoteDataSource>()),
  );
  getIt.registerLazySingleton<OrderOfferRepository>(
    () => OrderOfferRepositoryImpl(
      remote: getIt<OrderOfferRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetPendingOffersUseCase(getIt<OrderOfferRepository>()),
  );
  getIt.registerLazySingleton(
    () => AcceptOfferUseCase(getIt<OrderOfferRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeclineOfferUseCase(getIt<OrderOfferRepository>()),
  );
  getIt.registerLazySingleton(
    () => UndoDeclineOfferUseCase(getIt<OrderOfferRepository>()),
  );

  getIt.registerLazySingleton<OrderHistoryRepository>(
    () => OrderHistoryRepositoryImpl(
      localDataSource: getIt<OrderHistoryLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      syncQueue: getIt<SyncQueueLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetOrderHistoryUseCase(getIt<OrderHistoryRepository>()),
  );

  // History day — one past day's stops, opened from a day row.
  getIt.registerLazySingleton<HistoryDayLocalDataSource>(
    // A short delay so the stops skeleton is seen, as it will be on a real
    // network.
    () => const HistoryDayLocalDataSourceImpl(
      loadDelay: Duration(milliseconds: 600),
    ),
  );

  getIt.registerLazySingleton<HistoryDayRepository>(
    () => HistoryDayRepositoryImpl(
      localDataSource: getIt<HistoryDayLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetHistoryDayStopsUseCase(getIt<HistoryDayRepository>()),
  );

  // History stop record — one closed stop's log, opened from a day's stop.
  getIt.registerLazySingleton<HistoryStopRecordLocalDataSource>(
    () => const HistoryStopRecordLocalDataSourceImpl(
      loadDelay: Duration(milliseconds: 500),
    ),
  );

  getIt.registerLazySingleton<HistoryStopRecordRepository>(
    () => HistoryStopRecordRepositoryImpl(
      localDataSource: getIt<HistoryStopRecordLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetHistoryStopRecordUseCase(getIt<HistoryStopRecordRepository>()),
  );

  // Stop issue reports — the "Report an issue" sheet on a stop's record.
  getIt.registerLazySingleton<StopIssueDataSource>(
    () => const StopIssueMockDataSource(),
  );

  getIt.registerLazySingleton<StopIssueRepository>(
    () => StopIssueRepositoryImpl(dataSource: getIt<StopIssueDataSource>()),
  );

  getIt.registerLazySingleton(
    () => ReportStopIssueUseCase(getIt<StopIssueRepository>()),
  );

  // Order search — opened from the detail screen's ETA pill.
  getIt.registerLazySingleton<OrderSearchLocalDataSource>(
    () => OrderSearchApiDataSource(getIt<DriverOrdersRemoteDataSource>()),
  );

  getIt.registerLazySingleton<OrderSearchRepository>(
    () => OrderSearchRepositoryImpl(
      localDataSource: getIt<OrderSearchLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => SearchOrdersUseCase(getIt<OrderSearchRepository>()),
  );

  // ── 10. Feature: Settings ──────────────────────────────────────────────

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsApiDataSource(
      dio: getIt<Dio>(),
      storage: getIt<SecureStorageService>(),
      preferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: getIt<SettingsLocalDataSource>()),
  );

  getIt.registerLazySingleton(
    () => GetProfileUseCase(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdateProfileUseCase(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton(
    () => LogoutUseCase(getIt<SettingsRepository>()),
  );

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      getProfileUseCase: getIt<GetProfileUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );

  // ── 11. Feature: Auth (BLoCs / Controllers) ─────────────────────────────

  getIt.registerFactory<OtpBloc>(() => OtpBloc(getIt<AuthRepository>()));
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: getIt<AuthRepository>(),
      clearUserPreferencesUseCase: getIt<ClearUserPreferencesUseCase>(),
    ),
  );
  getIt.registerFactory<SignupBloc>(
    () => SignupBloc(
      validateStep1UseCase: getIt<ValidateSignupStep1UseCase>(),
      pickProfileImageUseCase: getIt<PickProfileImageUseCase>(),
      validateStep3UseCase: getIt<ValidateSignupStep3UseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
    ),
  );

  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(
      loginUseCase: getIt<LoginUseCase>(),
      googleSignInUseCase: getIt<GoogleSignInUseCase>(),
      getGoogleIdTokenUseCase: getIt<GetGoogleIdTokenUseCase>(),
      setRememberMeUseCase: getIt<SetRememberMeUseCase>(),
    ),
  );

  getIt.registerLazySingleton<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(
      forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
      verifyResetOtpUseCase: getIt<VerifyResetOtpUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    ),
  );

  // ── 12. Feature: Join Company ──────────────────────────────────────────

  getIt.registerLazySingleton<JoinCompanyRemoteDataSource>(
    () => JoinCompanyRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<JoinCompanyRepository>(
    () => JoinCompanyRepositoryImpl(
      getIt<JoinCompanyRemoteDataSource>(),
      preferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton(
    () => VerifyCompanyCodeUseCase(getIt<JoinCompanyRepository>()),
  );

  getIt.registerLazySingleton(
    () => SendCompanyRequestUseCase(getIt<JoinCompanyRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetRequestStatusUseCase(getIt<JoinCompanyRepository>()),
  );

  getIt.registerLazySingleton(
    () => CancelCompanyRequestUseCase(getIt<JoinCompanyRepository>()),
  );

  getIt.registerLazySingleton<JoinCompanyBloc>(
    () => JoinCompanyBloc(
      verifyCompanyCodeUseCase: getIt<VerifyCompanyCodeUseCase>(),
      sendCompanyRequestUseCase: getIt<SendCompanyRequestUseCase>(),
      getRequestStatusUseCase: getIt<GetRequestStatusUseCase>(),
      cancelCompanyRequestUseCase: getIt<CancelCompanyRequestUseCase>(),
    ),
  );
}
