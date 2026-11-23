import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

import '../../../../core/di/injection.dart';
import '../../../orders/data/datasources/driver_orders_remote_data_source.dart';
import '../../../orders/data/proof_upload_queue.dart';
import '../../../tracking/domain/tracking_service.dart';
import '../../data/models/fleet_info_model.dart';
import '../../data/models/route_stop_model.dart';
import '../../domain/services/route_flow_engine.dart';
import '../../domain/entities/fleet_info.dart';
import '../../domain/entities/proof_of_delivery.dart';
import '../../domain/entities/route_summary.dart';
import '../../domain/entities/location_report.dart';
import '../../domain/entities/stop_status.dart';
import '../../domain/usecases/get_active_route_usecase.dart';
import '../../domain/usecases/reorder_stop_usecase.dart';
import '../../domain/usecases/report_wrong_location_usecase.dart';
import '../../domain/usecases/update_stop_status_usecase.dart';
import '../../domain/usecases/search_fleets_usecase.dart';
import '../../domain/usecases/join_fleet_usecase.dart';
import '../../domain/entities/fleet_company.dart';
import 'package:routex_mobile/core/utils/external_launcher.dart';
import '../../domain/utils/route_fleet_utils.dart';
import '../widgets/delivery_signature_view.dart';
import 'route_fleet_state.dart';

enum RouteFleetTestMode {
  none,
  empty,
  locationNeeded,
  planning,
  ready,
  driving,
  drivingR11,
  drivingR12,
  drivingR13,
  drivingR20,
  drivingR21,
  drivingR22,
  proofP01,
  proofP02,
  proofP03,
  proofP03b,
  proofP04,
  drivingR16,
  drivingR28,
  drivingR17,
  drivingR18,
  drivingR19,
  drivingR23,
  drivingR24,
  drivingR25,
  drivingR30,
  drivingR33,
  drivingR34,
  drivingR26,
  drivingR26b,
  drivingR29,
  drivingR31,
  drivingR27,
  drivingR40,
  drivingR40b,
  drivingR41,
  drivingR42,
}

