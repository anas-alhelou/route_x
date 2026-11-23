import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/fleet_company.dart';
import '../../domain/entities/fleet_info.dart';
import '../../domain/entities/route_summary.dart';
import '../widgets/delivery_signature_view.dart';

abstract class RouteFleetState extends Equatable {
  const RouteFleetState();
  @override
  List<Object?> get props => [];
}

class RouteFleetInitial extends RouteFleetState {
  const RouteFleetInitial();
}

class RouteFleetLoading extends RouteFleetState {
  const RouteFleetLoading();
}

class RouteFleetEmpty extends RouteFleetState {
  const RouteFleetEmpty();
}

class RouteFleetLocationNeeded extends RouteFleetState {
  const RouteFleetLocationNeeded({required this.fleetInfo, this.isSheetDismissed = false});
  final FleetInfo fleetInfo;
  final bool isSheetDismissed;

  RouteFleetLocationNeeded copyWith({FleetInfo? fleetInfo, bool? isSheetDismissed}) {
    return RouteFleetLocationNeeded(
      fleetInfo: fleetInfo ?? this.fleetInfo,
      isSheetDismissed: isSheetDismissed ?? this.isSheetDismissed,
    );
  }

  @override
  List<Object?> get props => [fleetInfo, isSheetDismissed];
}

class RouteFleetLoaded extends RouteFleetState {
  const RouteFleetLoaded({required this.fleetInfo, this.isSheetExpanded = false});
  final FleetInfo fleetInfo;
  final bool isSheetExpanded;

  RouteFleetLoaded copyWith({FleetInfo? fleetInfo, bool? isSheetExpanded}) {
    return RouteFleetLoaded(
      fleetInfo: fleetInfo ?? this.fleetInfo,
      isSheetExpanded: isSheetExpanded ?? this.isSheetExpanded,
    );
  }

  @override
  List<Object?> get props => [fleetInfo, isSheetExpanded];
}

class RouteFleetError extends RouteFleetState {
  const RouteFleetError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class RouteFleetPlanning extends RouteFleetState {
  const RouteFleetPlanning({required this.fleetInfo});
  final FleetInfo fleetInfo;

  @override
  List<Object?> get props => [fleetInfo];
}

class RouteFleetCheckPackages extends RouteFleetState {
  const RouteFleetCheckPackages({
    required this.fleetInfo,
    required this.checkedStopIds,
  });

  final FleetInfo fleetInfo;
  final Set<String> checkedStopIds;

  @override
  List<Object?> get props => [fleetInfo, checkedStopIds];
}

class RouteFleetReady extends RouteFleetState {
  const RouteFleetReady({
    required this.fleetInfo,
    required this.distanceMeters,
    required this.durationMinutes,
  });
  final FleetInfo fleetInfo;
  final int distanceMeters;
  final int durationMinutes;

  String get formattedDistance => '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  String get formattedDuration => '$durationMinutes min';
  String get summaryChipText => '$formattedDistance · $formattedDuration';

  @override
  List<Object?> get props => [fleetInfo, distanceMeters, durationMinutes];
}

enum ManeuverType { turnLeft, arrive }
enum DrivingModalSheet { none, navigateWith, stops, endRoute, reason, contactSteps, locationStopped, backFromMaps, routeUpdated, whatChanged, moreOptions, help, stopDetails, returnDepot, handBack, arrivingAuto, unmarkedStop, checkPackages, onBreak, wrongLocation }
enum MapAppOption { routex, googleMaps }
enum StateBannerType { none, rerouting, weakGps, offline }
enum DrivingToastType { none, sentForReview, stopMoved }

class RouteFleetDriving extends RouteFleetState {
  const RouteFleetDriving({
    required this.fleetInfo,
    required this.currentStopIndex,
    required this.maneuverType,
    required this.distanceValue,
    required this.distanceUnit,
    required this.instructionText,
    this.nextStepText,
    required this.arrivalTime,
    required this.remainingMinutes,
    required this.remainingKm,
    required this.driverLatLng,
    required this.traveledPath,
    required this.upcomingPath,
    this.depotLatLng,
    this.isTappable = true,
    this.mapControlsTop = 250.0,
    this.heading,
    this.activeSheet = DrivingModalSheet.none,
    this.selectedMapApp = MapAppOption.routex,
    this.alwaysUseApp = false,
    this.availableApps = const [MapAppOption.routex, MapAppOption.googleMaps],
    this.bannerType = StateBannerType.none,
    this.toastType = DrivingToastType.none,
    this.toastMessage,
    this.breakStartTime,
    this.allowedBreakMinutes = 15,
  });

