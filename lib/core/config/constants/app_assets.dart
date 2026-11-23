/// Central registry for all static asset paths used in the RouteX app.
///
/// Always reference assets through this class — never use hard-coded
/// path strings anywhere else in the codebase.
///
/// Directory convention:
///   assets/images/svg/   → vector images (illustrations, logos)
///   assets/images/png/   → raster images (photos, graphics)
///   assets/images/jpg/   → raster photos
///   assets/icons/svg/    → vector icons
///   assets/icons/png/    → raster icons
class AppAssets {
  AppAssets._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Images — SVG
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Images — SVG
  // ---------------------------------------------------------------------------

  /// RouteX brand logo mark.
  static const String logo = 'assets/icons/svg/ic_logo.svg';

  // ---------------------------------------------------------------------------
  // Images — PNG
  // ---------------------------------------------------------------------------
  static const String imgAvatarSolidPlaceholder =
      'assets/images/png/img_avatar_solid_placeholder.png';
  static const String imgOnboardingGraphic1 =
      'assets/images/png/img_onboarding_graphic_1.png';
  static const String imgOtpEmailErrorIcon =
      'assets/images/png/img_otp_email_error_icon.png';
  static const String imgOtpEmailIcon =
      'assets/images/png/img_otp_email_icon.png';
  static const String imgYoureAllSetIllustration =
      'assets/images/png/img_youre_all_set_illustration.png';

  /// Onboarding 1's hero image ("Deliver More. Drive Less.").
  static const String imgOnboarding1 = 'assets/images/png/img_onboarding_1.png';

  /// Onboarding 2's hero image ("Every stop, in order.").
  static const String imgOnboarding2 = 'assets/images/png/img_onboarding_2.png';

  /// The driver's own photo, shown in the Home header avatar.
  static const String imgDriverAvatar =
      'assets/images/png/img_driver_avatar.png';

  /// Fleet logo — Red Sea Express.
  static const String imgFleetRedSeaExpress =
      'assets/images/png/img_fleet_red_sea_express.png';

  /// Fleet logo — KTN Wears.
  static const String imgFleetKtnWears =
      'assets/images/png/img_fleet_ktn_wears.png';

  /// Fleet logo — Dridies Dry Fruits.
  static const String imgFleetDridiesDryFruits =
      'assets/images/png/img_fleet_dridies_dry_fruits.png';

  /// Fleet logo — Bilial Pharmacy.
  ///
  /// Vector, unlike the three logos above: no raster export of this mark ships
  /// with the design, and a cross is exactly the kind of shape that stays crisp
  /// at any avatar size. [FleetAvatar] picks the renderer from the extension, so
  /// the two formats sit side by side in the fleet list without special-casing.
  static const String imgFleetBilialPharmacy =
      'assets/images/svg/img_fleet_bilial_pharmacy.svg';

  /// Fleet logo — Shaunize.
  static const String imgFleetShaunize =
      'assets/images/svg/img_fleet_shaunize.svg';

  /// Notification empty-state illustration.
  static const String imgNotificationsEmpty =
      'assets/images/png/img_notifications_empty.png';
  // Map & Action Card PNG Icons
  static const String icCompass = 'assets/images/png/compass_ic.png';
  static const String icLayers = 'assets/images/png/layers_ic.png';
  static const String icCurrentLocation =
      'assets/images/png/current_location_ic.png';
  static const String icArrowRight = 'assets/images/png/arrow_right_ic.png';
  static const String icSearchEmpty = 'assets/images/png/search_ic.png';
  static const String icNotificationN =
      'assets/images/png/notification_n_ic.png';
  static const String icErrorRequest = 'assets/images/png/error_request_ic.png';

  // ---------------------------------------------------------------------------
  // Icons — SVG
  // ---------------------------------------------------------------------------

  /// The right-pointing arrow on a CTA label.
  ///
  /// Authored as a filled arrow (not the stroked [icArrowLeft]), and the only
  /// icon here that must be mirrored in RTL — a CTA that keeps pointing right in
  /// an Arabic layout reads as "back". Callers mirror it through
  /// `DirectionMirrored` rather than swapping in a second file.
  static const String icArrow = 'assets/icons/svg/arrow_Icon.svg';