class RouteFleetCubit extends Cubit<RouteFleetState>
    with WidgetsBindingObserver {
  RouteFleetCubit({
    required GetActiveRouteUseCase getActiveRouteUseCase,
    required UpdateStopStatusUseCase updateStopStatusUseCase,
    ReorderStopUseCase? reorderStopUseCase,
    ReportWrongLocationUseCase? reportWrongLocationUseCase,
    SearchFleetsUseCase? searchFleetsUseCase,
    JoinFleetUseCase? joinFleetUseCase,

    // ToDO : This is Route : Fleet test mode.
    RouteFleetTestMode testMode = RouteFleetTestMode.none,
  }) : _getActiveRouteUseCase = getActiveRouteUseCase,
       _updateStopStatusUseCase = updateStopStatusUseCase,
       _reorderStopUseCase = reorderStopUseCase ?? getIt<ReorderStopUseCase>(),
       _reportWrongLocationUseCase =
           reportWrongLocationUseCase ?? getIt<ReportWrongLocationUseCase>(),
       _searchFleetsUseCase =
           searchFleetsUseCase ??
           (getIt.isRegistered<SearchFleetsUseCase>()
               ? getIt<SearchFleetsUseCase>()
               : null),
       _joinFleetUseCase =
           joinFleetUseCase ??
           (getIt.isRegistered<JoinFleetUseCase>()
               ? getIt<JoinFleetUseCase>()
               : null),
       _testMode = testMode,
       super(const RouteFleetLoading()) {
    WidgetsBinding.instance.addObserver(this);
    // Photos left over from an earlier session are sent now.
    if (getIt.isRegistered<ProofUploadQueue>()) {
      unawaited(getIt<ProofUploadQueue>().resume());
    }
    _initLocationSharingListener();
    loadActiveRoute();
  }

  final GetActiveRouteUseCase _getActiveRouteUseCase;
  final UpdateStopStatusUseCase _updateStopStatusUseCase;
  final ReorderStopUseCase _reorderStopUseCase;
  final ReportWrongLocationUseCase _reportWrongLocationUseCase;
  final SearchFleetsUseCase? _searchFleetsUseCase;
  final JoinFleetUseCase? _joinFleetUseCase;
  final RouteFleetTestMode _testMode;
  StreamSubscription<ServiceStatus>? _locationServiceSub;
  bool _externalMapsOpened = false;

  FleetInfoModel? _currentFleetInfo;

  FleetInfoModel get _effectiveFleet {
    if (_currentFleetInfo != null && _flowEngine != null) {
      final engineStops = _flowEngine!.stops
          .map(
            (s) => RouteStopModel(
              id: s.id,
              title: s.title,
              address: s.address,
              eta: s.eta,
              isCompleted:
                  _flowEngine!.stopStatuses[s.id] ==
                  StopDeliveryStatus.delivered,
              status: _flowEngine!.stopStatuses[s.id]?.name ?? 'Pending',
              // Keep every detail of the stop (R12 note, R27 details, P01/P02 door number...).
              phone: s.phone,
              gateCode: s.gateCode,
              timeWindow: s.timeWindow,
              packagesText: s.packagesText,
              companyNote: s.companyNote,
              orderId: s.orderId,
              packageType: s.packageType,
              doorNumber: s.doorNumber,
              latitude: s.latitude,
              longitude: s.longitude,
            ),
          )
          .toList();
      return FleetInfoModel(
        routeId: _currentFleetInfo!.routeId,
        routeName: _currentFleetInfo!.routeName,
        activeVehicleNumber: _currentFleetInfo!.activeVehicleNumber,
        totalDistance: _currentFleetInfo!.totalDistance,
        progressPercentage: _currentFleetInfo!.progressPercentage,
        depotInfo: _currentFleetInfo!.depotInfo,
        stops: engineStops,
      );
    }
    return _currentFleetInfo ?? _staticSpecFleetInfo;
  }

  FleetInfoModel get _specFleetInfo {
    if (_testMode == RouteFleetTestMode.none) {
      return _effectiveFleet;
    }
    return _staticSpecFleetInfo;
  }

  // Spec-compliant 3 stops for R02 and R03
  static final FleetInfoModel _staticSpecFleetInfo = FleetInfoModel(
    routeId: 'rt-spec-001',
    routeName: 'Route #3',
    activeVehicleNumber: 'RX-VAN-882',
    totalDistance: '6.8 km',
    progressPercentage: 0.0,
    depotInfo: const DepotInfoModel(
      name: 'Red Sea Express hub',
      address: 'Al Rawdah',
      distanceText: '3.1 km',
      etaText: 'arrive 11:02',
    ),
    stops: [
      RouteStopModel(
        id: 'stop-1',
        title: 'Omar Haddad',
        address: 'Sari St, Al Zahra',
        eta: '10:05',
        isCompleted: false,
        status: 'Pending',
      ),
      RouteStopModel(
        id: 'stop-2',
        title: 'Lina Fares',
        address: 'Tahlia St, Al Nahda',
        eta: '10:24',
        isCompleted: false,
        status: 'Pending',
      ),
      RouteStopModel(
        id: 'stop-3',
        title: 'Ahmed Ali',
        address: 'Prince Sultan St, Al Rawdah',
        eta: '10:41',
        isCompleted: false,
        status: 'Pending',
      ),
    ],
  );

  RouteFlowEngine? _flowEngine;
  StreamSubscription<ArrivalEvent>? _arrivalSub;
  Timer? _toastCountdownTimer;
  FleetInfo? _previousFleetInfo;
  int? _previousStopIndex;

  // TEMP simulation flag A for R41 (auto-detect arriving card on Stop 1 at idx 0)
  bool simulateAutoDetectR41 = false;
  // TEMP simulation flag B for R42 (left without marking card on Stop 2 at idx 1)
  bool simulateLeftUnmarkedR42 = false;
  // Timestamp when driver left without marking
  DateTime? leftUnmarkedTimestamp;

  /// Packages to hand back at the depot (R40 / R40b). Taken from the R19 summary
  /// when the driver taps "Directions to depot", cleared when the route is cleared.
  ReturnPackageTask? _returnTask;
  ReturnPackageTask? get returnTask => _returnTask;

  // TEMP: data for the R40 / R40b test modes.
  static const ReturnPackageTask _testReturnTask = ReturnPackageTask(
    customerNames: ['Lina Fares'],
    depotName: 'Red Sea Express hub, Al Rawdah',
    depotDistanceText: '3.1 km',
    orderIds: ['#RX-1036'],
    failureReasons: ['Customer not answering'],
  );

  void _initLocationSharingListener() {
    _locationServiceSub = Geolocator.getServiceStatusStream().listen((
      serviceStatus,
    ) {
      if (serviceStatus == ServiceStatus.disabled) {
        onLocationSharingStopped();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        getIt.isRegistered<ProofUploadQueue>()) {
      unawaited(getIt<ProofUploadQueue>().resume());
    }
    if (state == AppLifecycleState.resumed && _externalMapsOpened) {
      _externalMapsOpened = false;
      onAppResumedFromMaps();
    }
  }

  /// Live tracking runs only while a real route is being driven.
  void _startTracking() {
    if (!getIt.isRegistered<TrackingService>()) return;
    final service = getIt<TrackingService>();
    _bindTrackingStatus(service);
    unawaited(service.start());
  }

  VoidCallback? _trackingListener;

  /// Tells the driver when position sharing is not running (the session could
  /// not be opened). The service keeps retrying; the banner clears itself once
  /// sharing is back.
  void _bindTrackingStatus(TrackingService service) {
    if (_trackingListener != null) return;
    void onStatus() {
      final current = state;
      if (current is! RouteFleetDriving) return;
      switch (service.status.value) {
        case TrackingStatus.retrying:
          if (current.bannerType == StateBannerType.none) {
            emit(current.copyWith(bannerType: StateBannerType.offline));
          }
        case TrackingStatus.active:
          if (current.bannerType == StateBannerType.offline) {
            emit(current.copyWith(bannerType: StateBannerType.none));
          }
        case TrackingStatus.idle:
          break;
      }
    }

    _trackingListener = onStatus;
    service.status.addListener(onStatus);
  }

  /// Tells the backend the driver left on the route (best effort).
  // POST /orders/start-delivery needs no body (storeId only for multi-store).
  void _notifyStartDelivery() {
    if (!getIt.isRegistered<DriverOrdersRemoteDataSource>()) return;
    unawaited(
      getIt<DriverOrdersRemoteDataSource>().startDelivery().then<void>((_) {}).catchError((_) {}),
    );
  }

  /// Uploads the delivery photo for [stopId] (the order id). One retry; a
  /// failure does not block the driver.
  /// A failed upload is kept by [ProofUploadQueue] and retried until it goes
  /// through, also after the app restarts.
  void _uploadProof(String stopId, String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return;
    if (!getIt.isRegistered<ProofUploadQueue>()) return;
    unawaited(getIt<ProofUploadQueue>().submit(stopId, photoPath));
  }

  void _stopTracking() {
    if (!getIt.isRegistered<TrackingService>()) return;
    final service = getIt<TrackingService>();
    final listener = _trackingListener;
    if (listener != null) {
      service.status.removeListener(listener);
      _trackingListener = null;
    }
    unawaited(service.stop());
  }

  @override
  Future<void> close() {
    _stopTracking();
    WidgetsBinding.instance.removeObserver(this);
    _locationServiceSub?.cancel();
    _arrivalSub?.cancel();
    _toastCountdownTimer?.cancel();
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> loadActiveRoute() async {
    emit(const RouteFleetLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    // The tab may have been left while the delay ran.
    if (isClosed) return;
    try {
      if (_testMode == RouteFleetTestMode.empty) {
        emit(const RouteFleetEmpty());
        return;
      }
      if (_testMode == RouteFleetTestMode.locationNeeded) {
        emit(RouteFleetLocationNeeded(fleetInfo: _specFleetInfo));
        return;
      }
      if (_testMode == RouteFleetTestMode.ready) {
        emit(
          RouteFleetReady(
            fleetInfo: _specFleetInfo,
            distanceMeters: 6800,
            durationMinutes: 32,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.driving) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
            ],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
              LatLng(21.5300, 39.1780),
            ],
            isTappable: true,
            mapControlsTop: 250.0,
            heading: 0.0,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR11) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.arrive,
            distanceValue: '40',
            distanceUnit: 'm',
            instructionText: 'Omar Haddad is on your right',
            nextStepText: null,
            arrivalTime: '10:05',
            remainingMinutes: 1,
            remainingKm: 0.1,
            driverLatLng: const LatLng(21.5420, 39.1718),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
              LatLng(21.5420, 39.1718),
            ],
            upcomingPath: const [
              LatLng(21.5420, 39.1718),
              LatLng(21.5433, 39.1728),
            ],
            isTappable: false,
            mapControlsTop: 190.0,
            heading: -90.0,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR12) {
        emit(
          RouteFleetArrived(
            fleetInfo: _specFleetInfo,
            stopIndex: 0,
            arrivalTime: '10:05',
            companyNote: 'Call when you arrive. Building 12, 3rd floor.',
            // The driver has arrived at stop 1: the puck sits on the stop marker.
            driverLatLng: const LatLng(21.5433, 39.1728),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728), // Stop 1
            ],
            upcomingPath: const [
              LatLng(21.5433, 39.1728), // Stop 1
              LatLng(21.5580, 39.1850), // Stop 2
              LatLng(21.5300, 39.1780), // Stop 3
            ],
            // Depot marker: about 80px left of and 160px below the puck (Figma R12).
            depotLatLng: const LatLng(21.5369, 39.1696),
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR13) {
        emit(
          RouteFleetDelivered(
            fleetInfo: _specFleetInfo,
            deliveredStopIndex: 0,
            nextStopIndex: 1,
            deliveredCustomerName: 'Omar Haddad',
            nextStopName: 'Lina Fares',
            nextStopAddressAndMeta: 'Tahlia St, Al Nahda · 6 min · 1.4 km',
            // Stop 1 is delivered; the puck still covers its marker (Figma R13).
            driverLatLng: const LatLng(21.5433, 39.1728),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728), // Stop 1
            ],
            upcomingPath: const [
              LatLng(21.5433, 39.1728), // Stop 1
              LatLng(21.5580, 39.1850), // Stop 2
              LatLng(21.5300, 39.1780), // Stop 3
            ],
            depotLatLng: const LatLng(21.5369, 39.1696),
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR20) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
            ],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
              LatLng(21.5300, 39.1780),
            ],
            isTappable: true,
            mapControlsTop: 250.0,
            heading: 0.0,
            activeSheet: DrivingModalSheet.navigateWith,
            alwaysUseApp: true,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR21) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
            ],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
              LatLng(21.5300, 39.1780),
            ],
            isTappable: true,
            mapControlsTop: 250.0,
            heading: 0.0,
            activeSheet: DrivingModalSheet.stops,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR22) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 1,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
            ],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
              LatLng(21.5300, 39.1780),
            ],
            isTappable: true,
            mapControlsTop: 250.0,
            heading: 0.0,
            activeSheet: DrivingModalSheet.endRoute,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR27) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
            ],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
              LatLng(21.5300, 39.1780),
            ],
            isTappable: true,
            mapControlsTop: 250.0,
            heading: 0.0,
            activeSheet: DrivingModalSheet.stopDetails,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR40) {
        _returnTask = _testReturnTask; // TEMP test data
        emit(
          RouteFleetArrived(
            fleetInfo: _specFleetInfo,
            stopIndex: 0,
            arrivalTime: '11:02',
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [LatLng(21.5369, 39.1696)],
            depotLatLng: const LatLng(21.5369, 39.1696),
            activeSheet: DrivingModalSheet.returnDepot,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR40b) {
        _returnTask = _testReturnTask; // TEMP test data
        emit(
          RouteFleetArrived(
            fleetInfo: _specFleetInfo,
            stopIndex: 0,
            arrivalTime: '11:02',
            driverLatLng: const LatLng(21.5369, 39.1696),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5369, 39.1696),
            ],
            upcomingPath: const [],
            depotLatLng: const LatLng(21.5369, 39.1696),
            activeSheet: DrivingModalSheet.handBack,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR41) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.arrive,
            distanceValue: '0',
            distanceUnit: 'm',
            instructionText: 'Omar Haddad is on your right',
            arrivalTime: '10:05',
            remainingMinutes: 0,
            remainingKm: 0.0,
            driverLatLng: const LatLng(21.5433, 39.1728),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5433, 39.1728),
            ],
            upcomingPath: const [LatLng(21.5580, 39.1850)],
            mapControlsTop: 190.0,
            activeSheet: DrivingModalSheet.arrivingAuto,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR42) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 1,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Tahlia St',
            arrivalTime: '10:24',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [LatLng(21.5580, 39.1850)],
            mapControlsTop: 250.0,
            activeSheet: DrivingModalSheet.unmarkedStop,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.proofP01) {
        emit(
          const RouteFleetProofCamera(
            stopNumber: 1,
            customerName: 'Omar Haddad',
            requiresSignature: false,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.proofP02) {
        emit(const RouteFleetProofCheckPhoto(requiresSignature: false));
        return;
      }
      if (_testMode == RouteFleetTestMode.proofP03) {
        emit(
          const RouteFleetProofSignature(
            customerName: 'Omar Haddad',
            initialMode: SignatureMode.draw,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.proofP03b) {
        emit(
          const RouteFleetProofSignature(
            customerName: 'Omar Haddad',
            initialMode: SignatureMode.type,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.proofP04) {
        emit(
          const RouteFleetProofSignature(
            customerName: 'Omar Haddad',
            initialMode: SignatureMode.draw,
            showCantSignSheet: true,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR16) {
        emit(
          RouteFleetArrived(
            fleetInfo: _specFleetInfo,
            stopIndex: 1,
            arrivalTime: '10:24',
            driverLatLng: const LatLng(21.5497, 39.1760),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
            ],
            upcomingPath: const [
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            activeSheet: DrivingModalSheet.reason,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR28) {
        emit(
          RouteFleetArrived(
            fleetInfo: _specFleetInfo,
            stopIndex: 1,
            arrivalTime: '10:24',
            driverLatLng: const LatLng(21.5497, 39.1760),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
            ],
            upcomingPath: const [
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            activeSheet: DrivingModalSheet.contactSteps,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR17) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 2,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '40',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Hira St',
            nextStepText: 'Prince Sultan St',
            arrivalTime: '10:41',
            remainingMinutes: 5,
            remainingKm: 0.9,
            driverLatLng: const LatLng(21.5420, 39.1718),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
              LatLng(21.5420, 39.1718),
            ],
            upcomingPath: const [
              LatLng(21.5420, 39.1718),
              LatLng(21.5300, 39.1780),
            ],
            isTappable: true,
            mapControlsTop: 280.0,
            toastType: DrivingToastType.sentForReview,
            toastMessage: 'Sent to Red Sea Express for review',
            heading: 0.0,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR18) {
        emit(
          RouteFleetArrived(
            fleetInfo: _specFleetInfo,
            stopIndex: 2,
            arrivalTime: '10:41',
            driverLatLng: const LatLng(21.5497, 39.1760),
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5400, 39.1700),
              LatLng(21.5497, 39.1760),
            ],
            upcomingPath: const [],
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR19) {
        emit(
          RouteFleetComplete(
            summary: RouteSummary(
              date: DateTime(2026, 10, 11),
              driverName: 'Hamza',
              deliveredCount: 2,
              failedCount: 1,
              totalStopsCount: 3,
              totalDistanceKm: 14.2,
              totalDurationMinutes: 52,
              returnTask: const ReturnPackageTask(
                customerNames: ['Lina'],
                depotName: 'Red Sea Express hub, Al Rawdah',
                depotDistanceText: '3.1 km',
              ),
              stopSummaries: const [
                RouteStopSummary(
                  stopId: 'stop-1',
                  customerName: 'Omar Haddad',
                  status: StopDeliveryStatus.delivered,
                  timeText: '10:05',
                ),
                RouteStopSummary(
                  stopId: 'stop-2',
                  customerName: 'Lina Fares',
                  status: StopDeliveryStatus.failed,
                  failureReasonText: 'Customer not answering',
                  timeText: '10:24',
                ),
                RouteStopSummary(
                  stopId: 'stop-3',
                  customerName: 'Ahmed Ali',
                  status: StopDeliveryStatus.delivered,
                  timeText: '10:43',
                ),
              ],
            ),
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR23) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            arrivalTime: '10:07',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            mapControlsTop: 230.0,
            bannerType: StateBannerType.rerouting,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 2500));
        if (!isClosed &&
            state is RouteFleetDriving &&
            (state as RouteFleetDriving).bannerType ==
                StateBannerType.rerouting) {
          emit(
            (state as RouteFleetDriving).copyWith(
              bannerType: StateBannerType.none,
              mapControlsTop: 250.0,
            ),
          );
        }
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR24) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            arrivalTime: '10:06',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            mapControlsTop: 230.0,
            bannerType: StateBannerType.weakGps,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR25) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            arrivalTime: '10:06',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            mapControlsTop: 230.0,
            bannerType: StateBannerType.offline,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR30) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 1,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '90',
            distanceUnit: 'm',
            instructionText: 'Turn right onto Tahlia St',
            nextStepText: 'Stop 2 is on the right',
            arrivalTime: '10:24',
            remainingMinutes: 6,
            remainingKm: 1.4,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [LatLng(21.5580, 39.1850)],
            mapControlsTop: 250.0,
            toastType: DrivingToastType.stopMoved,
            toastMessage: 'Omar Haddad moved to the end of your route',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 3000));
        if (!isClosed &&
            state is RouteFleetDriving &&
            (state as RouteFleetDriving).toastType ==
                DrivingToastType.stopMoved) {
          emit(
            (state as RouteFleetDriving).copyWith(
              toastType: DrivingToastType.none,
            ),
          );
        }
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR33) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [LatLng(21.5433, 39.1728)],
            mapControlsTop: 250.0,
            activeSheet: DrivingModalSheet.locationStopped,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR34) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [LatLng(21.5433, 39.1728)],
            mapControlsTop: 250.0,
            activeSheet: DrivingModalSheet.backFromMaps,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR26) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            activeSheet: DrivingModalSheet.routeUpdated,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR26b) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            activeSheet: DrivingModalSheet.whatChanged,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR29) {
        emit(
          RouteFleetArrived(
            fleetInfo: _specFleetInfo,
            stopIndex: 0,
            arrivalTime: '10:05',
            driverLatLng: const LatLng(21.5497, 39.1760),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            activeSheet: DrivingModalSheet.moreOptions,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.drivingR31) {
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Turn left onto Sari St',
            nextStepText: 'Stop 1 is on the right',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [
              LatLng(21.5400, 39.1700),
              LatLng(21.5433, 39.1728),
              LatLng(21.5580, 39.1850),
            ],
            activeSheet: DrivingModalSheet.help,
          ),
        );
        return;
      }
      if (_testMode == RouteFleetTestMode.planning) {
        emit(RouteFleetPlanning(fleetInfo: _specFleetInfo));
        await Future.delayed(const Duration(seconds: 3));
        if (!isClosed && state is RouteFleetPlanning) {
          emit(
            RouteFleetReady(
              fleetInfo: _specFleetInfo,
              distanceMeters: 6800,
              durationMinutes: 32,
            ),
          );
        }
        return;
      }

      // Real behavior (_testMode == RouteFleetTestMode.none)
      final fleetInfo = await _getActiveRouteUseCase();
      if (isClosed) return;
      _currentFleetInfo = fleetInfo is FleetInfoModel
          ? fleetInfo
          : FleetInfoModel(
              routeId: fleetInfo.routeId,
              routeName: fleetInfo.routeName,
              activeVehicleNumber: fleetInfo.activeVehicleNumber,
              totalDistance: fleetInfo.totalDistance,
              progressPercentage: fleetInfo.progressPercentage,
              depotInfo: DepotInfoModel(
                name: fleetInfo.depotInfo.name,
                address: fleetInfo.depotInfo.address,
                distanceText: fleetInfo.depotInfo.distanceText,
                etaText: fleetInfo.depotInfo.etaText,
              ),
              stops: fleetInfo.stops
                  .map(
                    (s) => RouteStopModel(
                      id: s.id,
                      title: s.title,
                      address: s.address,
                      eta: s.eta,
                      isCompleted: s.isCompleted,
                      status: s.status,
                      orderId: s.orderId,
                      packageType: s.packageType,
                      latitude: s.latitude,
                      longitude: s.longitude,
                    ),
                  )
                  .toList(),
            );
      final effectiveFleet = _effectiveFleet;

      if (effectiveFleet.stops.isEmpty) {
        emit(const RouteFleetEmpty());
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Permission.location.status;

      if (!serviceEnabled || !permission.isGranted) {
        emit(RouteFleetLocationNeeded(fleetInfo: effectiveFleet));
      } else {
        emit(RouteFleetPlanning(fleetInfo: effectiveFleet));
        await Future.delayed(const Duration(seconds: 3));
        if (!isClosed && state is RouteFleetPlanning) {
          _flowEngine = RouteFlowEngine(stops: effectiveFleet.stops);
          emit(
            RouteFleetReady(
              fleetInfo: effectiveFleet,
              distanceMeters: 6800,
              durationMinutes: 32,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (isClosed) return;
      // `GET /orders/mine` answers 403 for a driver the backend does not let
      // work yet (no company joined). That is the "no fleet" situation, which
      // already has its own screen leading to the join flow, not an error.
      if (e.response?.statusCode == 403) {
        emit(const RouteFleetNoFleetState());
      } else {
        emit(RouteFleetError(e.toString()));
      }
    } catch (e) {
      if (isClosed) return;
      emit(RouteFleetError(e.toString()));
    }
  }

  // ── Real Triggers for System States (R33 / R34) ────────────────────────────

  void onLocationSharingStopped() {
    final current = state;
    if (current is RouteFleetDriving) {
      emit(current.copyWith(activeSheet: DrivingModalSheet.locationStopped));
    }
  }

  void onAppResumedFromMaps() {
    final current = state;
    if (current is RouteFleetDriving && _externalMapsOpened) {
      _externalMapsOpened = false;
      emit(current.copyWith(activeSheet: DrivingModalSheet.backFromMaps));
    }
  }

  // ── Data Layer Stop Reordering (R30) ────────────────────────────────────────

  Future<void> reorderStopToLast(int stopIndex) async {
    final current = state;
    if (current is RouteFleetDriving || current is RouteFleetArrived) {
      try {
        _previousFleetInfo = current is RouteFleetDriving
            ? current.fleetInfo
            : (current as RouteFleetArrived).fleetInfo;
        _previousStopIndex = current is RouteFleetDriving
            ? current.currentStopIndex
            : (current as RouteFleetArrived).stopIndex;

        final updatedFleet = await _reorderStopUseCase(stopIndex);
        _flowEngine?.moveStopToEnd(stopIndex);

        final newIndex = RouteFleetUtils.currentIndexAfterMoveToEnd(
          currentIndex: _previousStopIndex!,
          movedIndex: stopIndex,
          stopCount: updatedFleet.stops.length,
        );

        emit(
          RouteFleetDriving(
            fleetInfo: updatedFleet,
            currentStopIndex: newIndex,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Proceed to stop ${newIndex + 1}',
            arrivalTime: updatedFleet.stops[newIndex].eta,
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [LatLng(21.5433, 39.1728)],
            mapControlsTop: 250.0,
            toastType: DrivingToastType.stopMoved,
            toastMessage:
                '${_previousFleetInfo!.stops[stopIndex].title} moved to the end of your route',
            activeSheet: DrivingModalSheet.none,
          ),
        );

        _arrivalSub?.cancel();
        _toastCountdownTimer?.cancel();
        _toastCountdownTimer = Timer(const Duration(seconds: 3), () {
          final s = state;
          if (s is RouteFleetDriving &&
              s.toastType == DrivingToastType.stopMoved) {
            emit(s.copyWith(toastType: DrivingToastType.none));
            _startArrivalSimulation();
          }
        });
      } catch (e) {
        emit(RouteFleetError(e.toString()));
      }
    }
  }

  void openCheckPackagesSheet() {
    final currentState = state;
    final fleet = currentState is RouteFleetReady
        ? currentState.fleetInfo
        : currentState is RouteFleetPlanning
        ? currentState.fleetInfo
        : _specFleetInfo;
    emit(RouteFleetCheckPackages(fleetInfo: fleet, checkedStopIds: const {}));
  }

  /// R03 opened from the "Overview" map control while a route is running
  /// (Figma prototype: Overview -> R03). The engine and its timers keep running.
  void openRouteOverview() {
    final current = state;
    if (current is RouteFleetDriving) {
      emit(
        RouteFleetReady(
          fleetInfo: current.fleetInfo,
          distanceMeters:
              6800, // TEMP: route totals until they come from the route data
          durationMinutes: 32, // TEMP
        ),
      );
    }
  }

  void togglePackageChecked(String stopId) {
    final currentState = state;
    if (currentState is RouteFleetCheckPackages) {
      final updated = Set<String>.from(currentState.checkedStopIds);
      if (updated.contains(stopId)) {
        updated.remove(stopId);
      } else {
        updated.add(stopId);
      }
      emit(
        RouteFleetCheckPackages(
          fleetInfo: currentState.fleetInfo,
          checkedStopIds: updated,
        ),
      );
    }
  }

  Future<void> requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      final status = await Permission.location.request();
      if (status.isGranted) {
        final fleetInfo = await _getActiveRouteUseCase();
        final effectiveFleet = fleetInfo.stops.isEmpty
            ? _specFleetInfo
            : fleetInfo;
        // R04 "Allow location" -> R10: the route starts straight away.
        emit(
          RouteFleetReady(
            fleetInfo: effectiveFleet,
            distanceMeters: 6800,
            durationMinutes: 32,
          ),
        );
        startRoute();
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        // Denied: stay on screen
      }
    } catch (e) {
      // handle error if needed
    }
  }

  void dismissLocationSheet() {
    final currentState = state;
    if (currentState is RouteFleetLocationNeeded) {
      // R04 "Not now" -> R03: the route waits, ready to start.
      emit(
        RouteFleetReady(
          fleetInfo: currentState.fleetInfo,
          distanceMeters: 6800,
          durationMinutes: 32,
        ),
      );
    }
  }

  void startRoute() {
    final currentState = state;
    final fleet = currentState is RouteFleetCheckPackages
        ? currentState.fleetInfo
        : currentState is RouteFleetReady
        ? currentState.fleetInfo
        : currentState is RouteFleetPlanning
        ? currentState.fleetInfo
        : _specFleetInfo;

    if (_testMode == RouteFleetTestMode.none) {
      _flowEngine ??= RouteFlowEngine(stops: fleet.stops);
      _flowEngine!.startRoute();
      _startArrivalSimulation();
      _startTracking();
      _notifyStartDelivery();
    }

    emit(
      RouteFleetDriving(
        fleetInfo: fleet,
        currentStopIndex: _flowEngine?.currentIndex ?? 0,
        maneuverType: ManeuverType.turnLeft,
        distanceValue: '80',
        distanceUnit: 'm',
        instructionText: 'Turn left onto Sari St',
        nextStepText: 'Stop 1 is on the right',
        arrivalTime: '10:05',
        remainingMinutes: 4,
        remainingKm: 1.1,
        driverLatLng: const LatLng(21.5380, 39.1680),
        traveledPath: const [
          LatLng(21.5380, 39.1680),
          LatLng(21.5400, 39.1700),
        ],
        upcomingPath: const [
          LatLng(21.5400, 39.1700),
          LatLng(21.5433, 39.1728),
          LatLng(21.5580, 39.1850),
          LatLng(21.5300, 39.1780),
        ],
        isTappable: true,
        mapControlsTop: 250.0,
        heading: 0.0,
      ),
    );
  }

  void _startArrivalSimulation() {
    _arrivalSub?.cancel();
    final idx = _flowEngine?.currentIndex ?? 0;
    final emitAutoDetect = simulateAutoDetectR41 && idx == 0;
    final emitLeftUnmarked = simulateLeftUnmarkedR42 && idx == 1;

    _arrivalSub =
        SimulatedArrivalSource(
          approachDelay: const Duration(milliseconds: 2500),
          arrivalDelay: const Duration(seconds: 6),
          emitAutoDetect: emitAutoDetect,
          emitLeftUnmarked: emitLeftUnmarked,
        ).arrivalStream.listen((event) {
          if (_flowEngine == null || _testMode != RouteFleetTestMode.none) {
            return;
          }
          if (event.type == ArrivalEventType.autoDetectArriving) {
            _flowEngine!.arrive();
            final current = state;
            if (current is RouteFleetDriving) {
              final stop = _flowEngine!.stops[idx];
              emit(
                RouteFleetDriving(
                  fleetInfo: current.fleetInfo,
                  currentStopIndex: idx,
                  maneuverType: ManeuverType.arrive,
                  distanceValue: '0',
                  distanceUnit: 'm',
                  instructionText: '${stop.title} is on your right',
                  arrivalTime: stop.eta,
                  remainingMinutes: 0,
                  remainingKm: 0.0,
                  driverLatLng: const LatLng(21.5433, 39.1728),
                  traveledPath: const [LatLng(21.5380, 39.1680)],
                  upcomingPath: const [LatLng(21.5433, 39.1728)],
                  mapControlsTop: 190.0,
                  activeSheet: DrivingModalSheet.arrivingAuto,
                ),
              );
            }
          } else if (event.type == ArrivalEventType.leftWithoutMarking) {
            _flowEngine!.markLeftUnmarked();
            leftUnmarkedTimestamp = DateTime.now().subtract(
              const Duration(minutes: 2),
            );
            final current = state;
            if (current is RouteFleetArrived) {
              emit(
                RouteFleetArrived(
                  fleetInfo: current.fleetInfo,
                  stopIndex: current.stopIndex,
                  arrivalTime: current.arrivalTime,
                  driverLatLng: current.driverLatLng,
                  traveledPath: current.traveledPath,
                  upcomingPath: current.upcomingPath,
                  depotLatLng: current.depotLatLng,
                  activeSheet: DrivingModalSheet.unmarkedStop,
                ),
              );
            }
          } else if (event.type == ArrivalEventType.approaching) {
            _flowEngine!.approach();
            final current = state;
            if (current is RouteFleetDriving) {
              final stop = _flowEngine!.stops[idx];
              // R11: "almost there" banner for the current stop.
              emit(
                RouteFleetDriving(
                  fleetInfo: current.fleetInfo,
                  currentStopIndex: idx,
                  maneuverType: ManeuverType.arrive,
                  distanceValue: '40',
                  distanceUnit: 'm',
                  instructionText: '${stop.title} is on your right',
                  nextStepText: null,
                  arrivalTime: stop.eta,
                  remainingMinutes: 1,
                  remainingKm: 0.1,
                  // TEMP: fixed coordinates until real GPS positions are used.
                  driverLatLng: const LatLng(21.5420, 39.1718),
                  traveledPath: const [
                    LatLng(21.5380, 39.1680),
                    LatLng(21.5400, 39.1700),
                    LatLng(21.5420, 39.1718),
                  ],
                  upcomingPath: const [
                    LatLng(21.5420, 39.1718),
                    LatLng(21.5433, 39.1728),
                  ],
                  isTappable: false,
                  mapControlsTop: 190.0,
                  heading: -90.0,
                ),
              );
            }
          } else if (event.type == ArrivalEventType.arrived) {
            _flowEngine!.arrive();
            final currentIdx = _flowEngine!.currentIndex;
            final stop = _flowEngine!.stops[currentIdx];
            emit(
              RouteFleetArrived(
                fleetInfo: _specFleetInfo,
                stopIndex: currentIdx,
                arrivalTime: stop.eta,
                driverLatLng: const LatLng(21.5433, 39.1728),
                traveledPath: const [
                  LatLng(21.5380, 39.1680),
                  LatLng(21.5433, 39.1728),
                ],
                upcomingPath: const [LatLng(21.5433, 39.1728)],
                depotLatLng: const LatLng(21.5369, 39.1696),
              ),
            );
          }
        });
  }

  void startReturnToDepot() {
    final current = state;
    if (current is RouteFleetComplete) {
      _returnTask = current.summary.returnTask;
    }
    final fleetInfo = current is RouteFleetDriving
        ? current.fleetInfo
        : (current is RouteFleetComplete ? _specFleetInfo : _specFleetInfo);
    emit(
      RouteFleetDriving(
        fleetInfo: fleetInfo,
        currentStopIndex: 0,
        maneuverType: ManeuverType.arrive,
        distanceValue: '3.1',
        distanceUnit: 'km',
        instructionText: 'Head to ${fleetInfo.depotInfo.name}',
        arrivalTime: fleetInfo.depotInfo.etaText,
        remainingMinutes: 8,
        remainingKm: 3.1,
        driverLatLng: const LatLng(21.5380, 39.1680),
        traveledPath: const [LatLng(21.5380, 39.1680)],
        upcomingPath: const [LatLng(21.5369, 39.1696)],
        depotLatLng: const LatLng(21.5369, 39.1696),
        activeSheet: DrivingModalSheet.returnDepot,
      ),
    );
  }

  void arriveAtDepot() {
    final current = state;
    if (current is RouteFleetDriving) {
      emit(
        RouteFleetArrived(
          fleetInfo: current.fleetInfo,
          stopIndex: current.currentStopIndex,
          arrivalTime: current.arrivalTime,
          driverLatLng: const LatLng(21.5369, 39.1696),
          traveledPath: current.traveledPath,
          upcomingPath: current.upcomingPath,
          depotLatLng: current.depotLatLng,
          activeSheet: DrivingModalSheet.handBack,
        ),
      );
    }
  }

  void takeBreak() {
    _flowEngine?.startBreak();
    _arrivalSub?.cancel();
    _toastCountdownTimer?.cancel();
    final current = state;
    if (current is RouteFleetDriving) {
      emit(
        current.copyWith(
          activeSheet: DrivingModalSheet.onBreak,
          breakStartTime: _flowEngine?.breakStartTime ?? DateTime.now(),
          allowedBreakMinutes: _flowEngine?.allowedBreakMinutes ?? 15,
        ),
      );
    }
  }

  void extendBreak() {
    _flowEngine?.extendBreak(5);
    final current = state;
    if (current is RouteFleetDriving) {
      emit(
        current.copyWith(
          activeSheet: DrivingModalSheet.onBreak,
          allowedBreakMinutes: _flowEngine?.allowedBreakMinutes ?? 15,
        ),
      );
    }
  }

  void resumeBreak() {
    _flowEngine?.resumeBreak();
    closeModalSheet();
    _startArrivalSimulation();
  }

  Future<void> reportWrongLocation(
    String reasonCode,
    String reasonText, {
    LatLng? correctedLatLng,
  }) async {
    final current = state;
    final stopIndex = current is RouteFleetDriving
        ? current.currentStopIndex
        : (current is RouteFleetArrived ? current.stopIndex : 0);
    final stopId = current is RouteFleetDriving || current is RouteFleetArrived
        ? (current is RouteFleetDriving
              ? current.fleetInfo.stops[stopIndex].id
              : (current as RouteFleetArrived).fleetInfo.stops[stopIndex].id)
        : 'stop-1';

    try {
      await _reportWrongLocationUseCase(
        LocationReport(
          stopId: stopId,
          reasonCode: reasonCode,
          reasonText: reasonText,
          correctedLatLng: correctedLatLng,
        ),
      );

      final fleetInfo = current is RouteFleetDriving
          ? current.fleetInfo
          : (current is RouteFleetArrived ? current.fleetInfo : _specFleetInfo);
      final stop = fleetInfo.stops[stopIndex];
      emit(
        RouteFleetArrived(
          fleetInfo: fleetInfo,
          stopIndex: stopIndex,
          arrivalTime: stop.eta,
          driverLatLng: const LatLng(21.5433, 39.1728),
          traveledPath: const [
            LatLng(21.5380, 39.1680),
            LatLng(21.5433, 39.1728),
          ],
          upcomingPath: const [LatLng(21.5433, 39.1728)],
          depotLatLng: const LatLng(21.5369, 39.1696),
          activeSheet: DrivingModalSheet.none,
        ),
      );
    } catch (e) {
      emit(RouteFleetError(e.toString()));
    }
  }

  void endDayAtDepot() {
    _stopTracking();
    _flowEngine = null;
    _returnTask = null;
    _arrivalSub?.cancel();
    _toastCountdownTimer?.cancel();
    emit(const RouteFleetEmpty());
  }

  /// R19 "Done": the finished route is cleared (engine, timers) and R01 is what
  /// the Route tab shows next time.
  void clearCompletedRoute() => endDayAtDepot();

  void openStopFromAutoArrival() {
    _flowEngine?.arrive();
    final current = state;
    if (current is RouteFleetDriving) {
      final stop = _flowEngine != null && _flowEngine!.stops.isNotEmpty
          ? _flowEngine!.stops[current.currentStopIndex]
          : null;
      emit(
        RouteFleetArrived(
          fleetInfo: current.fleetInfo,
          stopIndex: current.currentStopIndex,
          arrivalTime: stop?.eta ?? current.arrivalTime,
          driverLatLng: current.driverLatLng,
          traveledPath: current.traveledPath,
          upcomingPath: current.upcomingPath,
          depotLatLng: const LatLng(21.5369, 39.1696),
        ),
      );
    }
  }

  void notHereYetFromAutoArrival() {
    final current = state;
    if (current is RouteFleetArrived) {
      final stop = _flowEngine != null && _flowEngine!.stops.isNotEmpty
          ? _flowEngine!.stops[current.stopIndex]
          : null;
      emit(
        RouteFleetDriving(
          fleetInfo: current.fleetInfo,
          currentStopIndex: current.stopIndex,
          maneuverType: ManeuverType.arrive,
          distanceValue: '40',
          distanceUnit: 'm',
          instructionText: '${stop?.title ?? "Stop"} is on your right',
          arrivalTime: stop?.eta ?? current.arrivalTime,
          remainingMinutes: 1,
          remainingKm: 0.1,
          driverLatLng: current.driverLatLng,
          traveledPath: current.traveledPath,
          upcomingPath: current.upcomingPath,
          depotLatLng: current.depotLatLng,
          mapControlsTop: 190.0,
        ),
      );
    } else {
      closeModalSheet();
    }
    _startArrivalSimulation();
  }

  void yesDeliveredFromUnmarked() {
    _flowEngine?.startDelivery();
    final idx = _flowEngine?.currentIndex ?? 0;
    final stop = _flowEngine != null && _flowEngine!.stops.isNotEmpty
        ? _flowEngine!.stops[idx]
        : null;
    emit(
      RouteFleetProofCamera(
        stopNumber: idx + 1,
        customerName: stop?.title ?? 'Customer',
        requiresSignature: false,
      ),
    );
  }

  void couldntDeliverFromUnmarked() {
    openModalSheet(DrivingModalSheet.reason);
  }

  void goBackFromUnmarked() {
    _flowEngine?.returnToArrived();
    final current = state;
    if (current is RouteFleetArrived) {
      emit(
        RouteFleetArrived(
          fleetInfo: current.fleetInfo,
          stopIndex: current.stopIndex,
          arrivalTime: current.arrivalTime,
          driverLatLng: current.driverLatLng,
          traveledPath: current.traveledPath,
          upcomingPath: current.upcomingPath,
          depotLatLng: current.depotLatLng,
          activeSheet: DrivingModalSheet.none,
        ),
      );
    } else if (current is RouteFleetDriving) {
      emit(
        RouteFleetArrived(
          fleetInfo: current.fleetInfo,
          stopIndex: current.currentStopIndex,
          arrivalTime: current.arrivalTime,
          driverLatLng: current.driverLatLng,
          traveledPath: current.traveledPath,
          upcomingPath: current.upcomingPath,
          depotLatLng: current.depotLatLng,
          activeSheet: DrivingModalSheet.none,
        ),
      );
    }
  }

  void completeCurrentDelivery(ProofOfDeliveryData proof) {
    _toastCountdownTimer?.cancel();
    // The photo taken in P01 travels with the proof (also when a signature follows).
    final proofWithPhoto = proof.photoPath == null && _pendingPhotoPath != null
        ? proof.copyWith(photoPath: _pendingPhotoPath)
        : proof;
    _pendingPhotoPath = null;
    if (_flowEngine != null && _testMode == RouteFleetTestMode.none) {
      final deliveredIndex = _flowEngine!.currentIndex;
      if (deliveredIndex < _flowEngine!.stops.length) {
        _uploadProof(
          _flowEngine!.stops[deliveredIndex].id,
          proofWithPhoto.photoPath,
        );
      }
      _flowEngine!.completeDelivery(proofWithPhoto);
      if (_flowEngine!.phase == RouteFlowPhase.complete) {
        _emitRouteComplete();
      } else if (_flowEngine!.phase == RouteFlowPhase.driving) {
        // Next stop is the last stop (R17, no toast)
        final newIdx = _flowEngine!.currentIndex;
        final stop = _flowEngine!.stops[newIdx];
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: newIdx,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Proceed to stop ${newIdx + 1}',
            arrivalTime: stop.eta,
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680), // TEMP
            traveledPath: const [LatLng(21.5380, 39.1680)], // TEMP
            upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
            mapControlsTop: 250.0,
          ),
        );
        _startArrivalSimulation();
      } else if (_flowEngine!.phase == RouteFlowPhase.deliveredToast) {
        final deliveredIdx = _flowEngine!.currentIndex;
        final nextIdx =
            (_flowEngine!.currentIndex + 1 < _flowEngine!.stops.length)
            ? _flowEngine!.currentIndex + 1
            : deliveredIdx;
        final deliveredStop = _flowEngine!.stops[deliveredIdx];
        final nextStop = _flowEngine!.stops[nextIdx];

        emit(
          RouteFleetDelivered(
            fleetInfo: _specFleetInfo,
            deliveredStopIndex: deliveredIdx,
            nextStopIndex: nextIdx,
            deliveredCustomerName: deliveredStop.title,
            nextStopName: nextStop.title,
            nextStopAddressAndMeta: '${nextStop.address} · 6 min · 1.4 km',
            driverLatLng: const LatLng(21.5433, 39.1728), // TEMP
            traveledPath: const [
              LatLng(21.5380, 39.1680),
              LatLng(21.5433, 39.1728),
            ], // TEMP
            upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
            depotLatLng: const LatLng(21.5369, 39.1696), // TEMP
          ),
        );

        _toastCountdownTimer = Timer(const Duration(seconds: 3), () {
          goToNextStopFromToast();
        });
      }
    } else {
      emit(const RouteFleetProofCheckPhoto(requiresSignature: false));
    }
  }

  void goToNextStopFromToast() {
    _toastCountdownTimer?.cancel();
    if (_flowEngine == null ||
        _flowEngine!.phase != RouteFlowPhase.deliveredToast ||
        _testMode != RouteFleetTestMode.none) {
      return;
    }
    _flowEngine!.advanceToNextStop();
    if (_flowEngine!.phase == RouteFlowPhase.complete) {
      _emitRouteComplete();
    } else {
      final newIdx = _flowEngine!.currentIndex;
      final stop = _flowEngine!.stops[newIdx];
      emit(
        RouteFleetDriving(
          fleetInfo: _specFleetInfo,
          currentStopIndex: newIdx,
          maneuverType: ManeuverType.turnLeft,
          distanceValue: '80',
          distanceUnit: 'm',
          instructionText: 'Proceed to next stop',
          arrivalTime: stop.eta,
          remainingMinutes: 4,
          remainingKm: 1.1,
          driverLatLng: const LatLng(21.5380, 39.1680), // TEMP
          traveledPath: const [LatLng(21.5380, 39.1680)], // TEMP
          upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
          mapControlsTop: 250.0,
        ),
      );
      _startArrivalSimulation();
    }
  }

  /// True when a real route is running (not a test mode).
  bool get hasActiveRoute => _flowEngine != null;

  /// Whether the stop at [index] was marked as failed by the driver.
  bool isStopFailed(int index) {
    final engine = _flowEngine;
    if (engine == null || index < 0 || index >= engine.stops.length) {
      return false;
    }
    return engine.stopStatuses[engine.stops[index].id] ==
        StopDeliveryStatus.failed;
  }

  void failCurrentStop(String reasonCode, String reasonText) {
    _toastCountdownTimer?.cancel();
    if (_flowEngine != null && _testMode == RouteFleetTestMode.none) {
      _flowEngine!.failStop(reasonCode, reasonText);
      if (_flowEngine!.phase == RouteFlowPhase.complete) {
        _emitRouteComplete();
      } else {
        final newIdx = _flowEngine!.currentIndex;
        final stop = _flowEngine!.stops[newIdx];
        emit(
          RouteFleetDriving(
            fleetInfo: _specFleetInfo,
            currentStopIndex: newIdx,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Proceed to next stop',
            arrivalTime: stop.eta,
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680), // TEMP
            traveledPath: const [LatLng(21.5380, 39.1680)], // TEMP
            upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
            mapControlsTop:
                280.0, // Figma R17: the toast pushes the map controls down
            toastType: DrivingToastType.sentForReview,
            toastMessage: 'Sent to Red Sea Express for review',
          ),
        );
        _startArrivalSimulation();
      }
    }
  }

  void endRouteEarly() {
    _toastCountdownTimer?.cancel();
    if (_flowEngine != null && _testMode == RouteFleetTestMode.none) {
      _flowEngine!.endRoute();
      _emitRouteComplete();
    } else {
      emit(
        RouteFleetComplete(
          summary: RouteSummary(
            date: DateTime.now(),
            driverName: 'Hamza',
            deliveredCount: 1,
            failedCount: 2,
            totalStopsCount: 3,
            totalDistanceKm: 14.2,
            totalDurationMinutes: 52,
            returnTask: const ReturnPackageTask(
              customerNames: ['Lina Fares'],
              depotName: 'Red Sea Express hub, Al Rawdah',
              depotDistanceText: '3.1 km',
            ),
            stopSummaries: const [
              RouteStopSummary(
                stopId: 'stop-1',
                customerName: 'Omar Haddad',
                status: StopDeliveryStatus.delivered,
                timeText: '10:05',
              ),
              RouteStopSummary(
                stopId: 'stop-2',
                customerName: 'Lina Fares',
                status: StopDeliveryStatus.failed,
                failureReasonText: 'Returned by end route',
                timeText: '10:24',
              ),
              RouteStopSummary(
                stopId: 'stop-3',
                customerName: 'Ahmed Ali',
                status: StopDeliveryStatus.failed,
                failureReasonText: 'Returned by end route',
                timeText: '10:41',
              ),
            ],
          ),
        ),
      );
    }
  }

  void undoLast() {
    _toastCountdownTimer?.cancel();
    if (_flowEngine != null && _testMode == RouteFleetTestMode.none) {
      final success = _flowEngine!.undoLast();
      if (!success) return;
      final currentPhase = _flowEngine!.phase;
      final idx = _flowEngine!.currentIndex;
      final stop = _flowEngine!.stops[idx];

      switch (currentPhase) {
        case RouteFlowPhase.ready:
          emit(
            RouteFleetReady(
              fleetInfo: _specFleetInfo,
              distanceMeters: 6800,
              durationMinutes: 32,
            ),
          );
          break;
        case RouteFlowPhase.driving:
          emit(
            RouteFleetDriving(
              fleetInfo: _specFleetInfo,
              currentStopIndex: idx,
              maneuverType: ManeuverType.turnLeft,
              distanceValue: '80',
              distanceUnit: 'm',
              instructionText: 'Proceed to stop ${idx + 1}',
              arrivalTime: stop.eta,
              remainingMinutes: 4,
              remainingKm: 1.1,
              driverLatLng: const LatLng(21.5380, 39.1680), // TEMP
              traveledPath: const [LatLng(21.5380, 39.1680)], // TEMP
              upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
              mapControlsTop: 250.0,
            ),
          );
          _startArrivalSimulation();
          break;
        case RouteFlowPhase.approaching:
          emit(
            RouteFleetDriving(
              fleetInfo: _specFleetInfo,
              currentStopIndex: idx,
              maneuverType: ManeuverType.arrive,
              distanceValue: '40',
              distanceUnit: 'm',
              instructionText: '${stop.title} is on your right',
              arrivalTime: stop.eta,
              remainingMinutes: 1,
              remainingKm: 0.1,
              driverLatLng: const LatLng(21.5420, 39.1718), // TEMP
              traveledPath: const [
                LatLng(21.5380, 39.1680),
                LatLng(21.5420, 39.1718),
              ], // TEMP
              upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
              mapControlsTop: 190.0,
            ),
          );
          break;
        case RouteFlowPhase.arrived:
          emit(
            RouteFleetArrived(
              fleetInfo: _specFleetInfo,
              stopIndex: idx,
              arrivalTime: stop.eta,
              driverLatLng: const LatLng(21.5433, 39.1728), // TEMP
              traveledPath: const [
                LatLng(21.5380, 39.1680),
                LatLng(21.5433, 39.1728),
              ], // TEMP
              upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
              depotLatLng: const LatLng(21.5369, 39.1696), // TEMP
            ),
          );
          break;
        case RouteFlowPhase.leftUnmarked:
          emit(
            RouteFleetArrived(
              fleetInfo: _specFleetInfo,
              stopIndex: idx,
              arrivalTime: stop.eta,
              driverLatLng: const LatLng(21.5433, 39.1728), // TEMP
              traveledPath: const [
                LatLng(21.5380, 39.1680),
                LatLng(21.5433, 39.1728),
              ], // TEMP
              upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
              depotLatLng: const LatLng(21.5369, 39.1696), // TEMP
              activeSheet: DrivingModalSheet.unmarkedStop,
            ),
          );
          break;
        case RouteFlowPhase.onBreak:
          emit(
            RouteFleetDriving(
              fleetInfo: _specFleetInfo,
              currentStopIndex: idx,
              maneuverType: ManeuverType.turnLeft,
              distanceValue: '80',
              distanceUnit: 'm',
              instructionText: 'On break',
              arrivalTime: stop.eta,
              remainingMinutes: 4,
              remainingKm: 1.1,
              driverLatLng: const LatLng(21.5380, 39.1680), // TEMP
              traveledPath: const [LatLng(21.5380, 39.1680)], // TEMP
              upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
              mapControlsTop: 250.0,
              activeSheet: DrivingModalSheet.onBreak,
            ),
          );
          break;
        case RouteFlowPhase.delivering:
          emit(
            RouteFleetProofCamera(
              stopNumber: idx + 1,
              customerName: stop.title,
              requiresSignature: idx == _flowEngine!.stops.length - 1,
            ),
          );
          break;
        case RouteFlowPhase.deliveredToast:
          final deliveredIdx = idx;
          final nextIdx = (idx + 1 < _flowEngine!.stops.length) ? idx + 1 : idx;
          final deliveredStop = _flowEngine!.stops[deliveredIdx];
          final nextStop = _flowEngine!.stops[nextIdx];

          emit(
            RouteFleetDelivered(
              fleetInfo: _specFleetInfo,
              deliveredStopIndex: deliveredIdx,
              nextStopIndex: nextIdx,
              deliveredCustomerName: deliveredStop.title,
              nextStopName: nextStop.title,
              nextStopAddressAndMeta: '${nextStop.address} · 6 min · 1.4 km',
              driverLatLng: const LatLng(21.5433, 39.1728), // TEMP
              traveledPath: const [
                LatLng(21.5380, 39.1680),
                LatLng(21.5433, 39.1728),
              ], // TEMP
              upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
              depotLatLng: const LatLng(21.5369, 39.1696), // TEMP
            ),
          );

          _toastCountdownTimer = Timer(const Duration(seconds: 3), () {
            if (!isClosed &&
                _flowEngine != null &&
                _flowEngine!.phase == RouteFlowPhase.deliveredToast) {
              _flowEngine!.advanceToNextStop();
              final newIdx = _flowEngine!.currentIndex;
              final nextStp = _flowEngine!.stops[newIdx];
              emit(
                RouteFleetDriving(
                  fleetInfo: _specFleetInfo,
                  currentStopIndex: newIdx,
                  maneuverType: ManeuverType.turnLeft,
                  distanceValue: '80',
                  distanceUnit: 'm',
                  instructionText: 'Proceed to next stop',
                  arrivalTime: nextStp.eta,
                  remainingMinutes: 4,
                  remainingKm: 1.1,
                  driverLatLng: const LatLng(21.5380, 39.1680), // TEMP
                  traveledPath: const [LatLng(21.5380, 39.1680)], // TEMP
                  upcomingPath: const [LatLng(21.5433, 39.1728)], // TEMP
                  mapControlsTop: 250.0,
                ),
              );
              _startArrivalSimulation();
            }
          });
          break;
        case RouteFlowPhase.complete:
          _emitRouteComplete();
          break;
      }
    }
  }

  void undoReorderStop() {
    final current = state;
    if (_previousFleetInfo != null) {
      _flowEngine?.undoLast();
      if (current is RouteFleetDriving) {
        emit(
          current.copyWith(
            fleetInfo: _previousFleetInfo,
            currentStopIndex: _previousStopIndex ?? current.currentStopIndex,
            toastType: DrivingToastType.none,
          ),
        );
      } else {
        emit(
          RouteFleetDriving(
            fleetInfo: _previousFleetInfo!,
            currentStopIndex: _previousStopIndex ?? 0,
            maneuverType: ManeuverType.turnLeft,
            distanceValue: '80',
            distanceUnit: 'm',
            instructionText: 'Proceed to stop ${(_previousStopIndex ?? 0) + 1}',
            arrivalTime: '10:05',
            remainingMinutes: 4,
            remainingKm: 1.1,
            driverLatLng: const LatLng(21.5380, 39.1680),
            traveledPath: const [LatLng(21.5380, 39.1680)],
            upcomingPath: const [LatLng(21.5433, 39.1728)],
            mapControlsTop: 250.0,
            toastType: DrivingToastType.none,
          ),
        );
      }
      _startArrivalSimulation();
    } else if (current is RouteFleetDriving) {
      emit(current.copyWith(toastType: DrivingToastType.none));
    }
  }

  void _emitRouteComplete() {
    _stopTracking();
    if (_flowEngine == null) return;
    final summaries = _flowEngine!.stops.map((s) {
      final status =
          _flowEngine!.stopStatuses[s.id] ?? StopDeliveryStatus.upcoming;
      final reason = _flowEngine!.failureReasons[s.id];
      return RouteStopSummary(
        stopId: s.id,
        customerName: s.title,
        status: status,
        failureReasonText: reason,
        timeText: s.eta,
      );
    }).toList();

    final deliveredCount = summaries
        .where((s) => s.status == StopDeliveryStatus.delivered)
        .length;
    final failedCount = summaries
        .where((s) => s.status == StopDeliveryStatus.failed)
        .length;
    final failedStops = _flowEngine!.stops
        .where(
          (s) => _flowEngine!.stopStatuses[s.id] == StopDeliveryStatus.failed,
        )
        .toList();

    emit(
      RouteFleetComplete(
        summary: RouteSummary(
          date: DateTime.now(),
          driverName: 'Hamza',
          deliveredCount: deliveredCount,
          failedCount: failedCount,
          totalStopsCount: summaries.length,
          totalDistanceKm: 14.2,
          totalDurationMinutes: 52,
          returnTask: failedCount > 0
              ? ReturnPackageTask(
                  customerNames: failedStops.map((s) => s.title).toList(),
                  depotName: 'Red Sea Express hub, Al Rawdah',
                  depotDistanceText: '3.1 km',
                  orderIds: failedStops
                      .map((s) => s.orderId ?? '')
                      .where((id) => id.isNotEmpty)
                      .toList(),
                  failureReasons: failedStops
                      .map((s) => _flowEngine!.failureReasons[s.id] ?? '')
                      .toList(),
                )
              : null,
          stopSummaries: summaries,
        ),
      ),
    );
  }

  void openModalSheet(DrivingModalSheet sheet) {
    final current = state;
    if (current is RouteFleetDriving) {
      emit(current.copyWith(activeSheet: sheet));
    } else if (current is RouteFleetArrived) {
      emit(
        RouteFleetArrived(
          fleetInfo: current.fleetInfo,
          stopIndex: current.stopIndex,
          arrivalTime: current.arrivalTime,
          companyNote: current.companyNote,
          driverLatLng: current.driverLatLng,
          traveledPath: current.traveledPath,
          upcomingPath: current.upcomingPath,
          depotLatLng: current.depotLatLng,
          activeSheet: sheet,
          selectedMapApp: current.selectedMapApp,
          alwaysUseApp: current.alwaysUseApp,
        ),
      );
    }
  }

  void closeModalSheet() {
    final current = state;
    if (current is RouteFleetDriving) {
      emit(current.copyWith(activeSheet: DrivingModalSheet.none));
    } else if (current is RouteFleetArrived) {
      emit(
        RouteFleetArrived(
          fleetInfo: current.fleetInfo,
          stopIndex: current.stopIndex,
          arrivalTime: current.arrivalTime,
          companyNote: current.companyNote,
          driverLatLng: current.driverLatLng,
          traveledPath: current.traveledPath,
          upcomingPath: current.upcomingPath,
          depotLatLng: current.depotLatLng,
          activeSheet: DrivingModalSheet.none,
          selectedMapApp: current.selectedMapApp,
          alwaysUseApp: current.alwaysUseApp,
        ),
      );
    }
  }

  void selectMapApp(MapAppOption app) {
    final current = state;
    if (current is RouteFleetDriving) {
      emit(current.copyWith(selectedMapApp: app));
    }
  }

  /// R20 "Start directions": closes the sheet and, when an external maps app
  /// is selected, remembers that the app is leaving for it so that coming back
  /// shows the "Welcome back" sheet (R34). Selecting an app alone does not.
  void startDirections() {
    final current = state;
    if (current is RouteFleetDriving) {
      final stops = current.fleetInfo.stops;
      final destination = current.currentStopIndex < stops.length
          ? stops[current.currentStopIndex].address
          : null;
      switch (current.selectedMapApp) {
        case MapAppOption.googleMaps:
          unawaited(ExternalLauncher.googleMaps(destination));
        case MapAppOption.routex:
          break;
      }
      _externalMapsOpened = current.selectedMapApp != MapAppOption.routex;
      closeModalSheet();
    }
  }

  void toggleAlwaysUseApp(bool value) {
    final current = state;
    if (current is RouteFleetDriving) {
      emit(current.copyWith(alwaysUseApp: value));
    }
  }

  // ── Proof of Delivery Flow Transitions ──────────────────────────────────────

  /// Path of the proof photo taken in P01 until the delivery is completed.
  String? _pendingPhotoPath;

  void openProofCamera({
    int stopNumber = 1,
    String customerName = 'Omar Haddad',
    bool requiresSignature = false,
  }) {
    _pendingPhotoPath =
        null; // a new capture replaces the previous photo (Retake)
    emit(
      RouteFleetProofCamera(
        fleetInfo: _effectiveFleet,
        stopNumber: stopNumber,
        customerName: customerName,
        requiresSignature: requiresSignature,
      ),
    );
  }

  void closeProofCamera() {
    final current = state;
    if (current is RouteFleetProofCamera) {
      final stopIdx = current.stopNumber - 1;
      _flowEngine?.returnToArrived();
      final stop = _effectiveFleet.stops.length > stopIdx && stopIdx >= 0
          ? _effectiveFleet.stops[stopIdx]
          : _effectiveFleet.stops.first;
      emit(
        RouteFleetArrived(
          fleetInfo: _effectiveFleet,
          stopIndex: stopIdx,
          arrivalTime: stop.eta,
          companyNote: stop.companyNote,
          driverLatLng: const LatLng(21.5433, 39.1728),
          traveledPath: const [
            LatLng(21.5380, 39.1680),
            LatLng(21.5400, 39.1700),
            LatLng(21.5433, 39.1728),
          ],
          upcomingPath: const [
            LatLng(21.5433, 39.1728),
            LatLng(21.5580, 39.1850),
            LatLng(21.5300, 39.1780),
          ],
          depotLatLng: const LatLng(21.5369, 39.1696),
        ),
      );
    }
  }

  void capturePhotoAndCheck({
    int stopNumber = 1,
    String? customerName,
    bool requiresSignature = false,
    String? photoPath,
  }) {
    // Coming back from the signature screen keeps the photo that was already taken.
    if (photoPath != null) _pendingPhotoPath = photoPath;
    emit(
      RouteFleetProofCheckPhoto(
        fleetInfo: _effectiveFleet,
        photoPath: _pendingPhotoPath,
        stopNumber: stopNumber,
        customerName: customerName,
        requiresSignature: requiresSignature,
      ),
    );
  }

  void openProofSignature({
    String customerName = 'Omar Haddad',
    SignatureMode initialMode = SignatureMode.draw,
  }) {
    emit(
      RouteFleetProofSignature(
        customerName: customerName,
        initialMode: initialMode,
        showCantSignSheet: false,
      ),
    );
  }

  void openCantSignSheet() {
    final current = state;
    if (current is RouteFleetProofSignature) {
      emit(
        RouteFleetProofSignature(
          customerName: current.customerName,
          initialMode: current.initialMode,
          showCantSignSheet: true,
        ),
      );
    }
  }

  void closeCantSignSheet() {
    final current = state;
    if (current is RouteFleetProofSignature) {
      emit(
        RouteFleetProofSignature(
          customerName: current.customerName,
          initialMode: current.initialMode,
          showCantSignSheet: false,
        ),
      );
    }
  }

  Future<void> updateStop(String stopId, bool isCompleted) async {
    final currentState = state;
    if (currentState is RouteFleetLoaded) {
      try {
        final updatedFleet = await _updateStopStatusUseCase(
          stopId,
          isCompleted,
        );
        emit(currentState.copyWith(fleetInfo: updatedFleet));
      } catch (e) {
        emit(RouteFleetError(e.toString()));
      }
    }
  }

  void toggleSheetExpansion() {
    final currentState = state;
    if (currentState is RouteFleetLoaded) {
      emit(
        currentState.copyWith(isSheetExpanded: !currentState.isSheetExpanded),
      );
    }
  }

  // ── Onboarding Journey Actions ─────────────────────────────────────────────

  Timer? _searchDebounce;

  void goToNoFleet() {
    emit(const RouteFleetNoFleetState());
  }

  void goToFindFleet({
    String filter = 'Nearby',
    String searchQuery = '',
    List<FleetCompany> fleets = const [],
  }) {
    emit(
      RouteFleetFindFleetState(
        selectedFilter: filter,
        searchQuery: searchQuery,
        fleets: fleets,
      ),
    );
  }

  void updateSearchQuery(String query) {
    final current = state;
    final filter = current is RouteFleetFindFleetState
        ? current.selectedFilter
        : 'Nearby';

    emit(
      RouteFleetFindFleetState(
        selectedFilter: filter,
        searchQuery: query,
        isLoading: query.trim().isNotEmpty,
      ),
    );

    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      emit(
        RouteFleetFindFleetState(
          selectedFilter: filter,
          searchQuery: query,
          fleets: const [],
          isLoading: false,
        ),
      );
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchFleets(query);
    });
  }

  Future<void> searchFleets(String query) async {
    if (_searchFleetsUseCase == null) {
      emit(
        RouteFleetFindFleetState(
          searchQuery: query,
          fleets: const [],
          isLoading: false,
        ),
      );
      return;
    }

    final current = state;
    final filter = current is RouteFleetFindFleetState
        ? current.selectedFilter
        : 'Nearby';

    emit(
      RouteFleetFindFleetState(
        selectedFilter: filter,
        searchQuery: query,
        isLoading: true,
      ),
    );

    final result = await _searchFleetsUseCase(query);
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            RouteFleetFindFleetState(
              selectedFilter: filter,
              searchQuery: query,
              fleets: const [],
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (fleets) {
        if (!isClosed) {
          emit(
            RouteFleetFindFleetState(
              selectedFilter: filter,
              searchQuery: query,
              fleets: fleets,
              isLoading: false,
              errorMessage: null,
            ),
          );
        }
      },
    );
  }

  void openJoinConfirmSheet(
    String fleetName, {
    required String companyId,
    bool isUnavailable = false,
  }) {
    final current = state;
    final filter = current is RouteFleetFindFleetState
        ? current.selectedFilter
        : current is RouteFleetJoinConfirmSheetState
        ? current.selectedFilter
        : 'Nearby';
    emit(
      RouteFleetJoinConfirmSheetState(
        fleetName: fleetName,
        companyId: companyId,
        selectedFilter: filter,
        isUnavailable: isUnavailable,
      ),
    );
  }

  void closeJoinConfirmSheet() {
    final current = state;
    final filter = current is RouteFleetJoinConfirmSheetState
        ? current.selectedFilter
        : 'Nearby';
    emit(RouteFleetFindFleetState(selectedFilter: filter));
  }

  void toggleFleetUnavailable() {
    final current = state;
    if (current is RouteFleetJoinConfirmSheetState) {
      emit(
        RouteFleetJoinConfirmSheetState(
          fleetName: current.fleetName,
          companyId: current.companyId,
          selectedFilter: current.selectedFilter,
          isUnavailable: !current.isUnavailable,
        ),
      );
    }
  }

  Future<void> sendJoinRequest(
    String fleetName, {
    required String companyId,
  }) async {
    if (_testMode != RouteFleetTestMode.none) {
      final filter = state is RouteFleetJoinConfirmSheetState
          ? (state as RouteFleetJoinConfirmSheetState).selectedFilter
          : 'Nearby';
      emit(
        RouteFleetRequestedState(fleetName: fleetName, selectedFilter: filter),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed && state is RouteFleetRequestedState) {
          emit(RouteFleetRequestPendingState(fleetName: fleetName));
        }
      });
      return;
    }

    if (_joinFleetUseCase == null) {
      goToPendingReview(fleetName: fleetName);
      return;
    }

    final result = await _joinFleetUseCase(companyId);
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            RouteFleetFindFleetState(
              selectedFilter: 'Nearby',
              searchQuery: '',
              errorMessage: failure.message,
            ),
          );
        }
      },
      (companyName) {
        if (!isClosed) {
          goToPendingReview(fleetName: companyName ?? fleetName);
        }
      },
    );
  }

  void goToPendingReview({String fleetName = 'Red Sea Express'}) {
    emit(RouteFleetRequestPendingState(fleetName: fleetName));
  }

  void openCancelRequestSheet() {
    final current = state;
    final fleetName = current is RouteFleetRequestPendingState
        ? current.fleetName
        : 'Red Sea Express';
    emit(RouteFleetCancelRequestSheetState(fleetName: fleetName));
  }

  void closeCancelRequestSheet() {
    final current = state;
    final fleetName = current is RouteFleetCancelRequestSheetState
        ? current.fleetName
        : 'Red Sea Express';
    emit(RouteFleetRequestPendingState(fleetName: fleetName));
  }

  void confirmCancelRequest() {
    emit(const RouteFleetNoFleetState());
  }

  void simulateApprove() {
    emit(const RouteFleetApprovedState(fleetName: 'Red Sea Express'));
  }

  void simulateDecline() {
    emit(
      const RouteFleetDeclinedState(
        fleetName: 'Red Sea Express',
        reason:
            "Vehicle type isn't supported. This fleet only takes bikes and cars in Al Hamra.",
      ),
    );
  }

  void goToOffShift({String fleetName = 'Red Sea Express'}) {
    emit(RouteFleetOffShiftState(fleetName: fleetName));
  }

  void goToOnShiftWaiting({String fleetName = 'Red Sea Express'}) {
    emit(RouteFleetOnShiftWaitingState());
  }

  void goToApproved({String fleetName = 'Red Sea Express'}) {
    emit(RouteFleetApprovedState(fleetName: fleetName));
  }

  void triggerPlanningStateForTesting() {
    emit(RouteFleetPlanning(fleetInfo: _specFleetInfo));
  }

  /// True while a route is running, so Home must not restart it.
  bool get _isRouteRunning =>
      state is RouteFleetDriving ||
      state is RouteFleetArrived ||
      state is RouteFleetDelivered ||
      state is RouteFleetProofCamera ||
      state is RouteFleetProofCheckPhoto ||
      state is RouteFleetProofSignature ||
      state is RouteFleetComplete;

  /// Figma HM1 "Start delivery": R02 (planning) -> after 2 s -> R03 (ready).
  Future<void> beginPlanningFromHome() async {
    if (_isRouteRunning) return;
    final fleet = _specFleetInfo;
    emit(RouteFleetPlanning(fleetInfo: fleet));
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!isClosed && state is RouteFleetPlanning) {
      emit(
        RouteFleetReady(
          fleetInfo: fleet,
          distanceMeters: 6800, // TEMP: route totals until they come from the route data
          durationMinutes: 32, // TEMP
        ),
      );
    }
  }

  /// Figma HM2 "Open route": R10. A route that is already running stays as it is.
  void openRouteFromHome() {
    if (_isRouteRunning) return;
    startRoute();
  }
}