  final FleetInfo fleetInfo;
  final int currentStopIndex;
  final ManeuverType maneuverType;
  final String distanceValue;
  final String distanceUnit;
  final String instructionText;
  final String? nextStepText;
  final String arrivalTime;
  final int remainingMinutes;
  final double remainingKm;
  final LatLng driverLatLng;
  final List<LatLng> traveledPath;
  final List<LatLng> upcomingPath;
  final LatLng? depotLatLng;
  final bool isTappable;
  final double mapControlsTop;
  final double? heading;
  final DrivingModalSheet activeSheet;
  final MapAppOption selectedMapApp;
  final bool alwaysUseApp;
  final List<MapAppOption> availableApps;
  final StateBannerType bannerType;
  final DrivingToastType toastType;
  final String? toastMessage;
  final DateTime? breakStartTime;
  final int allowedBreakMinutes;

  RouteFleetDriving copyWith({
    FleetInfo? fleetInfo,
    int? currentStopIndex,
    ManeuverType? maneuverType,
    String? distanceValue,
    String? distanceUnit,
    String? instructionText,
    String? nextStepText,
    String? arrivalTime,
    int? remainingMinutes,
    double? remainingKm,
    LatLng? driverLatLng,
    List<LatLng>? traveledPath,
    List<LatLng>? upcomingPath,
    LatLng? depotLatLng,
    bool? isTappable,
    double? mapControlsTop,
    double? heading,
    DrivingModalSheet? activeSheet,
    MapAppOption? selectedMapApp,
    bool? alwaysUseApp,
    List<MapAppOption>? availableApps,
    StateBannerType? bannerType,
    DrivingToastType? toastType,
    String? toastMessage,
    DateTime? breakStartTime,
    int? allowedBreakMinutes,
  }) {
    return RouteFleetDriving(
      fleetInfo: fleetInfo ?? this.fleetInfo,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      maneuverType: maneuverType ?? this.maneuverType,
      distanceValue: distanceValue ?? this.distanceValue,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      instructionText: instructionText ?? this.instructionText,
      nextStepText: nextStepText ?? this.nextStepText,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      remainingKm: remainingKm ?? this.remainingKm,
      driverLatLng: driverLatLng ?? this.driverLatLng,
      traveledPath: traveledPath ?? this.traveledPath,
      upcomingPath: upcomingPath ?? this.upcomingPath,
      depotLatLng: depotLatLng ?? this.depotLatLng,
      isTappable: isTappable ?? this.isTappable,
      mapControlsTop: mapControlsTop ?? this.mapControlsTop,
      heading: heading ?? this.heading,
      activeSheet: activeSheet ?? this.activeSheet,
      selectedMapApp: selectedMapApp ?? this.selectedMapApp,
      alwaysUseApp: alwaysUseApp ?? this.alwaysUseApp,
      availableApps: availableApps ?? this.availableApps,
      bannerType: bannerType ?? this.bannerType,
      toastType: toastType ?? this.toastType,
      toastMessage: toastMessage ?? this.toastMessage,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      allowedBreakMinutes: allowedBreakMinutes ?? this.allowedBreakMinutes,
    );
  }

  @override
  List<Object?> get props => [
        fleetInfo,
        currentStopIndex,
        maneuverType,
        distanceValue,
        distanceUnit,
        instructionText,
        nextStepText,
        arrivalTime,
        remainingMinutes,
        remainingKm,
        driverLatLng,
        traveledPath,
        upcomingPath,
        depotLatLng,
        isTappable,
        mapControlsTop,
        heading,
        activeSheet,
        selectedMapApp,
        alwaysUseApp,
        availableApps,
        bannerType,
        toastType,
        toastMessage,
        breakStartTime,
        allowedBreakMinutes,
      ];
}

class RouteFleetArrived extends RouteFleetState {
  const RouteFleetArrived({
    required this.fleetInfo,
    required this.stopIndex,
    required this.arrivalTime,
    this.companyNote,
    required this.driverLatLng,
    required this.traveledPath,
    required this.upcomingPath,
    this.depotLatLng,
    this.activeSheet = DrivingModalSheet.none,
    this.selectedMapApp = MapAppOption.routex,
    this.alwaysUseApp = false,
  });

  final FleetInfo fleetInfo;
  final int stopIndex;
  final String arrivalTime;
  final String? companyNote;
  final LatLng driverLatLng;
  final List<LatLng> traveledPath;
  final List<LatLng> upcomingPath;
  final LatLng? depotLatLng;
  final DrivingModalSheet activeSheet;
  final MapAppOption selectedMapApp;
  final bool alwaysUseApp;

  @override
  List<Object?> get props => [
        fleetInfo,
        stopIndex,
        arrivalTime,
        companyNote,
        driverLatLng,
        traveledPath,
        upcomingPath,
        depotLatLng,
        activeSheet,
        selectedMapApp,
        alwaysUseApp,
      ];
}

class RouteFleetDelivered extends RouteFleetState {
  const RouteFleetDelivered({
    required this.fleetInfo,
    required this.deliveredStopIndex,
    required this.nextStopIndex,
    required this.deliveredCustomerName,
    required this.nextStopName,
    required this.nextStopAddressAndMeta,
    required this.driverLatLng,
    required this.traveledPath,
    required this.upcomingPath,
    this.depotLatLng,
  });

