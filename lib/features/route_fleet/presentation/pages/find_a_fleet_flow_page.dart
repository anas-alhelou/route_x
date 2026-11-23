// lib/features/route_fleet/presentation/pages/find_a_fleet_flow_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/cancel_request_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/find_fleet_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/join_confirm_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/request_approved_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/request_declined_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/request_pending_view.dart';

/// Standalone full-screen page for the "Find a Fleet" flow pushed on the Root Navigator.
/// This guarantees the Bottom Navigation Bar is completely hidden.
class FindAFleetFlowPage extends StatelessWidget {
  const FindAFleetFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteFleetCubit(
        getActiveRouteUseCase: getIt(),
        updateStopStatusUseCase: getIt(),
      )..goToFindFleet(),
      child: const FindAFleetFlowView(),
    );
  }
}

class FindAFleetFlowView extends StatelessWidget {
  const FindAFleetFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: BlocConsumer<RouteFleetCubit, RouteFleetState>(
        listener: (context, state) {
          // If user requests to go back to No Fleet from inside the flow, pop the route
          if (state is RouteFleetNoFleetState) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is RouteFleetFindFleetState || state is RouteFleetRequestedState) {
            return const FindFleetView();
          }

          if (state is RouteFleetJoinConfirmSheetState) {
            return Stack(
              children: [
                const FindFleetView(),
                ModalBarrier(
                  color: Colors.black.withValues(alpha: 0.5),
                  dismissible: true,
                  onDismiss: () => context.read<RouteFleetCubit>().closeJoinConfirmSheet(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: JoinConfirmSheet(fleetName: state.fleetName),
                ),
              ],
            );
          }

          if (state is RouteFleetRequestPendingState) {
            return RequestPendingView(fleetName: state.fleetName);
          }

          if (state is RouteFleetCancelRequestSheetState) {
            return Stack(
              children: [
                RequestPendingView(fleetName: state.fleetName),
                ModalBarrier(
                  color: Colors.black.withValues(alpha: 0.5),
                  dismissible: true,
                  onDismiss: () => context.read<RouteFleetCubit>().closeCancelRequestSheet(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CancelRequestSheet(fleetName: state.fleetName),
                ),
              ],
            );
          }

          if (state is RouteFleetApprovedState) {
            return RequestApprovedView(fleetName: state.fleetName);
          }

          if (state is RouteFleetDeclinedState) {
            return RequestDeclinedView(fleetName: state.fleetName, reason: state.reason);
          }

          return const FindFleetView();
        },
      ),
    );
  }
}
