// lib/features/route_fleet/presentation/pages/route_fleet_page.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/help_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/main_layout/presentation/cubit/main_layout_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:routex_mobile/features/route_fleet/presentation/pages/route_page.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/proof_of_delivery.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/active_route_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/arrived_chip.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/arrival_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/approved_status_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/cancel_request_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/cant_sign_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/check_photo_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/declined_status_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/delivered_toast.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/delivery_camera_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/delivery_signature_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/driving_trip_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/find_fleet_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/join_confirm_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/scrim_widget.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/map_header_widget.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/next_stop_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/off_shift_status_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/on_shift_waiting_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/pending_status_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_complete_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_empty_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_error_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_loading_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_location_needed_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_maneuver_banner.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_planning_ready_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_stop_tile.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/stop_moved_toast.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/check_packages_sheet.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

class RouteFleetPage extends StatelessWidget {
  const RouteFleetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteFleetCubit(
        getActiveRouteUseCase: getIt(),
        updateStopStatusUseCase: getIt(),
      ),
      child: const RouteFleetView(),
    );
  }
}

class RouteFleetView extends StatelessWidget {
  const RouteFleetView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RouteFleetCubit, RouteFleetState>(
      listener: (context, state) {
        final isDrivingOrActive =
            state is RouteFleetDriving ||
            state is RouteFleetArrived ||
            state is RouteFleetDelivered ||
            state is RouteFleetProofCamera ||
            state is RouteFleetProofCheckPhoto ||
            state is RouteFleetProofSignature ||
            state is RouteFleetComplete ||
            // Figma R43: the load-check sheet covers the bottom navigation.
            state is RouteFleetCheckPackages;
        context.read<MainLayoutCubit>().setBottomNavVisible(!isDrivingOrActive);
      },
      child: Scaffold(
        backgroundColor: AppColors.brandBackground,
        body: BlocBuilder<RouteFleetCubit, RouteFleetState>(
          builder: (context, state) {
            if (state is RouteFleetLoading || state is RouteFleetInitial) {
              return const RouteLoadingView();
            }

            if (state is RouteFleetError) {
              return RouteErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<RouteFleetCubit>().loadActiveRoute(),
              );
            }

            if (state is RouteFleetLocationNeeded) {
              return RoutePage(
                showMapControls: false,
                showDriverPuck: true,
                showBottomNav: true,
                bottomCard: state.isSheetDismissed
                    ? null
                    : RouteLocationNeededView(
                        onRequestPermission: () {
                          context
                              .read<RouteFleetCubit>()
                              .requestLocationPermission();
                        },
                        onNotNow: () {
                          context
                              .read<RouteFleetCubit>()
                              .dismissLocationSheet();
                        },
                      ),
              );
            }

            if (state is RouteFleetEmpty) {
              return const RoutePage(
                showMapControls: false,
                showPlannedRoute: false,
                showBottomNav: true,
                bottomCard: RouteEmptyView(),
              );
            }

            if (state is RouteFleetCheckPackages) {
              return Stack(
                children: [
                  RoutePage(
                    stops: state.fleetInfo.stops,
                    showMapControls: false,
                    showDriverPuck: true,
                    isDottedRoute: false,
                    showBottomNav: true,
                    topBadge: RouteSummaryChip(
                      isCalculating: false,
                      stopCount: state.fleetInfo.stops.length,
                      summaryText: '${state.fleetInfo.totalDistance} · 32 min',
                    ),
                    drivingState: RouteFleetDriving(
                      fleetInfo: state.fleetInfo,
                      currentStopIndex: 0,
                      maneuverType: ManeuverType.turnLeft,
                      distanceValue: '80',
                      distanceUnit: 'm',
                      instructionText: context.tr.routeCheckPackages,
                      arrivalTime: '10:05',
                      remainingMinutes: 4,
                      remainingKm: 1.1,
                      driverLatLng: LatLng(21.5380, 39.1680),
                      traveledPath: [],
                      upcomingPath: [],
                    ),
                  ),
                  ScrimWidget(blur: true),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: AppSizes.sheetBottomGap.h,
                    child: Center(
                      child: CheckPackagesSheet(
                        fleetInfo: state.fleetInfo,
                        checkedStopIds: state.checkedStopIds,
                        onPackageToggled: (id) => context
                            .read<RouteFleetCubit>()
                            .togglePackageChecked(id),
                        onStartRouteTapped: () =>
                            context.read<RouteFleetCubit>().startRoute(),
                        // R43 "Package missing" -> R31 Help.
                        onPackageMissingTapped: () => showRoutexSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (sheetContext) => HelpSheet(
                            companyName: 'Red Sea Express',
                            onCallDispatchTapped: () {},
                            onMessageDispatchTapped: () {},
                            onTakeABreakTapped: () => Navigator.pop(sheetContext),
                            onVehicleProblemTapped: () {},
                            onUnsafeTapped: () {},
                            onCloseTapped: () => Navigator.pop(sheetContext),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is RouteFleetPlanning) {
              return RoutePage(
                stops: state.fleetInfo.stops,
                showMapControls: false,
                showDriverPuck: true,
                isDottedRoute: true,
                showBottomNav: true,
                topBadge: const RouteSummaryChip(
                  isCalculating: true,
                  stopCount: 3,
                ),
                bottomCard: TripSheet(
                  isReady: false,
                  stops: state.fleetInfo.stops,
                  onStartRoute: () =>
                      context.read<RouteFleetCubit>().openCheckPackagesSheet(),
                ),
              );
            }

            if (state is RouteFleetReady) {
              return RoutePage(
                stops: state.fleetInfo.stops,
                showMapControls: false,
                showDriverPuck: true,
                isDottedRoute: false,
                showBottomNav: true,
                topBadge: RouteSummaryChip(
                  isCalculating: false,
                  stopCount: state.fleetInfo.stops.length,
                  summaryText: state.summaryChipText,
                ),
                bottomCard: TripSheet(
                  isReady: true,
                  stops: state.fleetInfo.stops,
                  distanceMeters: state.distanceMeters,
                  durationMinutes: state.durationMinutes,
                  onStartRoute: () =>
                      context.read<RouteFleetCubit>().openCheckPackagesSheet(),
                ),
              );
            }

            if (state is RouteFleetDriving) {
              // R17 toast comes from the state (a stop was failed), not from the stop index.
              final showSentForReview =
                  state.toastType == DrivingToastType.sentForReview;
              final cubit = context.read<RouteFleetCubit>();

              return RoutePage(
                stops: state.fleetInfo.stops,
                isDriving: true,
                drivingState: state,
                activeSheet: state.activeSheet,
                isFailedStop2: cubit.isStopFailed(1) || showSentForReview,
                showMapControls: false,
                showDriverPuck: true,
                isDottedRoute: false,
                topBadge: RouteManeuverBanner(
                  distanceValue: state.distanceValue,
                  distanceUnit: state.distanceUnit,
                  instructionText: state.instructionText,
                  nextStepText: state.nextStepText,
                  maneuverType: state.maneuverType,
                ),
                subBadgeTop: showSentForReview ? 214.h : null,
                subBadge: showSentForReview
                    ? DeliveredToast(
                        customMessage: context.tr.routeSentToCompanyForReview,
                      )
                    : state.toastType == DrivingToastType.stopMoved
                    ? StopMovedToast(
                        customerName: state.toastMessage != null
                            ? state.toastMessage!.split(' ').first
                            : 'Omar Haddad',
                        onUndoTapped: () =>
                            context.read<RouteFleetCubit>().undoReorderStop(),
                      )
                    : null,
                bottomCard: DrivingTripSheet(
                  currentStop: state.fleetInfo.stops[state.currentStopIndex],
                  stopIndex: state.currentStopIndex + 1,
                  arrivalTime: state.arrivalTime,
                  remainingMinutes: state.remainingMinutes,
                  remainingKm: state.remainingKm,
                  isTappable: state.isTappable,
                  onNavigateTapped: () => context
                      .read<RouteFleetCubit>()
                      .openModalSheet(DrivingModalSheet.navigateWith),
                  onStopDetailsTapped: () => context
                      .read<RouteFleetCubit>()
                      .openModalSheet(DrivingModalSheet.stopDetails),
                ),
                onOpenNavigateWithSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.navigateWith),
                onOpenStopsSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.stops),
                onCloseModalSheet: () =>
                    context.read<RouteFleetCubit>().closeModalSheet(),
                onSelectMapApp: (app) =>
                    context.read<RouteFleetCubit>().selectMapApp(app),
                onStartDirections: () =>
                    context.read<RouteFleetCubit>().startDirections(),
                onAlwaysUseChanged: (val) =>
                    context.read<RouteFleetCubit>().toggleAlwaysUseApp(val),
                onEndRouteEarlyTapped: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.endRoute),
                onKeepDeliveringTapped: () =>
                    context.read<RouteFleetCubit>().closeModalSheet(),
                onEndRouteTapped: () =>
                    context.read<RouteFleetCubit>().endRouteEarly(),
                onOpenReasonSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.reason),
                onOpenContactStepsSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.contactSteps),
                onSendReasonToCompanyTapped: (code, label) => context
                    .read<RouteFleetCubit>()
                    .failCurrentStop(code, label),
                onMarkCouldntDeliverTapped: () =>
                    context.read<RouteFleetCubit>().failCurrentStop(
                      'CUSTOMER_NOT_ANSWERING',
                      'Customer not answering',
                    ),
                onArriveAtDepot: () =>
                    context.read<RouteFleetCubit>().arriveAtDepot(),
                onEndDayAtDepot: () =>
                    context.read<RouteFleetCubit>().endDayAtDepot(),
                onOpenStopFromAutoArrival: () =>
                    context.read<RouteFleetCubit>().openStopFromAutoArrival(),
                onNotHereYetFromAutoArrival: () =>
                    context.read<RouteFleetCubit>().notHereYetFromAutoArrival(),
                onYesDeliveredFromUnmarked: () =>
                    context.read<RouteFleetCubit>().yesDeliveredFromUnmarked(),
                onCouldntDeliverFromUnmarked: () => context
                    .read<RouteFleetCubit>()
                    .couldntDeliverFromUnmarked(),
                onGoBackFromUnmarked: () =>
                    context.read<RouteFleetCubit>().goBackFromUnmarked(),
                onTryAgainLaterTapped: () => context
                    .read<RouteFleetCubit>()
                    .reorderStopToLast(state.currentStopIndex),
                onTakeABreakTapped: () =>
                    context.read<RouteFleetCubit>().takeBreak(),
                onResumeBreakTapped: () =>
                    context.read<RouteFleetCubit>().resumeBreak(),
                onExtendBreakTapped: () =>
                    context.read<RouteFleetCubit>().extendBreak(),
                onReportWrongLocationTapped: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.wrongLocation),
              );
            }

            if (state is RouteFleetArrived) {
              final isLastStop =
                  state.stopIndex == state.fleetInfo.stops.length - 1;

              return RoutePage(
                stops: state.fleetInfo.stops,
                isDriving: false,
                isArrivedOrDelivered: true,
                activeSheet: state.activeSheet,
                isFailedStop2: context.read<RouteFleetCubit>().hasActiveRoute
                    ? context.read<RouteFleetCubit>().isStopFailed(1)
                    : state.stopIndex >= 2, // test modes (no running route)
                driverLatLng: state.driverLatLng,
                traveledPath: state.traveledPath,
                upcomingPath: state.upcomingPath,
                depotLatLng: state.depotLatLng,
                showMapControls: false,
                showDriverPuck: true,
                isDottedRoute: false,
                topBadge: const ArrivedChip(),
                bottomCard: ArrivalSheet(
                  stopIndexText: isLastStop
                      ? context.tr.routeLastStop
                      : context.tr.routeStopNofM('${state.stopIndex + 1}', '${state.fleetInfo.stops.length}'),
                  arrivalTime: state.arrivalTime,
                  customerName: state.fleetInfo.stops[state.stopIndex].title,
                  addressAndOrder:
                      '${state.fleetInfo.stops[state.stopIndex].address}${state.fleetInfo.stops[state.stopIndex].orderId != null ? ' · ${state.fleetInfo.stops[state.stopIndex].orderId}' : ''}',
                  // The note comes from the stop itself when the state does not carry it.
                  companyNote:
                      state.companyNote ??
                      state.fleetInfo.stops[state.stopIndex].companyNote,
                  phone: state.fleetInfo.stops[state.stopIndex].phone,
                  onMapsTapped: () => context
                      .read<RouteFleetCubit>()
                      .openModalSheet(DrivingModalSheet.navigateWith),
                  // Figma prototype: R12 "More" -> R29 (More options), not the stops list.
                  onMoreTapped: () => context
                      .read<RouteFleetCubit>()
                      .openModalSheet(DrivingModalSheet.moreOptions),
                  onCouldntDeliverTapped: () {
                    // Opens R16 Reason sheet
                    context.read<RouteFleetCubit>().openModalSheet(
                      DrivingModalSheet.reason,
                    );
                  },
                  onDeliveredTapped: () {
                    // Real transition: Open P01 Proof Camera for Stop
                    context.read<RouteFleetCubit>().openProofCamera(
                      stopNumber: state.stopIndex + 1,
                      customerName:
                          state.fleetInfo.stops[state.stopIndex].title,
                      requiresSignature: isLastStop,
                    );
                  },
                ),
                onOpenNavigateWithSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.navigateWith),
                onOpenStopsSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.stops),
                onCloseModalSheet: () =>
                    context.read<RouteFleetCubit>().closeModalSheet(),
                onSelectMapApp: (app) =>
                    context.read<RouteFleetCubit>().selectMapApp(app),
                onStartDirections: () =>
                    context.read<RouteFleetCubit>().startDirections(),
                onAlwaysUseChanged: (val) =>
                    context.read<RouteFleetCubit>().toggleAlwaysUseApp(val),
                onEndRouteEarlyTapped: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.endRoute),
                onKeepDeliveringTapped: () =>
                    context.read<RouteFleetCubit>().closeModalSheet(),
                onEndRouteTapped: () =>
                    context.read<RouteFleetCubit>().endRouteEarly(),
                onOpenReasonSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.reason),
                onOpenContactStepsSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.contactSteps),
                onSendReasonToCompanyTapped: (code, label) => context
                    .read<RouteFleetCubit>()
                    .failCurrentStop(code, label),
                onMarkCouldntDeliverTapped: () =>
                    context.read<RouteFleetCubit>().failCurrentStop(
                      'CUSTOMER_NOT_ANSWERING',
                      'Customer not answering',
                    ),
                onArriveAtDepot: () =>
                    context.read<RouteFleetCubit>().arriveAtDepot(),
                onEndDayAtDepot: () =>
                    context.read<RouteFleetCubit>().endDayAtDepot(),
                onOpenStopFromAutoArrival: () =>
                    context.read<RouteFleetCubit>().openStopFromAutoArrival(),
                onNotHereYetFromAutoArrival: () =>
                    context.read<RouteFleetCubit>().notHereYetFromAutoArrival(),
                onYesDeliveredFromUnmarked: () =>
                    context.read<RouteFleetCubit>().yesDeliveredFromUnmarked(),
                onCouldntDeliverFromUnmarked: () => context
                    .read<RouteFleetCubit>()
                    .couldntDeliverFromUnmarked(),
                onGoBackFromUnmarked: () =>
                    context.read<RouteFleetCubit>().goBackFromUnmarked(),
                onTryAgainLaterTapped: () => context
                    .read<RouteFleetCubit>()
                    .reorderStopToLast(state.stopIndex),
              );
            }

            if (state is RouteFleetDelivered) {
              return RoutePage(
                stops: state.fleetInfo.stops,
                isDriving: true,
                isDelivered: true,
                isArrivedOrDelivered: true,
                driverLatLng: state.driverLatLng,
                traveledPath: state.traveledPath,
                upcomingPath: state.upcomingPath,
                depotLatLng: state.depotLatLng,
                showMapControls: false,
                showDriverPuck: true,
                isDottedRoute: false,
                topBadge: DeliveredToast(
                  customerName: state.deliveredCustomerName,
                  onUndoTapped: () =>
                      context.read<RouteFleetCubit>().undoLast(),
                ),
                bottomCard: NextStopSheet(
                  nextStopNumber: state.nextStopIndex + 1,
                  nextStopName: state.nextStopName,
                  nextStopAddressAndMeta: state.nextStopAddressAndMeta,
                  freezeForTesting: false,
                  onGoToNextStopTapped: () =>
                      context.read<RouteFleetCubit>().goToNextStopFromToast(),
                  onCountdownFinished: () =>
                      context.read<RouteFleetCubit>().goToNextStopFromToast(),
                ),
                drivingState: RouteFleetDriving(
                  fleetInfo: state.fleetInfo,
                  currentStopIndex: state.nextStopIndex,
                  maneuverType: ManeuverType.arrive,
                  distanceValue: '0',
                  distanceUnit: 'm',
                  instructionText: '',
                  arrivalTime: '10:24',
                  remainingMinutes: 6,
                  remainingKm: 1.4,
                  driverLatLng: state.driverLatLng,
                  traveledPath: state.traveledPath,
                  upcomingPath: state.upcomingPath,
                  mapControlsTop: 190.0,
                  heading: -90.0,
                ),
                onOpenNavigateWithSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.navigateWith),
                onOpenStopsSheet: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.stops),
                onCloseModalSheet: () =>
                    context.read<RouteFleetCubit>().closeModalSheet(),
                onSelectMapApp: (app) =>
                    context.read<RouteFleetCubit>().selectMapApp(app),
                onStartDirections: () =>
                    context.read<RouteFleetCubit>().startDirections(),
                onAlwaysUseChanged: (val) =>
                    context.read<RouteFleetCubit>().toggleAlwaysUseApp(val),
                onEndRouteEarlyTapped: () => context
                    .read<RouteFleetCubit>()
                    .openModalSheet(DrivingModalSheet.endRoute),
                onKeepDeliveringTapped: () =>
                    context.read<RouteFleetCubit>().closeModalSheet(),
                onEndRouteTapped: () =>
                    context.read<RouteFleetCubit>().endRouteEarly(),
              );
            }

            // ── Proof of Delivery Screens (P01 .. P04) ──────────────────────────

            if (state is RouteFleetProofCamera) {
              final currentStop =
                  (state.fleetInfo != null &&
                      state.stopNumber <= state.fleetInfo!.stops.length)
                  ? state.fleetInfo!.stops[state.stopNumber - 1]
                  : null;
              return DeliveryCameraView(
                stopNumber: state.stopNumber,
                customerName: state.customerName,
                doorNumber: currentStop?.doorNumber,
                requiresSignature: state.requiresSignature,
                onCloseTapped: () =>
                    context.read<RouteFleetCubit>().closeProofCamera(),
                onShutterTapped: (photoPath) {
                  context.read<RouteFleetCubit>().capturePhotoAndCheck(
                    stopNumber: state.stopNumber,
                    customerName: state.customerName,
                    requiresSignature: state.requiresSignature,
                    photoPath: photoPath,
                  );
                },
              );
            }

            if (state is RouteFleetProofCheckPhoto) {
              final currentStop =
                  (state.fleetInfo != null &&
                      state.stopNumber <= state.fleetInfo!.stops.length)
                  ? state.fleetInfo!.stops[state.stopNumber - 1]
                  : null;
              final customerName =
                  state.customerName ?? currentStop?.title ?? 'Omar Haddad';
              return CheckPhotoView(
                photoPath: state.photoPath,
                doorNumber: currentStop?.doorNumber,
                requiresSignature: state.requiresSignature,
                onRetakeTapped: () {
                  context.read<RouteFleetCubit>().openProofCamera(
                    stopNumber: state.stopNumber,
                    customerName: customerName,
                    requiresSignature: state.requiresSignature,
                  );
                },
                onPrimaryActionTapped: () {
                  if (state.requiresSignature) {
                    context.read<RouteFleetCubit>().openProofSignature(
                      customerName: customerName,
                    );
                  } else {
                    context.read<RouteFleetCubit>().completeCurrentDelivery(
                      ProofOfDeliveryData(signerName: customerName),
                    );
                  }
                },
              );
            }

            if (state is RouteFleetProofSignature) {
              return Stack(
                children: [
                  DeliverySignatureView(
                    customerName: state.customerName,
                    initialMode: state.initialMode,
                    onBackToPhotoTapped: () {
                      context.read<RouteFleetCubit>().capturePhotoAndCheck(
                        requiresSignature: true,
                      );
                    },
                    onDoneTapped: () {
                      context.read<RouteFleetCubit>().completeCurrentDelivery(
                        ProofOfDeliveryData(
                          signerName: state.customerName,
                          requiresSignature: true,
                        ),
                      );
                    },
                    onCantSignTapped: () {
                      context.read<RouteFleetCubit>().openCantSignSheet();
                    },
                  ),
                  if (state.showCantSignSheet) ...[
                    ModalBarrier(
                      color: AppColors.scrimDark,
                      dismissible: true,
                      onDismiss: () =>
                          context.read<RouteFleetCubit>().closeCantSignSheet(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CantSignSheet(
                        onMarkDeliveredPhotoOnlyTapped: (reasonCode) {
                          context
                              .read<RouteFleetCubit>()
                              .completeCurrentDelivery(
                                ProofOfDeliveryData(
                                  signerName: state.customerName,
                                  isPhotoOnly: true,
                                ),
                              );
                        },
                        onBackToSignatureTapped: () {
                          context.read<RouteFleetCubit>().closeCantSignSheet();
                        },
                      ),
                    ),
                  ],
                ],
              );
            }

            // ── Route Complete Page (R19) ───────────────────────────────────────

            if (state is RouteFleetComplete) {
              return RouteCompleteView(
                summary: state.summary,
                onDirectionsToDepotTapped: () =>
                    context.read<RouteFleetCubit>().startReturnToDepot(),
                onDoneTapped: () {
                  // Prototype: R19 Done -> Home. The finished route is cleared (R01 next time).
                  context.read<MainLayoutCubit>().changeTab(0);
                  context.read<RouteFleetCubit>().clearCompletedRoute();
                },
                onSeeInHistoryTapped: () {
                  // Not linked in Figma: opens the Orders tab.
                  context.read<MainLayoutCubit>().changeTab(2);
                },
              );
            }

            if (state is RouteFleetNoFleetState) {
              return const RoutePage(
                showMapControls: false,
                showPlannedRoute: false,
                showBottomNav: true,
              ); // No Fleet card over the bare map
            }

            if (state is RouteFleetFindFleetState) {
              return const FindFleetView();
            }

            if (state is RouteFleetJoinConfirmSheetState) {
              return Stack(
                children: [
                  const FindFleetView(),
                  ModalBarrier(
                    color: Colors.black.withValues(alpha: 0.5),
                    dismissible: true,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: JoinConfirmSheet(fleetName: state.fleetName),
                  ),
                ],
              );
            }

            if (state is RouteFleetRequestedState) {
              return const FindFleetView();
            }

            if (state is RouteFleetRequestPendingState) {
              return RoutePage(
                showBottomNav: true,
                bottomCard: PendingStatusCard(
                  fleetName: state.fleetName,
                  onJoinAnotherFleet: () =>
                      context.read<RouteFleetCubit>().goToFindFleet(),
                  onCancelRequest: () =>
                      context.read<RouteFleetCubit>().openCancelRequestSheet(),
                ),
              );
            }

            if (state is RouteFleetCancelRequestSheetState) {
              return Stack(
                children: [
                  RoutePage(
                    showBottomNav: true,
                    bottomCard: PendingStatusCard(
                      fleetName: state.fleetName,
                      onJoinAnotherFleet: () =>
                          context.read<RouteFleetCubit>().goToFindFleet(),
                      onCancelRequest: () => context
                          .read<RouteFleetCubit>()
                          .openCancelRequestSheet(),
                    ),
                  ),
                  ModalBarrier(
                    color: Colors.black.withValues(alpha: 0.5),
                    dismissible: true,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CancelRequestSheet(fleetName: state.fleetName),
                  ),
                ],
              );
            }

            if (state is RouteFleetApprovedState) {
              return RoutePage(
                showBottomNav: true,
                bottomCard: ApprovedStatusCard(
                  fleetName: state.fleetName,
                  onStartShift: () =>
                      context.read<RouteFleetCubit>().goToOnShiftWaiting(),
                  onNotNow: () =>
                      context.read<RouteFleetCubit>().goToOffShift(),
                ),
              );
            }

            if (state is RouteFleetDeclinedState) {
              return RoutePage(
                showBottomNav: true,
                bottomCard: DeclinedStatusCard(
                  fleetName: state.fleetName,
                  reason: state.reason,
                  onChooseAnotherFleet: () =>
                      context.read<RouteFleetCubit>().goToFindFleet(),
                  onUpdateVehicle: () =>
                      context.read<RouteFleetCubit>().goToFindFleet(),
                ),
              );
            }

            if (state is RouteFleetOffShiftState) {
              return RoutePage(
                showBottomNav: true,
                bottomCard: OffShiftStatusCard(
                  fleetName: state.fleetName,
                  onStartShift: () =>
                      context.read<RouteFleetCubit>().goToOnShiftWaiting(),
                ),
              );
            }

            if (state is RouteFleetOnShiftWaitingState) {
              return RoutePage(
                showBottomNav: true,
                bottomCard: OnShiftWaitingCard(
                  onEndShift: () =>
                      context.read<RouteFleetCubit>().goToOffShift(),
                ),
              );
            }

            if (state is RouteFleetLoaded) {
              final fleet = state.fleetInfo;
              return Stack(
                children: [
                  Column(
                    children: [
                      MapHeaderWidget(
                        progressPercentage: fleet.progressPercentage,
                        totalDistance: fleet.totalDistance,
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          itemCount: fleet.stops.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final stop = fleet.stops[index];
                            return RouteStopTile(
                              stop: stop,
                              index: index,
                              onToggle: (stopId) {
                                context.read<RouteFleetCubit>().updateStop(
                                  stopId,
                                  !stop.isCompleted,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ActiveRouteSheet(
                      vehicleNumber: fleet.activeVehicleNumber,
                      routeName: fleet.routeName,
                      isExpanded: state.isSheetExpanded,
                      onToggle: () {
                        context.read<RouteFleetCubit>().toggleSheetExpansion();
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