  /// The back chevron-arrow used by every top bar.
  ///
  /// Authored pointing left; [RouteXTopBar] mirrors it in RTL rather than
  /// swapping in a second file, so the two directions can never drift apart.
  static const String icArrowLeft = 'assets/icons/svg/ic_arrow_left.svg';

  static const String icBell = 'assets/icons/svg/ic_bell.svg';
  static const String icCar = 'assets/icons/svg/ic_car.svg';

  /// The tick inside a completed setup-step marker.
  ///
  /// Drawn in #222222 and tinted to white at the call site: the only background
  /// it ever appears on is the brand green fill, and keeping the file neutral
  /// means the same asset stays correct if that fill ever changes.
  static const String icCheck = 'assets/icons/svg/ic_check.svg';
  static const String icCheckCircle = 'assets/icons/svg/ic_check_circle.svg';

  static const String icChevronRight = 'assets/icons/svg/ic_chevron_right.svg';
  static const String icChevronRightSm =
      'assets/icons/svg/ic_chevron_right_sm.svg';

  /// The clipboard glyph beside the Enter Fleet Code "Paste" label.
  static const String icClipboard = 'assets/icons/svg/ic_clipboard.svg';

  /// The X in the declined-request sheet's tinted icon well.
  static const String icClose = 'assets/icons/svg/ic_close.svg';

  static const String icFilter = 'assets/icons/svg/ic_filter.svg';
  static const String icFleetVan = 'assets/icons/svg/ic_fleet_van.svg';
  static const String icGoogleG = 'assets/icons/svg/ic_google_g.svg';

  /// The circled i on a [RouteXInfoCard].
  static const String icInfo = 'assets/icons/svg/ic_info.svg';

  static const String icKey = 'assets/icons/svg/ic_key.svg';
  static const String icList = 'assets/icons/svg/ic_list.svg';
  static const String icLock = 'assets/icons/svg/ic_lock.svg';
  static const String icLogo = 'assets/icons/svg/ic_logo.svg';
  static const String icMotorcycle = 'assets/icons/svg/ic_motorcycle.svg';
  static const String icPerson = 'assets/icons/svg/ic_person.svg';
  static const String icPin = 'assets/icons/svg/ic_pin.svg';
  static const String icSearch = 'assets/icons/svg/ic_search.svg';
  static const String icStatDeliveries =
      'assets/icons/svg/ic_stat_deliveries.svg';
  static const String icStatDistance = 'assets/icons/svg/ic_stat_distance.svg';
  static const String icStatTime = 'assets/icons/svg/ic_stat_time.svg';
  static const String icTruck = 'assets/icons/svg/ic_truck.svg';
  static const String icVan = 'assets/icons/svg/ic_van.svg';
  static const String icVehicleBadge = 'assets/icons/svg/ic_vehicle_badge.svg';
  static const String icWifiOffline = 'assets/icons/svg/ic_wifi_offline.svg';
  static const String icPackage = 'assets/icons/svg/ic_package.svg';
  static const String icBan = 'assets/icons/svg/ic_ban.svg';
  static const String icNav = 'assets/icons/svg/ic_nav.svg';
  static const String icNavArrowFilled =
      'assets/icons/svg/ic_nav_arrow_filled.svg';
  static const String icRoute = 'assets/icons/svg/ic_route.svg';
  static const String icRouteCurve = 'assets/icons/svg/ic_route_curve.svg';
  static const String newRoutes = 'assets/icons/svg/new_routes.svg';
  static const String icSun = 'assets/icons/svg/ic_sun.svg';
  static const String icLogout = 'assets/icons/svg/ic_logout.svg';
  static const String icErrorCircle =
      'assets/icons/svg/ic_error_exclamation_circle.svg';
  static const String icShieldCheck = 'assets/icons/svg/ic_shield_check.svg';
  static const String icHourglass = 'assets/icons/svg/ic_hourglass.svg';
  static const String icArrowDown = 'assets/icons/svg/ic_arrow_down.svg';
  static const String icSpinner = 'assets/icons/svg/ic_spinner.svg';
  static const String icChatBubble = 'assets/icons/svg/ic_chat_bubble.svg';

