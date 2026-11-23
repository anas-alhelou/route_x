// lib/features/home/domain/entities/delivery_data.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/services/location/user_location.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Delivery Scenario — the dashboard's main discriminator.
// ─────────────────────────────────────────────────────────────────────────────

/// Which of the eight Home states (HM0–HM6) should be rendered.
///
/// The value is derived from the data rather than stored — once real data
/// arrives, the BLoC computes the scenario from the payload and emits a state
/// that carries it alongside the snapshot.
enum DeliveryScenario {
  /// HM0 — skeleton loaders, data still loading.
  loading,

  /// HM1 — orders ready, driver has not yet tapped "Start delivery".
  readyToStart,

  /// HM2 — driver is actively navigating to a stop.
  onRoute,

  /// HM3 — all stops completed, waiting for more.
  allCaughtUp,

  /// HM6 (Figma 6410:56236) — no orders assigned today.
  noOrdersToday,

  /// HM5 (Figma 6410:56288) — first day online, waiting for first order.
  firstDay,

  /// HM4 (Figma 6410:56444) — device has no internet connectivity.
  offline,

  /// HM8 (Figma 6410:56525) — new order arrives over first day screen.
  newOrderFirstDay,

  /// HM9 (Figma 6410:56105) — new order arrives over on-route screen.
  newOrderOnRoute;

  /// Backward-compatibility alias for [noOrdersToday].
  static const DeliveryScenario noOrders = DeliveryScenario.noOrdersToday;
}

// ─────────────────────────────────────────────────────────────────────────────
// Next-stop information (HM2).
// ─────────────────────────────────────────────────────────────────────────────

/// The next delivery stop the driver is heading to.
class NextStopInfo extends Equatable {
  const NextStopInfo({
    required this.stopLabel,
    required this.customerName,
    required this.address,
    required this.estimatedArrival,
    required this.currentStop,
    required this.totalStops,
  });

  /// E.g. "Stop 2 of 3".
  final String stopLabel;

  /// Customer's name shown under the label.
  final String customerName;

  /// Street + neighbourhood shown under the name.
  final String address;

  /// Human-readable ETA: "about 6 min".
  final String estimatedArrival;

  /// 1-based current stop index.
  final int currentStop;

  /// Total stops in this route.
  final int totalStops;

