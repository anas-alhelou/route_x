// lib/features/orders/presentation/pages/history_waiting_to_sync_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/entities/pending_sync_update_entity.dart';
import '../controllers/waiting_to_sync_cubit.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/history/history_primary_button.dart';
import '../widgets/history/history_rows.dart';
import '../widgets/history/sync_widgets.dart';
import '../widgets/order_detail/order_detail_header.dart';
import '../widgets/orders_today/orders_card.dart';
import '../widgets/orders_today/orders_row_tile.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import 'package:routex_mobile/features/main_layout/presentation/widgets/shell_nav_bar.dart';

/// The stops this phone has not uploaded yet, opened from History's
/// "waiting to sync" card.
///
/// Mostly reassurance: each update is listed with what it carries, so a
/// driver can see the photo is safe; the one way to lose them is said
/// once; "Sync now" is there for when they would rather not wait.
///
/// Pops with `true` once the queue is empty, so History can refresh.
class HistoryWaitingToSyncPage extends StatelessWidget {
  const HistoryWaitingToSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WaitingToSyncCubit(
        getPendingSyncUpdatesUseCase: getIt(),
        syncPendingUpdatesUseCase: getIt(),
      )..load(),
      child: const HistoryWaitingToSyncView(),
    );
  }
}

class HistoryWaitingToSyncView extends StatelessWidget {
  const HistoryWaitingToSyncView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final gutter = EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w);

    return BlocConsumer<WaitingToSyncCubit, WaitingToSyncState>(
      // Done after a sync: back to History, which reloads.
      listenWhen: (previous, current) =>
          previous.syncing && !current.syncing && current.isEmpty,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: const ShellNavBar(),
          backgroundColor: AppColors.brandBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OrderDetailBackButton(
                  label: l10n.ordersSegmentHistory,
                  onPressed: () =>
                      Navigator.of(context).maybePop(state.isEmpty),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: 6.h,
                      bottom: HistoryMetrics.bottomPadding.h +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: gutter,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.syncTitle,
                                style: AppTextStyles.s28Bold.scaled.copyWith(
                                  height: 1.15,
                                  letterSpacing: -0.28.sp,
                                  color: AppColors.brandBlack,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                l10n.syncSubtitle,
                                style: AppTextStyles.s14Regular.scaled.copyWith(
                                  height: 1.4,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Padding(padding: gutter, child: _body(l10n, state)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(AppLocalizations l10n, WaitingToSyncState state) {
    switch (state.status) {
      case WaitingToSyncStatus.loading:
        return const SizedBox.shrink();
      case WaitingToSyncStatus.failed:
        return _Note(l10n.ordersLoadFailedMessage);
      case WaitingToSyncStatus.loaded when state.updates.isEmpty:
        return _Note(l10n.syncAllUploaded);
      case WaitingToSyncStatus.loaded:
        return Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrdersCard(
                children: [
                  for (final update in state.updates)
                    OrdersRowTile(
                      leading: update.outcome == HistoryStopOutcome.delivered
                          ? const HistoryDeliveredBadge()
                          : const HistoryFailureBadge(),
                      title: update.addressLine,
                      subtitle: _subtitle(l10n, update),
                      trailing: SyncWaitingPill(label: l10n.syncWaiting),
                    ),
                ],
              ),
              SizedBox(height: 24.h),
              SyncKeepAppWarning(message: l10n.syncKeepAppWarning),
              SizedBox(height: 32.h),
              HistoryPrimaryButton(
                label: l10n.syncNow,
                busy: state.syncing,
                onPressed: context.read<WaitingToSyncCubit>().syncNow,
              ),
              if (state.syncFailed) ...[
                SizedBox(height: 12.h),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.syncNoSignal,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.s14Regular.scaled
                        .copyWith(color: AppColors.textWarning),
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.s16Regular.scaled.copyWith(color: AppColors.textMuted),
    );
  }
}

/// `#RX-1039 · Delivered 10:05 · photo and status`.
String _subtitle(AppLocalizations l10n, PendingSyncUpdateEntity update) {
  final outcome = update.outcome == HistoryStopOutcome.delivered
      ? l10n.syncDeliveredAt(update.time)
      : l10n.syncFailedAt(update.time);
  return ['#${update.orderCode}', outcome, _parts(l10n, update.parts)]
      .join(' · ');
}

/// `status`, `photo and status`, `photo, signature and status`.
String _parts(AppLocalizations l10n, List<PendingSyncPart> parts) {
  final names = [
    for (final part in parts)
      switch (part) {
        PendingSyncPart.photo => l10n.syncPartPhoto,
        PendingSyncPart.signature => l10n.syncPartSignature,
        PendingSyncPart.status => l10n.syncPartStatus,
      },
  ];
  if (names.length < 2) return names.join();
  return l10n.syncPartsJoin(
    names.sublist(0, names.length - 1).join(', '),
    names.last,
  );
}
