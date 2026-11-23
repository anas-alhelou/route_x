// lib/features/route_fleet/presentation/pages/route_page.dart
import 'package:routex_mobile/core/utils/map_tiles.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/custom_button.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/fleet_info.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/route_stop.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/contact_steps_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/end_route_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/map_type_selector_bottom_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/navigate_with_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/reason_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_empty_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_map_controls.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/scrim_widget.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/state_banner.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/stops_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/top_sheet_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_update_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_changes_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/more_options_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/help_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/stop_details_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/return_trip_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/hand_back_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/arriving_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/unmarked_stop_card.dart';
import 'package:routex_mobile/core/utils/external_launcher.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/features/tracking/domain/tracking_service.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/check_packages_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/on_break_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/wrong_location_sheet.dart';

/// Pixel-perfect RoutePage widget serving as root route view supporting R01..R34.
class RoutePage extends StatefulWidget {
  const RoutePage({
    super.key,
    this.bottomCard,
    this.showMapControls = true,
    this.showPlannedRoute = true,
    this.topBadge,
    this.subBadge,
    this.subBadgeTop,
    this.showDriverPuck = true,
    this.isDottedRoute = false,
    this.isDriving = false,
    this.isDelivered = false,
    this.isArrivedOrDelivered = false,
    this.isFailedStop2 = false,
    this.drivingState,
    this.driverLatLng,
    this.traveledPath,
    this.upcomingPath,
    this.depotLatLng,
    this.stops,
    this.activeSheet = DrivingModalSheet.none,
    this.onOpenNavigateWithSheet,
    this.onOpenStopsSheet,
    this.onCloseModalSheet,
    this.onStartDirections,
    this.onSelectMapApp,
    this.onAlwaysUseChanged,
    this.onEndRouteEarlyTapped,
    this.onKeepDeliveringTapped,
    this.onEndRouteTapped,
    this.onOpenReasonSheet,
    this.onOpenContactStepsSheet,
    this.onSendReasonToCompanyTapped,
    this.onMarkCouldntDeliverTapped,
    this.onArriveAtDepot,
    this.onEndDayAtDepot,
    this.onOpenStopFromAutoArrival,
    this.onNotHereYetFromAutoArrival,
    this.onYesDeliveredFromUnmarked,
    this.onCouldntDeliverFromUnmarked,
    this.onGoBackFromUnmarked,
    this.onTryAgainLaterTapped,
    this.onTakeABreakTapped,
    this.onResumeBreakTapped,
    this.onExtendBreakTapped,
    this.onReportWrongLocationTapped,
    this.showBottomNav = false,
  });
  final Widget? bottomCard;
  final bool showMapControls;

  /// Draws the built-in sample route (line and numbered stops). Off for
  /// screens that have no route to show, such as a driver with no fleet.
  final bool showPlannedRoute;
  final Widget? topBadge;
  final Widget? subBadge;

  /// Distance of [subBadge] from the top (Figma: 195 under the banner in R30, 214 in R17).
  final double? subBadgeTop;
  final bool showDriverPuck;
  final bool isDottedRoute;
  final bool isDriving;
  final bool isDelivered;
  final bool isArrivedOrDelivered;
  final bool isFailedStop2;
  final bool showBottomNav;
  final RouteFleetDriving? drivingState;

  /// Driver position and paths for the arrived / delivered states (R12, R13),
  /// which have no [drivingState]. When null, the built-in route is used.
  final LatLng? driverLatLng;
  final List<LatLng>? traveledPath;
  final List<LatLng>? upcomingPath;

  /// Depot destination marker (white ring with a pale-green dot).
  final LatLng? depotLatLng;

  /// The route's stops. Stops that carry a real position are drawn on the map
  /// instead of the built-in sample stops (see [_hasRealStops]).
  final List<RouteStop>? stops;
  final DrivingModalSheet activeSheet;
  final VoidCallback? onOpenNavigateWithSheet;
  final VoidCallback? onOpenStopsSheet;
  final VoidCallback? onCloseModalSheet;
  final VoidCallback? onStartDirections;
  final ValueChanged<MapAppOption>? onSelectMapApp;
  final ValueChanged<bool>? onAlwaysUseChanged;
  final VoidCallback? onEndRouteEarlyTapped;
  final VoidCallback? onKeepDeliveringTapped;
  final VoidCallback? onEndRouteTapped;
  final VoidCallback? onOpenReasonSheet;
  final VoidCallback? onOpenContactStepsSheet;
  final void Function(String code, String label)? onSendReasonToCompanyTapped;
  final VoidCallback? onMarkCouldntDeliverTapped;
  final VoidCallback? onArriveAtDepot;
  final VoidCallback? onEndDayAtDepot;
  final VoidCallback? onOpenStopFromAutoArrival;
  final VoidCallback? onNotHereYetFromAutoArrival;
  final VoidCallback? onYesDeliveredFromUnmarked;
  final VoidCallback? onCouldntDeliverFromUnmarked;
  final VoidCallback? onGoBackFromUnmarked;
  final VoidCallback? onTryAgainLaterTapped;
  final VoidCallback? onTakeABreakTapped;
  final VoidCallback? onResumeBreakTapped;
  final VoidCallback? onExtendBreakTapped;
  final VoidCallback? onReportWrongLocationTapped;

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final MapController _mapController = MapController();
  final GlobalKey _sheetKey = GlobalKey();
  double _sheetHeight = 0.0;
  bool _hasFittedCamera = false;
  bool _lastIsDotted = false;
  LatLng _currentMapCenter = const LatLng(21.5433, 39.1728);
  bool _isMapReady = false;
  LatLng? _pendingDrivingCenter;

