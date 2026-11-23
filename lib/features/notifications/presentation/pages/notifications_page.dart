// lib/features/notifications/presentation/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_top_bar.dart';
import 'package:routex_mobile/core/widgets/routex_skeleton.dart';
import 'package:routex_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:routex_mobile/features/notifications/presentation/widgets/notifications_empty_state.dart';
import 'package:routex_mobile/features/notifications/presentation/widgets/populated_notifications_list.dart';

export 'package:routex_mobile/features/notifications/presentation/widgets/notification_card.dart';
export 'package:routex_mobile/features/notifications/presentation/widgets/notifications_empty_state.dart';
export 'package:routex_mobile/features/notifications/presentation/widgets/populated_notifications_list.dart';

/// Notifications inbox screen matching Figma N01 (Populated) and N02 (Empty).
///
/// Base frame: 412 x 917, content width: 360, horizontal padding: 26.
/// Header: 40 x 40 back button, "Notifications" title (28h), and "Mark all read" right.
/// N01: Section "New" + cards, Section "Earlier" + cards (Width 360, icon container 40x40, unread dot 8x8).
/// N02: Centered empty state (170 x 156 3D bell illustration, 28 space, title, 10 space, 2-line desc).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    this.bloc,
    this.startEmpty = false,
    super.key,
  });

  final NotificationsBloc? bloc;
  final bool startEmpty;

  @override
  Widget build(BuildContext context) {
    final effectiveBloc = bloc ?? getIt<NotificationsBloc>();
    return BlocProvider<NotificationsBloc>.value(
      value: effectiveBloc,
      child: _NotificationsView(startEmpty: startEmpty),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView({this.startEmpty = false});

  final bool startEmpty;

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<NotificationsBloc>();
    if (bloc.state.status == NotificationsStatus.initial) {
      bloc.add(const NotificationsStarted());
      if (widget.startEmpty) {
        bloc.add(const NotificationsToggleEmpty());
      }
    } else if (widget.startEmpty && bloc.state.notifications.isNotEmpty) {
      bloc.add(const NotificationsToggleEmpty());
    } else if (!widget.startEmpty && bloc.state.notifications.isEmpty) {
      bloc.add(const NotificationsToggleEmpty());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final bool hasItems = state.notifications.isNotEmpty;
            final bool hasUnread = state.hasUnread;

            return Column(
              children: [
                // ── Header (40x40 back, title 28h, "Mark all read" right) ────
                RouteXTopBar(
                  title: context.tr.notificationsTitle,
                  onBack: () => context.pop(),
                  trailing: hasItems
                      ? GestureDetector(
                          onTap: hasUnread
                              ? () {
                                  context
                                      .read<NotificationsBloc>()
                                      .add(const NotificationsMarkAllRead());
                                }
                              : null,
                          child: Center(
                            child: Text(
                              context.tr.notificationsMarkAllRead,
                              style: TextStyle(
                                fontFamily: AppFonts.fontFamilySatoshi,
                                fontFamilyFallback: AppFonts.fontFamilyFallback,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: hasUnread
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(height: AppSpacing.s12.h),

                // ── Body (N01 Populated or N02 Empty) ────────────────────────
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state) {
    if (state.status == NotificationsStatus.loading && !state.isRefreshing) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            RouteXSkeleton.block(width: double.infinity, height: 80.h, radius: 16.r),
            SizedBox(height: 16.h),
            RouteXSkeleton.block(width: double.infinity, height: 80.h, radius: 16.r),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return const NotificationsEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.brandMain,
      onRefresh: () async {
        context.read<NotificationsBloc>().add(const NotificationsRefreshed());
      },
      child: PopulatedNotificationsList(
        notifications: state.notifications,
      ),
    );
  }
}