  @override
  List<Object?> get props => [
    stopLabel,
    customerName,
    address,
    estimatedArrival,
    currentStop,
    totalStops,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Attention items (HM1 / HM2 — "Needs your attention" cards).
// ─────────────────────────────────────────────────────────────────────────────

/// Category of an attention-item card.
enum AttentionItemType { newOrders, cancelledOrder, routeUpdate }

/// A single card in the "Needs your attention" section.
class AttentionItem extends Equatable {
  const AttentionItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final AttentionItemType type;

  /// Bold top line: "2 new orders offered".
  final String title;

  /// Muted bottom line: "Review and accept them".
  final String subtitle;

  @override
  List<Object?> get props => [id, type, title, subtitle];
}

// ─────────────────────────────────────────────────────────────────────────────
// First-day checklist item (HM5).
// ─────────────────────────────────────────────────────────────────────────────

/// One row in the "Before your first order" checklist.
class FirstDayCheckItem extends Equatable {
  const FirstDayCheckItem({
    required this.id,
    required this.title,
    required this.status,
    this.isComplete = true,
    this.iconAsset,
  });

  final String id;
  final String title;

  /// Status string shown on the trailing badge: "✓ On", "✓ Always", "Toyota Hiace".
  final String status;

  /// Whether the tick / check is shown.
  final bool isComplete;

  /// Optional custom SVG asset path.
  final String? iconAsset;

  @override
  List<Object?> get props => [id, title, status, isComplete, iconAsset];
}

// ─────────────────────────────────────────────────────────────────────────────
// First-day step item (HM5).
// ─────────────────────────────────────────────────────────────────────────────

/// One step in the "HOW YOUR DAY WORKS" stepper card.
class FirstDayStep extends Equatable {
  const FirstDayStep({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  /// 1-based step number (e.g. 1, 2, 3).
  final int stepNumber;

  /// Bold step title (e.g. "Get orders").
  final String title;

  /// Subtitle / description (e.g. "New orders show up in the Orders tab.").
  final String description;

  @override
  List<Object?> get props => [stepNumber, title, description];
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's summary (all states except HM5 first-day).
// ─────────────────────────────────────────────────────────────────────────────

/// The "TODAY" section figures.
class TodaySummary extends Equatable {
  const TodaySummary({
    required this.deliveredCount,
    required this.totalOrders,
    required this.distanceKm,
    required this.onRouteTime,
    required this.couldNotDeliver,
    required this.progressPercent,
  });

  /// Orders delivered so far.
  final int deliveredCount;

  /// Total orders assigned today (0 when noOrders scenario).
  final int totalOrders;

  /// Distance covered in kilometres.
  final double distanceKm;

  /// Human-readable on-route time: "1h 20m", "0m".
  final String onRouteTime;

  /// Orders that could not be delivered.
  final int couldNotDeliver;

  /// 0.0–1.0 progress fraction.
  final double progressPercent;

  @override
  List<Object?> get props => [
    deliveredCount,
    totalOrders,
    distanceKm,
    onRouteTime,
    couldNotDeliver,
    progressPercent,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// In-app incoming order notification overlay (HM8 & HM9).
// ─────────────────────────────────────────────────────────────────────────────

/// Incoming order notification card floating at the top of the Home screen.
class IncomingOrderNotification extends Equatable {
  const IncomingOrderNotification({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.subtitle,
    this.orderId,
  });

  final String id;

  /// E.g. "New order offered".
  final String title;

  /// E.g. "now".
  final String timeAgo;

  /// E.g. "Ahmed Ali, Al Rawdah · 2.4 km".
  final String subtitle;

  /// Optional order identifier.
  final String? orderId;

  @override
  List<Object?> get props => [id, title, timeAgo, subtitle, orderId];
}

// ─────────────────────────────────────────────────────────────────────────────
// The full delivery dashboard snapshot.
// ─────────────────────────────────────────────────────────────────────────────

/// Everything the delivery Home screen renders in one immutable value.
class DeliveryDashboard extends Equatable {
  const DeliveryDashboard({
    required this.driverName,
    required this.profileImagePath,
    required this.dateLabel,
    required this.scenario,
    this.today,
    this.nextStop,
    this.attentionItems = const [],
    this.firstDayChecklist = const [],
    this.firstDaySteps = const [],
    this.readyOrderCount = 0,
    this.companyName = 'Red Sea Express',
    this.isOffline = false,
    this.incomingOrderNotification,
    this.userLocation,
  });

  /// Driver's first name for the greeting.
  final String driverName;

  /// Asset path or URL for the profile avatar.
  final String profileImagePath;

  /// Formatted date: "Sunday, 11 October".
  final String dateLabel;

  /// Which HM variant to render.
  final DeliveryScenario scenario;

  /// Today's stats — null only while loading (HM0).
  final TodaySummary? today;

  /// Set only for [DeliveryScenario.onRoute] and [DeliveryScenario.newOrderOnRoute].
  final NextStopInfo? nextStop;

  /// Cards shown in "Needs your attention". Empty → section hidden.
  final List<AttentionItem> attentionItems;

  /// Checklist shown only in [DeliveryScenario.firstDay] and [DeliveryScenario.newOrderFirstDay].
  final List<FirstDayCheckItem> firstDayChecklist;

  /// Workflow steps shown in [DeliveryScenario.firstDay] and [DeliveryScenario.newOrderFirstDay].
  final List<FirstDayStep> firstDaySteps;

  /// Count of orders ready to go (HM1: "3 orders ready to go").
  final int readyOrderCount;

  /// The fleet / company name used in first-day messages.
  final String companyName;

  /// Whether the driver is currently offline (HM4).
  final bool isOffline;

  /// Set only when an in-app order notification overlay is active (HM8 & HM9).
  final IncomingOrderNotification? incomingOrderNotification;

  /// Geographic coordinates of the user if retrieved and granted.
  final UserLocation? userLocation;

  DeliveryDashboard copyWith({
    String? driverName,
    String? profileImagePath,
    String? dateLabel,
    DeliveryScenario? scenario,
    TodaySummary? today,
    NextStopInfo? nextStop,
    List<AttentionItem>? attentionItems,
    List<FirstDayCheckItem>? firstDayChecklist,
    List<FirstDayStep>? firstDaySteps,
    int? readyOrderCount,
    String? companyName,
    bool? isOffline,
    IncomingOrderNotification? incomingOrderNotification,
    UserLocation? userLocation,
  }) {
    return DeliveryDashboard(
      driverName: driverName ?? this.driverName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      dateLabel: dateLabel ?? this.dateLabel,
      scenario: scenario ?? this.scenario,
      today: today ?? this.today,
      nextStop: nextStop ?? this.nextStop,
      attentionItems: attentionItems ?? this.attentionItems,
      firstDayChecklist: firstDayChecklist ?? this.firstDayChecklist,
      firstDaySteps: firstDaySteps ?? this.firstDaySteps,
      readyOrderCount: readyOrderCount ?? this.readyOrderCount,
      companyName: companyName ?? this.companyName,
      isOffline: isOffline ?? this.isOffline,
      incomingOrderNotification:
          incomingOrderNotification ?? this.incomingOrderNotification,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [
    driverName,
    profileImagePath,
    dateLabel,
    scenario,
    today,
    nextStop,
    attentionItems,
    firstDayChecklist,
    firstDaySteps,
    readyOrderCount,
    companyName,
    isOffline,
    incomingOrderNotification,
    userLocation,
  ];
}