  /// Vertical latitude offset to center the driver above the bottom trip sheet in driving mode.
  static const double _kDrivingCenterLatOffset = 0.0015;

  // Driver start position (separate from stop 1, slightly behind/off route line)
  static const LatLng _driverLatLng = LatLng(21.5380, 39.1680);
  static const double _kDrivingZoom = 15.0;

  // Non-collinear planned route stops in exact order (1, 2, 3) forming a visible path
  static const List<LatLng> _plannedRoutePoints = [
    LatLng(21.5433, 39.1728), // Stop 1
    LatLng(21.5580, 39.1850), // Stop 2
    LatLng(21.5300, 39.1780), // Stop 3
  ];

  List<RouteStop> get _stopList =>
      widget.stops ?? widget.drivingState?.fleetInfo.stops ?? const <RouteStop>[];

  /// True when the backend gave at least one stop a position. Then the map
  /// shows the real stops and hides the sample route.
  bool get _hasRealStops => _stopList.any((s) => s.hasCoordinates);

  List<LatLng> get _pins => [
        for (final s in _stopList)
          if (s.hasCoordinates) LatLng(s.latitude!, s.longitude!),
      ];

  /// Points the camera has to fit: the real stops, or the sample ones.
  List<LatLng> get _stopPoints =>
      _hasRealStops ? _pins : _plannedRoutePoints;

  static const List<LatLng> _fullRoutePath = [
    _driverLatLng,
    LatLng(21.5433, 39.1728),
    LatLng(21.5580, 39.1850),
    LatLng(21.5300, 39.1780),
  ];

  static final FleetInfo _specFleetInfo = FleetInfo(
    routeId: 'rt-spec-001',
    routeName: 'Route #3',
    activeVehicleNumber: 'RX-VAN-882',
    totalDistance: '6.8 km',
    progressPercentage: 0.0,
    depotInfo: const DepotInfo(
      name: 'Red Sea Express hub',
      address: 'Al Rawdah',
      distanceText: '3.1 km',
      etaText: 'arrive 11:02',
    ),
    stops: [
      const RouteStop(
        id: 'stop-1',
        title: 'Omar Haddad',
        address: 'Sari St, Al Zahra',
        eta: '10:05',
        isCompleted: false,
        status: 'Pending',
      ),
      const RouteStop(
        id: 'stop-2',
        title: 'Lina Fares',
        address: 'Tahlia St, Al Nahda',
        eta: '10:24',
        isCompleted: false,
        status: 'Pending',
      ),
      const RouteStop(
        id: 'stop-3',
        title: 'Ahmed Ali',
        address: 'Prince Sultan St, Al Rawdah',
        eta: '10:41',
        isCompleted: false,
        status: 'Pending',
      ),
    ],
  );

  bool _isCompassActive = false;
  MapLayerStyle _currentMapStyle = MapLayerStyle.normal;
  bool _trafficEnabled = false;

  /// The current stop's customer phone, or null when there is no driving state.
  String? get _currentStopPhone {
    final driving = widget.drivingState;
    if (driving == null) return null;
    final stops = driving.fleetInfo.stops;
    final index = driving.currentStopIndex;
    return index >= 0 && index < stops.length ? stops[index].phone : null;
  }

  @override
  void initState() {
    super.initState();
    _lastIsDotted = widget.isDottedRoute;
    _updateSheetHeightAndFitCamera();
    _listenToLivePosition();
  }

  /// Real GPS fix of the driver (free: it comes from the phone), used for the
  /// puck while a route is being driven instead of the placeholder position.
  LatLng? _livePosition;
  ValueNotifier<Position?>? _liveSource;

  void _listenToLivePosition() {
    if (!getIt.isRegistered<TrackingService>()) return;
    _liveSource = getIt<TrackingService>().lastPosition;
    _liveSource!.addListener(_onLivePosition);
    _onLivePosition();
  }

  void _onLivePosition() {
    final p = _liveSource?.value;
    final next = p == null ? null : LatLng(p.latitude, p.longitude);
    if (!mounted || next == _livePosition) return;
    setState(() => _livePosition = next);
    if (next != null &&
        widget.isDriving &&
        !widget.isArrivedOrDelivered &&
        _isMapReady) {
      _mapController.move(
        LatLng(next.latitude + _kDrivingCenterLatOffset, next.longitude),
        _mapController.camera.zoom,
      );
    }
  }