  // Bottom Navigation Bar Icons
  static const String icNavHome = 'assets/icons/svg/home_ic.png';
  static const String icNavRoute = 'assets/icons/svg/route_ic.png';
  static const String icNavOrder = 'assets/icons/svg/order_ic.png';
  static const String icNavSettings = 'assets/icons/svg/settings_ic.png';

  // ---------------------------------------------------------------------------
  // Animations — JSON / Lottie
  // ---------------------------------------------------------------------------

  static const String splashAnimation = 'assets/animations/splash.json';
  static const String splashAnimationDark =
      'assets/animations/splash_dark.json';

  // ===========================================================================
  // Merged from feature/integration-all-features (route / camera / proof-of-delivery)
  // ===========================================================================

  static const String routeEmptyIc = 'assets/icons/svg/route_empty_ic.svg';

  static const String ordersEmptyIc = 'assets/icons/svg/orders_empty_ic.svg';

  static const String locationPinIc = 'assets/icons/svg/location_pin_ic.svg';


  // ---------------------------------------------------------------------------
  // Route Feature SVGs (assets/icons/svg/)
  // ---------------------------------------------------------------------------
  static const String routeIcRoute = 'assets/icons/svg/ic_route.svg';

  static const String routeIcOrders = 'assets/icons/svg/ic_orders.svg';

  static const String routeIcNavigate = 'assets/icons/svg/ic_navigate.svg';

  static const String routeIcTurnLeft = 'assets/icons/svg/ic_turn_left.svg';

  static const String routeIcTurnRight = 'assets/icons/svg/ic_turn_right.svg';

  static const String routeIcUTurn = 'assets/icons/svg/ic_u_turn.svg';

  static const String routeIcArrive = 'assets/icons/svg/ic_arrive.svg';

  static const String routeIcPin = 'assets/icons/svg/ic_pin.svg';

  static const String routeIcOverview = 'assets/icons/svg/ic_overview.svg';

  static const String routeIcStops = 'assets/icons/svg/ic_stops.svg';

  static const String routeIcRecenter = 'assets/icons/svg/ic_recenter.svg';

  static const String routeIcOffline = 'assets/icons/svg/ic_offline.svg';

  static const String routeIcCall = 'assets/icons/svg/ic_call.svg';

  static const String routeIcNote = 'assets/icons/svg/ic_note.svg';

  static const String routeIcEta = 'assets/icons/svg/ic_eta.svg';

  static const String routeIcDelivered = 'assets/icons/svg/ic_delivered.svg';

  static const String routeIcCancelled = 'assets/icons/svg/ic_cancelled.svg';

  static const String routeIcLocation = 'assets/icons/svg/ic_location.svg';

  static const String routeIcReview = 'assets/icons/svg/ic_review.svg';

  static const String routeIcHistory = 'assets/icons/svg/ic_history.svg';

  static const String routeIcPackage = 'assets/icons/svg/ic_package.svg';

  static const String routeIcArrowRight = 'assets/icons/svg/ic_arrow_right.svg';

  static const String routeIcNotification = 'assets/icons/svg/ic_notification.svg';

  static const String routeIcClockHistory = 'assets/icons/svg/ic_clock_history.svg';

  static const String routeIcVehicleProblem = 'assets/icons/svg/ic_vehicle_problem.svg';

  static const String routeIcPackageFailed = 'assets/icons/svg/ic_package_failed.svg';

  static const String routeIcHelp = 'assets/icons/svg/ic_help.svg';

  static const String routeIcBackChevron = 'assets/icons/svg/ic_back_chevron.svg';

  static const String cameraClose = 'assets/icons/svg/camera_close.svg';

  static const String cameraShutter = 'assets/icons/svg/camera_shutter.svg';

  static const String cameraFramingGuide = 'assets/icons/svg/camera_framing_guide.svg';

  static const String statusDelivered = 'assets/icons/svg/status_delivered.svg';

  static const String statusFailed = 'assets/icons/svg/status_failed.svg';

  static const String radioOff = 'assets/icons/svg/radio_off.svg';

  static const String radioOn = 'assets/icons/svg/radio_on.svg';

  static const String logoGoogleMaps = 'assets/icons/svg/logo_google_maps.svg';

  static const String logoWaze = 'assets/icons/svg/logo_waze.svg';

}