  final FleetInfo fleetInfo;
  final int deliveredStopIndex;
  final int nextStopIndex;
  final String deliveredCustomerName;
  final String nextStopName;
  final String nextStopAddressAndMeta;
  final LatLng driverLatLng;
  final List<LatLng> traveledPath;
  final List<LatLng> upcomingPath;
  final LatLng? depotLatLng;

  @override
  List<Object?> get props => [
        fleetInfo,
        deliveredStopIndex,
        nextStopIndex,
        deliveredCustomerName,
        nextStopName,
        nextStopAddressAndMeta,
        driverLatLng,
        traveledPath,
        upcomingPath,
        depotLatLng,
      ];
}

// ── Proof of Delivery States (P01 .. P04) ──────────────────────────────────

class RouteFleetProofCamera extends RouteFleetState {
  const RouteFleetProofCamera({
    this.fleetInfo,
    required this.stopNumber,
    required this.customerName,
    required this.requiresSignature,
  });

  final FleetInfo? fleetInfo;
  final int stopNumber;
  final String customerName;
  final bool requiresSignature;

  @override
  List<Object?> get props => [fleetInfo, stopNumber, customerName, requiresSignature];
}

class RouteFleetProofCheckPhoto extends RouteFleetState {
  const RouteFleetProofCheckPhoto({
    this.fleetInfo,
    this.photoPath,
    this.stopNumber = 1,
    this.customerName,
    required this.requiresSignature,
  });

  final FleetInfo? fleetInfo;
  final String? photoPath;
  final int stopNumber;
  final String? customerName;
  final bool requiresSignature;

  @override
  List<Object?> get props => [fleetInfo, photoPath, stopNumber, customerName, requiresSignature];
}

class RouteFleetProofSignature extends RouteFleetState {
  const RouteFleetProofSignature({
    required this.customerName,
    this.initialMode = SignatureMode.draw,
    this.showCantSignSheet = false,
  });

  final String customerName;
  final SignatureMode initialMode;
  final bool showCantSignSheet;

  @override
  List<Object?> get props => [customerName, initialMode, showCantSignSheet];
}

// ── Route Complete State (R19) ──────────────────────────────────────────────

class RouteFleetComplete extends RouteFleetState {
  const RouteFleetComplete({required this.summary});

  final RouteSummary summary;

  @override
  List<Object?> get props => [summary];
}

class RouteFleetNoFleetState extends RouteFleetState {
  const RouteFleetNoFleetState();
}

class RouteFleetFindFleetState extends RouteFleetState {
  const RouteFleetFindFleetState({
    this.selectedFilter = 'Nearby',
    this.searchQuery = '',
    this.fleets = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  final String selectedFilter;
  final String searchQuery;
  final List<FleetCompany> fleets;
  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        selectedFilter,
        searchQuery,
        fleets,
        isLoading,
        errorMessage,
      ];
}

class RouteFleetJoinConfirmSheetState extends RouteFleetState {
  const RouteFleetJoinConfirmSheetState({
    required this.fleetName,
    required this.companyId,
    required this.selectedFilter,
    this.isUnavailable = false,
  });
  final String fleetName;
  final String companyId;
  final String selectedFilter;
  final bool isUnavailable;

  @override
  List<Object?> get props => [
        fleetName,
        companyId,
        selectedFilter,
        isUnavailable,
      ];
}

class RouteFleetRequestedState extends RouteFleetState {
  const RouteFleetRequestedState({required this.fleetName, this.selectedFilter = 'Nearby'});
  final String fleetName;
  final String selectedFilter;

  @override
  List<Object?> get props => [fleetName, selectedFilter];
}

class RouteFleetRequestPendingState extends RouteFleetState {
  const RouteFleetRequestPendingState({required this.fleetName});
  final String fleetName;

  @override
  List<Object?> get props => [fleetName];
}

class RouteFleetCancelRequestSheetState extends RouteFleetState {
  const RouteFleetCancelRequestSheetState({required this.fleetName});
  final String fleetName;

  @override
  List<Object?> get props => [fleetName];
}

class RouteFleetApprovedState extends RouteFleetState {
  const RouteFleetApprovedState({required this.fleetName});
  final String fleetName;

  @override
  List<Object?> get props => [fleetName];
}

class RouteFleetDeclinedState extends RouteFleetState {
  const RouteFleetDeclinedState({required this.fleetName, required this.reason});
  final String fleetName;
  final String reason;

  @override
  List<Object?> get props => [fleetName, reason];
}

class RouteFleetOffShiftState extends RouteFleetState {
  const RouteFleetOffShiftState({required this.fleetName});
  final String fleetName;

  @override
  List<Object?> get props => [fleetName];
}

class RouteFleetOnShiftWaitingState extends RouteFleetState {
  const RouteFleetOnShiftWaitingState();
  @override
  List<Object?> get props => [];
}