  @override
  void dispose() {
    _liveSource?.removeListener(_onLivePosition);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RoutePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bottomCard != oldWidget.bottomCard ||
        widget.showDriverPuck != oldWidget.showDriverPuck ||
        widget.isDottedRoute != oldWidget.isDottedRoute ||
        widget.isDriving != oldWidget.isDriving ||
        widget.isDelivered != oldWidget.isDelivered ||
        widget.isArrivedOrDelivered != oldWidget.isArrivedOrDelivered) {
      if (widget.isDottedRoute != _lastIsDotted) {
        _lastIsDotted = widget.isDottedRoute;
        _hasFittedCamera = false;
      }
      _updateSheetHeightAndFitCamera();
    }
  }

  void _updateSheetHeightAndFitCamera() {
    if (widget.isDriving && !widget.isArrivedOrDelivered) {
      final pos =
          _livePosition ??
          widget.drivingState?.driverLatLng ??
          widget.driverLatLng ??
          _driverLatLng;
      final target = LatLng(
        pos.latitude + _kDrivingCenterLatOffset,
        pos.longitude,
      );
      if (_isMapReady) {
        _mapController.move(target, _kDrivingZoom);
      } else {
        _pendingDrivingCenter = target;
      }
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.bottomCard == null) {
        if (_sheetHeight != 0.0 || !_hasFittedCamera) {
          setState(() {
            _sheetHeight = 0.0;
            _hasFittedCamera = true;
          });
          _fitCameraToRoute();
        }
        return;
      }

      final context = _sheetKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final height = box.size.height;
          if (height > 0.0 &&
              (!_hasFittedCamera || (height - _sheetHeight).abs() > 1.0)) {
            setState(() {
              _sheetHeight = height;
              _hasFittedCamera = true;
            });
            _fitCameraToRoute();
          }
        }
      } else {
        _updateSheetHeightAndFitCamera();
      }
    });
  }

  void _fitCameraToRoute() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomClearance = widget.showBottomNav
        ? bottomInset +
              AppSizes.navBottomPadding.h +
              AppSizes.navHeight.h +
              16.h
        : bottomInset + AppSizes.sheetBottomGap.h;

    const markerRadius = 19.0;
    final topPadding =
        statusBarHeight + 64.h + 40.h + 16.h + markerRadius + 16.h;
    final bottomPadding = _sheetHeight + bottomClearance + markerRadius + 16.h;
    const leftRightPadding = 48.0;

    final pointsToFit =
        (widget.isDriving &&
            widget.isArrivedOrDelivered &&
            widget.drivingState != null)
        ? [widget.drivingState!.driverLatLng, ..._stopPoints]
        : (widget.isArrivedOrDelivered && widget.driverLatLng != null)
        ? [
            widget.driverLatLng!,
            ..._stopPoints,
            if (widget.depotLatLng != null) widget.depotLatLng!,
          ]
        : (_hasRealStops ? [if (_livePosition != null) _livePosition!, ..._pins] : _fullRoutePath);

    final bounds = LatLngBounds.fromPoints(pointsToFit);
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.fromLTRB(
            leftRightPadding,
            topPadding,
            leftRightPadding,
            bottomPadding,
          ),
        ),
      );
    } catch (_) {}
  }

  void _toggleCompassHeading() {
    setState(() {
      _isCompassActive = !_isCompassActive;
    });
    final targetRotation = _isCompassActive ? 45.0 : 0.0;
    _mapController.rotate(targetRotation);
  }

  void _openMapLayersSheet(BuildContext context) {
    showRoutexSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        top: false,
        child: MapTypeSelectorBottomSheet(
          currentStyle: _currentMapStyle,
          trafficEnabled: _trafficEnabled,
          onStyleChanged: (style) {
            setState(() {
              _currentMapStyle = style;
            });
          },
          onTrafficToggled: (enabled) {
            setState(() {
              _trafficEnabled = enabled;
            });
          },
        ),
      ),
    );
  }

  void _recenterToJeddah() {
    _mapController.move(_driverLatLng, 14.0);
  }

  /// Opens the "Join your company" flow (code, confirm, review, result).
  void _navigateToJoinCompany(BuildContext context) {
    context.push(RoutersName.joinCompanyScreen);
  }

  /// One numbered marker per stop that has a real position. A stop is shown as
  /// delivered when it is done or already passed.
  List<Marker> _realStopMarkers(int currentStopIdx) {
    final stops = _stopList;
    return [
      for (var i = 0; i < stops.length; i++)
        if (stops[i].hasCoordinates)
          _buildStopMarker(
            '${i + 1}',
            LatLng(stops[i].latitude!, stops[i].longitude!),
            isCurrent: i == currentStopIdx,
            isDelivered:
                stops[i].isCompleted || widget.isDelivered || i < currentStopIdx,
          ),
    ];
  }

  Marker _buildStopMarker(
    String number,
    LatLng point, {
    required bool isCurrent,
    bool isDelivered = false,
    bool isFailed = false,
  }) {
    final activeDriving = isCurrent && widget.isDriving;
    final fillColor = isDelivered
        ? AppColors.deliveredMarkerFill
        : isFailed
        ? AppColors.dangerSurface
        : (activeDriving ? AppColors.brandMain : AppColors.brandWhite);

    final borderColor = (activeDriving || isDelivered || isFailed)
        ? AppColors.brandWhite
        : AppColors.stopBorderUpcoming;

    final borderW = (activeDriving || isDelivered || isFailed) ? 3.w : 2.w;

    return Marker(
      point: point,
      width: 38.w,
      height: 38.h,
      alignment: Alignment.center,
      child: Container(
        width: 38.w,
        height: 38.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          border: Border.all(color: borderColor, width: borderW),
          boxShadow: (isCurrent || isDelivered || isFailed)
              ? AppTextStyles.stopMarkerShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Center(
          child: isDelivered
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CustomPaint(painter: _CheckMarkPainter()),
                )
              : isFailed
              ? const Icon(Icons.close, size: 18, color: AppColors.dangerIcon)
              : Text(
                  number,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlack,
                  ),
                ),
        ),
      ),
    );
  }

  /// Depot destination: a white ring with a pale-green dot (Figma R12-R18, R40-R42).
  Marker _buildDepotMarker(LatLng point) {
    return Marker(
      point: point,
      width: 41.w,
      height: 41.h,
      alignment: Alignment.center,
      child: Container(
        width: 41.w,
        height: 41.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.brandWhite,
          border: Border.all(color: AppColors.brandWhite, width: 3.w),
          boxShadow: AppTextStyles.stopMarkerShadow,
        ),
        child: Center(
          child: Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deliveredMarkerFill,
            ),
          ),
        ),
      ),
    );
  }

  List<Polyline> _buildPolylines() {
    final hasDrivingPaths = widget.isDriving && widget.drivingState != null;
    if (hasDrivingPaths || widget.upcomingPath != null) {
      final traveled = hasDrivingPaths
          ? widget.drivingState!.traveledPath
          : (widget.traveledPath ?? const <LatLng>[]);
      final upcoming = hasDrivingPaths
          ? widget.drivingState!.upcomingPath
          : widget.upcomingPath!;

      final List<Polyline> lines = [];
      // Traveled path (behind puck) - 2 stacked polylines
      if (traveled.isNotEmpty) {
        lines.add(
          Polyline(
            points: traveled,
            strokeWidth: 12.w,
            color: AppColors.brandWhite,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
        lines.add(
          Polyline(
            points: traveled,
            strokeWidth: 6.w,
            color: AppColors.routeTraveledLine,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
      }

      // Upcoming path - 3 stacked polylines
      if (upcoming.isNotEmpty) {
        lines.add(
          Polyline(
            points: upcoming,
            strokeWidth: 14.w,
            color: AppColors.brandWhite,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
        lines.add(
          Polyline(
            points: upcoming,
            strokeWidth: 9.w,
            color: AppColors.routeUpcomingCasing,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
        lines.add(
          Polyline(
            points: upcoming,
            strokeWidth: 6.w,
            color: AppColors.brandMain,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
      }
      return lines;
    } else {
      return [
        Polyline(
          points: _fullRoutePath,
          strokeWidth: 6.w,
          color: AppColors.brandBlack.withValues(alpha: 0.2),
          strokeCap: StrokeCap.round,
        ),
        Polyline(
          points: _fullRoutePath,
          strokeWidth: 4.w,
          color: AppColors.brandMain,
          strokeCap: StrokeCap.round,
        ),
      ];
    }
  }

  Widget _buildActiveModalSheet() {
    final effectiveSheet = widget.activeSheet != DrivingModalSheet.none
        ? widget.activeSheet
        : widget.drivingState?.activeSheet ?? DrivingModalSheet.none;

    final customerName =
        (widget.drivingState != null &&
            widget.drivingState!.fleetInfo.stops.isNotEmpty)
        ? widget
              .drivingState!
              .fleetInfo
              .stops[widget.drivingState!.currentStopIndex]
              .title
        : 'Lina Fares';

    switch (effectiveSheet) {
      case DrivingModalSheet.navigateWith:
        return NavigateWithSheet(
          customerName: customerName,
          selectedApp:
              widget.drivingState?.selectedMapApp ?? MapAppOption.routex,
          alwaysUseApp: widget.drivingState?.alwaysUseApp ?? false,
          availableApps:
              widget.drivingState?.availableApps ??
              const [
                MapAppOption.routex,
                MapAppOption.googleMaps,
              ],
          onAppSelected: widget.onSelectMapApp ?? (_) {},
          onAlwaysUseChanged: widget.onAlwaysUseChanged ?? (_) {},
          onStartDirectionsTapped:
              widget.onStartDirections ?? widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.stops:
        return StopsSheet(
          fleetInfo: widget.drivingState?.fleetInfo ?? _specFleetInfo,
          currentStopIndex: widget.drivingState?.currentStopIndex ?? 0,
          onBackToDirectionsTapped: widget.onCloseModalSheet ?? () {},
          onEndRouteEarlyTapped: widget.onEndRouteEarlyTapped ?? () {},
        );
      case DrivingModalSheet.endRoute:
        final remainingStops = widget.drivingState != null
            ? widget.drivingState!.fleetInfo.stops
                  .skip(widget.drivingState!.currentStopIndex)
                  .toList()
            : <RouteStop>[];
        return EndRouteSheet(
          remainingStops: remainingStops,
          onKeepDeliveringTapped: widget.onKeepDeliveringTapped ?? () {},
          onEndRouteTapped: widget.onEndRouteTapped ?? () {},
        );
      case DrivingModalSheet.reason:
        return ReasonSheet(
          customerName: customerName,
          companyName: 'Red Sea Express',
          onCustomerNotAnsweringTapped: widget.onOpenContactStepsSheet ?? () {},
          onSendToCompanyTapped:
              widget.onSendReasonToCompanyTapped ?? (_, __) {},
        );
      case DrivingModalSheet.contactSteps:
        return ContactStepsSheet(
          stopIndex: (widget.drivingState?.currentStopIndex ?? 0) + 1,
          totalStops: widget.drivingState?.fleetInfo.stops.length ?? 1,
          customerName: customerName,
          onCallAgainTapped: () => ExternalLauncher.call(_currentStopPhone),
          onMessageTapped: () => ExternalLauncher.sms(_currentStopPhone),
          onMarkCouldntDeliverTapped:
              widget.onMarkCouldntDeliverTapped ?? () {},
        );
      case DrivingModalSheet.locationStopped:
      case DrivingModalSheet.backFromMaps:
        return TopSheetView(
          sheetType: effectiveSheet,
          customerName: customerName,
          companyName: 'Red Sea Express',
          mapAppName: 'Google Maps',
          onTurnOnTapped: widget.onCloseModalSheet ?? () {},
          onIveArrivedTapped: () {
            // TODO: Transition to R12
          },
          onResumeTapped: widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.whatChanged:
        return RouteChangesSheet(
          companyName: 'Red Sea Express',
          updateTimestamp: '10:12',
          onGotItTapped: widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.moreOptions:
        return MoreOptionsSheet(
          onTryAgainLaterTapped:
              widget.onTryAgainLaterTapped ?? widget.onCloseModalSheet ?? () {},
          onDeliverDifferentStopTapped: () {},
          onReportWrongLocationTapped:
              widget.onReportWrongLocationTapped ??
              () {
                context.read<RouteFleetCubit>().openModalSheet(
                  DrivingModalSheet.wrongLocation,
                );
              },
          onGetHelpTapped: widget.onOpenStopsSheet ?? () {},
          onCloseTapped: widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.help:
        return HelpSheet(
          companyName: 'Red Sea Express',
          onCallDispatchTapped: () {},
          onMessageDispatchTapped: () {},
          onTakeABreakTapped:
              widget.onTakeABreakTapped ??
              () {
                context.read<RouteFleetCubit>().takeBreak();
              },
          onVehicleProblemTapped: () {},
          onUnsafeTapped: () {},
          onCloseTapped: widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.onBreak:
        final start = widget.drivingState?.breakStartTime ?? DateTime.now();
        final allowedMins = widget.drivingState?.allowedBreakMinutes ?? 15;
        return OnBreakSheet(
          breakStartTime: start,
          allowedMinutes: allowedMins,
          onResumeTapped:
              widget.onResumeBreakTapped ??
              () {
                context.read<RouteFleetCubit>().resumeBreak();
              },
          onAddMinutesTapped:
              widget.onExtendBreakTapped ??
              () {
                context.read<RouteFleetCubit>().extendBreak();
              },
        );
      case DrivingModalSheet.wrongLocation:
        final currentStop =
            (widget.drivingState != null &&
                widget.drivingState!.fleetInfo.stops.isNotEmpty)
            ? widget.drivingState!.fleetInfo.stops[widget
                  .drivingState!
                  .currentStopIndex]
            : null;
        return Stack(
          children: [
            Positioned(
              top: 80.h,
              left: 24.w,
              right: 24.w,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlack,
                    borderRadius: BorderRadius.circular(AppSizes.r20),
                    boxShadow: AppTextStyles.tripSheetShadow,
                  ),
                  child: Text(
                    context.tr.routeDragMapPin,
                    style: AppTextStyles.s14Bold.copyWith(
                      color: AppColors.brandWhite,
                    ),
                  ),
                ),
              ),
            ),
            WrongLocationSheet(
              customerName: currentStop?.title ?? 'Customer',
              onSendToDispatchTapped: (code, text) {
                context.read<RouteFleetCubit>().reportWrongLocation(
                  code,
                  text,
                  correctedLatLng: _currentMapCenter,
                );
              },
            ),
          ],
        );
      case DrivingModalSheet.stopDetails:
        final drivingState = widget.drivingState;
        final currentStop =
            (drivingState != null && drivingState.fleetInfo.stops.isNotEmpty)
            ? drivingState.fleetInfo.stops[drivingState.currentStopIndex]
            : null;
        final currentStopIdx = drivingState?.currentStopIndex ?? 0;
        final totalStops = drivingState?.fleetInfo.stops.length ?? 0;

        final metaParts = <String>[];
        if (currentStop?.address != null && currentStop!.address.isNotEmpty) {
          metaParts.add(currentStop.address);
        }
        if (currentStop?.orderId != null && currentStop!.orderId!.isNotEmpty) {
          metaParts.add(currentStop.orderId!);
        }
        if (drivingState != null) {
          metaParts.add(context.tr.routeKmShort(drivingState.remainingKm.toStringAsFixed(1)));
        }

        return StopDetailsSheet(
          stopNumber: currentStopIdx + 1,
          totalStops: totalStops > 0 ? totalStops : 1,
          customerName: currentStop?.title ?? customerName,
          metaText: metaParts.join(' · '),
          gateCode: currentStop?.gateCode,
          timeWindow: currentStop?.timeWindow,
          packagesText: currentStop?.packagesText,
          companyNote: currentStop?.companyNote,
          phone: currentStop?.phone,
          onCallTapped: () => ExternalLauncher.call(currentStop?.phone),
          onMessageTapped: () => ExternalLauncher.sms(currentStop?.phone),
          onBackToMapTapped: widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.returnDepot:
        final depotInfo = widget.drivingState?.fleetInfo.depotInfo;
        final returnTask = context.read<RouteFleetCubit>().returnTask;
        if (returnTask == null) return const SizedBox.shrink();
        final metaParts = <String>[];
        if (depotInfo?.address != null && depotInfo!.address.isNotEmpty) {
          metaParts.add(depotInfo.address);
        }
        if (depotInfo?.distanceText != null &&
            depotInfo!.distanceText.isNotEmpty) {
          metaParts.add(depotInfo.distanceText);
        }
        if (depotInfo?.etaText != null && depotInfo!.etaText.isNotEmpty) {
          metaParts.add(depotInfo.etaText);
        }
        final pkgCount = returnTask.customerNames.length;
        final pkgCountText =
            (pkgCount > 1
                ? context.tr.routePackagesToHandBack(pkgCount.toString())
                : context.tr.routePackageToHandBack(pkgCount.toString()));
        final pkgSubtitle = List.generate(
          returnTask.customerNames.length,
          (i) =>
              '${returnTask.customerNames[i]}${i < returnTask.orderIds.length && returnTask.orderIds[i].isNotEmpty ? ' · ${returnTask.orderIds[i]}' : ''}',
        ).join(', ');
        return ReturnTripCard(
          depotName: depotInfo?.name ?? '',
          metaText: metaParts.join(' · '),
          packageCountText: pkgCountText,
          packageSubtitle: pkgSubtitle,
          onAtDepotTapped:
              widget.onArriveAtDepot ?? widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.handBack:
        final returnTask = context.read<RouteFleetCubit>().returnTask;
        if (returnTask == null) return const SizedBox.shrink();
        return HandBackSheet(
          packageCount: returnTask.customerNames.length,
          customerName: returnTask.customerName,
          orderId: returnTask.orderId,
          failureReason: returnTask.failureReason,
          onReturnedTapped: widget.onEndDayAtDepot ?? () {},
        );
      case DrivingModalSheet.arrivingAuto:
        return ArrivingCard(
          customerName: customerName,
          address:
              (widget.drivingState != null &&
                  widget.drivingState!.fleetInfo.stops.isNotEmpty)
              ? widget
                    .drivingState!
                    .fleetInfo
                    .stops[widget.drivingState!.currentStopIndex]
                    .address
              : '',
          onNotHereYetTapped:
              widget.onNotHereYetFromAutoArrival ??
              widget.onCloseModalSheet ??
              () {},
          onOpenStopTapped: widget.onOpenStopFromAutoArrival ?? () {},
        );
      case DrivingModalSheet.unmarkedStop:
        final currentStopIdx = widget.drivingState?.currentStopIndex ?? 0;
        final timeAgo =
            context.read<RouteFleetCubit>().leftUnmarkedTimestamp != null
            ? context.tr.routeMinutesAgo('${DateTime.now().difference(context.read<RouteFleetCubit>().leftUnmarkedTimestamp!).inMinutes > 0 ? DateTime.now().difference(context.read<RouteFleetCubit>().leftUnmarkedTimestamp!).inMinutes : 2}')
            : context.tr.routeMinutesAgo('2');
        return UnmarkedStopCard(
          stopNumberText: '${currentStopIdx + 1}',
          customerName: customerName,
          timeAgoText: timeAgo,
          onYesDeliveredTapped: widget.onYesDeliveredFromUnmarked ?? () {},
          onCouldntDeliverTapped: widget.onCouldntDeliverFromUnmarked ?? () {},
          onGoBackTapped:
              widget.onGoBackFromUnmarked ?? widget.onCloseModalSheet ?? () {},
        );
      case DrivingModalSheet.routeUpdated:
        return const SizedBox.shrink();
      case DrivingModalSheet.checkPackages:
        return CheckPackagesSheet(
          fleetInfo: widget.drivingState?.fleetInfo ?? _specFleetInfo,
          checkedStopIds: const {},
          onPackageToggled: (_) {},
          onStartRouteTapped: () {},
          onPackageMissingTapped: () {},
        );
      case DrivingModalSheet.none:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomClearance = widget.showBottomNav
        ? bottomInset +
              AppSizes.navBottomPadding.h +
              AppSizes.navHeight.h +
              16.h
        : bottomInset + AppSizes.sheetBottomGap.h;

    String tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    if (_currentMapStyle == MapLayerStyle.satellite) {
      tileUrl =
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    } else if (_currentMapStyle == MapLayerStyle.terrain) {
      tileUrl = 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
    }

    final driverPosition =
        (widget.isDriving ? _livePosition : null) ??
        widget.drivingState?.driverLatLng ??
        widget.driverLatLng ??
        _driverLatLng;
    final driverLat = driverPosition.latitude;
    final driverLng = driverPosition.longitude;
    final drivingCenter = LatLng(driverLat + 0.0015, driverLng);
    final mapControlsTop = widget.drivingState?.mapControlsTop ?? 250.h;

    final effectiveSheet = widget.activeSheet != DrivingModalSheet.none
        ? widget.activeSheet
        : widget.drivingState?.activeSheet ?? DrivingModalSheet.none;

    final effectiveBottomCard = widget.bottomCard;

    final isTopSheetActive =
        effectiveSheet == DrivingModalSheet.locationStopped ||
        effectiveSheet == DrivingModalSheet.backFromMaps;

    final hasBottomModalSheet =
        !isTopSheetActive &&
        effectiveSheet != DrivingModalSheet.none &&
        effectiveSheet != DrivingModalSheet.routeUpdated;

    final currentStopIdx = widget.drivingState?.currentStopIndex ?? 0;
    final currentStopName =
        (widget.drivingState != null &&
            widget.drivingState!.fleetInfo.stops.isNotEmpty)
        ? widget
              .drivingState!
              .fleetInfo
              .stops[widget.drivingState!.currentStopIndex]
              .title
        : 'Omar Haddad';

    final bannerType = widget.drivingState?.bannerType ?? StateBannerType.none;

    return Scaffold(
      body: Stack(
        children: [
          // Fixed center pin for R45 Wrong Location
          if (effectiveSheet == DrivingModalSheet.wrongLocation)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.brandMain, // #8FE600
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.brandBlack,
                        size: 26.w,
                      ),
                    ),
                  ),
                  Container(
                    width: 4.w,
                    height: 12.h,
                    color: AppColors.brandBlack,
                  ),
                ],
              ),
            ),

          // ── Background Map View (flutter_map) ───────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: (widget.isDriving && !widget.isArrivedOrDelivered)
                  ? drivingCenter
                  : (_hasRealStops ? _pins.first : _driverLatLng),
              initialZoom: widget.isDriving ? _kDrivingZoom : 14.0,
              initialCameraFit:
                  (widget.isDriving && widget.isArrivedOrDelivered)
                  ? CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints([
                        LatLng(driverLat, driverLng),
                        ..._stopPoints,
                      ]),
                      padding: const EdgeInsets.all(48.0),
                    )
                  : (widget.isDriving
                        ? null
                        : CameraFit.bounds(
                            bounds: LatLngBounds.fromPoints(_fullRoutePath),
                            padding: const EdgeInsets.all(48.0),
                          )),
              onMapReady: () {
                _isMapReady = true;
                if (_pendingDrivingCenter != null) {
                  _mapController.move(_pendingDrivingCenter!, _kDrivingZoom);
                  _pendingDrivingCenter = null;
                }
                // In the arrived / delivered states the first sheet-aware fit runs
                // before the map controller is attached (the error is swallowed),
                // so fit again now that the map is ready.
                if (widget.isArrivedOrDelivered) _hasFittedCamera = false;
                _updateSheetHeightAndFitCamera();
              },
              onPositionChanged: (position, hasGesture) {
                _currentMapCenter = position.center;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: 'com.routex.routex_mobile',
                tileBuilder: themedTileBuilder,
              ),
              if (widget.showPlannedRoute && !_hasRealStops)
                PolylineLayer(polylines: _buildPolylines()),
              MarkerLayer(
                markers: [
                  // Z-Order: depot and stop markers FIRST, DriverPuck LAST so puck is always on top
                  if (widget.depotLatLng != null)
                    _buildDepotMarker(widget.depotLatLng!),
                  if (_hasRealStops)
                    ..._realStopMarkers(currentStopIdx)
                  else if (widget.showPlannedRoute) ...[
                  _buildStopMarker(
                    '1',
                    _plannedRoutePoints[0],
                    isCurrent: currentStopIdx == 0,
                    isDelivered: widget.isDelivered || currentStopIdx > 0,
                  ),
                  _buildStopMarker(
                    '2',
                    _plannedRoutePoints[1],
                    isCurrent: currentStopIdx == 1,
                    isDelivered: currentStopIdx > 1,
                    isFailed: widget.isFailedStop2,
                  ),
                  _buildStopMarker(
                    '3',
                    _plannedRoutePoints[2],
                    isCurrent: currentStopIdx == 2,
                  ),
                  ],
                  if (widget.showDriverPuck &&
                      (!_hasRealStops || _livePosition != null))
                    Marker(
                      point: LatLng(driverLat, driverLng),
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      child: DriverPuck(heading: widget.drivingState?.heading),
                    ),
                ],
              ),
            ],
          ),

          // ── Top-Right Floating Controls (Non-Driving) ───────────────────
          if (widget.showMapControls && !widget.isDriving)
            Positioned(
              top: 54.h,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandWhite,
                      border: Border.all(
                        color: AppColors.brandMain,
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppAssets.imgAvatarSolidPlaceholder,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          color: AppColors.brandBlack,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _MapActionButton(
                    iconAsset: AppAssets.icCompass,
                    isActive: _isCompassActive,
                    onTap: _toggleCompassHeading,
                  ),
                  SizedBox(height: 12.h),
                  _MapActionButton(
                    iconAsset: AppAssets.icLayers,
                    onTap: () => _openMapLayersSheet(context),
                  ),
                  SizedBox(height: 12.h),
                  _MapActionButton(
                    iconAsset: AppAssets.icCurrentLocation,
                    onTap: _recenterToJeddah,
                  ),
                ],
              ),
            ),

          // ── Map Controls (Driving R10..R34) ─────────────────────────────
          if (widget.isDriving && !widget.isArrivedOrDelivered)
            Positioned(
              top: mapControlsTop,
              right: 16.w,
              child: RouteMapControls(
                onOverviewTapped: () =>
                    context.read<RouteFleetCubit>().openRouteOverview(),
                onStopsTapped: widget.onOpenStopsSheet,
                onHelpTapped: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.help),
              ),
            ),

          // ── Top Banner / Top Sheet Layer ────────────────────────────────
          if (isTopSheetActive)
            Positioned(
              top: 56.h,
              left: 0,
              right: 0,
              child: Center(child: _buildActiveModalSheet()),
            )
          else if (bannerType != StateBannerType.none)
            Positioned(
              top: 56.h,
              left: 0,
              right: 0,
              child: Center(
                child: StateBanner(
                  type: bannerType,
                  customerName: currentStopName,
                ),
              ),
            )
          else if (widget.topBadge != null)
            Positioned(top: 64.h, left: 16.w, child: widget.topBadge!),

          // ── Toast under the banner (R17 "Sent for review", R30 "Stop moved") ──
          if (widget.subBadge != null)
            Positioned(
              top: widget.subBadgeTop ?? 195.h,
              left: 0,
              right: 0,
              child: Center(child: widget.subBadge!),
            ),

          // ── Floating Bottom Sheet Card (DrivingTripSheet / Bottom Card) ──
          if (effectiveBottomCard != null)
            Positioned(
              key: _sheetKey,
              left: 16.w,
              right: 16.w,
              bottom: bottomClearance,
              child: Center(child: effectiveBottomCard),
            )
          else if (effectiveSheet != DrivingModalSheet.routeUpdated)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: bottomClearance,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 360.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr.routeNoFleetConnectionCaps,
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.grey757575,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        context.tr.routeNotConnectedToFleet,
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandBlack,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        context.tr.routeJoinFleetToReceive,
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey666,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Figma "Join your company": joining is by company code,
                      // so the one action here opens the code screen.
                      Center(
                        child: CustomButton(
                          text: context.tr.routeFindAFleet,
                          backgroundColor: AppColors.brandMain,
                          textColor: AppColors.onBrand,
                          iconAsset: AppAssets.icArrowRight,
                          width: 310.w,
                          height: 56.h,
                          borderRadius: 6.r,
                          onPressed: () => _navigateToJoinCompany(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Route Updated Card Overlay (R26) ────────────────────────────
          if (effectiveSheet == DrivingModalSheet.routeUpdated)
            Positioned(
              top: 519.h,
              left: 16.w,
              right: 16.w,
              child: Center(
                child: RouteUpdateCard(
                  companyName: 'Red Sea Express',
                  updateSummaryText:
                      context.tr.routeOneStopAdded,
                  onOkTapped: widget.onCloseModalSheet ?? () {},
                  onViewWhenStoppedTapped: widget.onOpenStopsSheet ?? () {},
                ),
              ),
            ),

          // ── Scrim & Bottom Modal Sheet Overlay (R16, R20, R21, R22, R28) ──
          if (hasBottomModalSheet) ...[
            ScrimWidget(onTap: widget.onCloseModalSheet),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: bottomInset + AppSizes.sheetBottomGap.h,
              child: Center(child: _buildActiveModalSheet()),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.checkStroke
      ..strokeWidth = 2.13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ui.Path path = ui.Path();
    path.moveTo(size.width * 0.2, size.height * 0.55);
    path.lineTo(size.width * 0.45, size.height * 0.75);
    path.lineTo(size.width * 0.8, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.iconAsset,
    required this.onTap,
    this.isActive = false,
  });

  final String iconAsset;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: AppColors.brandBlack,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            iconAsset,
            width: 16.w,
            height: 16.h,
            color: isActive ? AppColors.brandBlack : null,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
