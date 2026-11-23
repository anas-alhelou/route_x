// lib/features/orders/presentation/pages/history_stop_record_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/entities/history_stop_record_entity.dart';
import '../../domain/entities/order_history_entity.dart';
import '../controllers/history_stop_record_cubit.dart';
import '../controllers/history_stop_record_state.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/history/history_rows.dart';
import '../widgets/history/proof_of_delivery_card.dart';
import '../widgets/history/report_stop_issue_sheet.dart';
import '../widgets/history/stop_record_widgets.dart';
import '../widgets/history/sync_widgets.dart';
import '../widgets/order_detail/order_detail_header.dart';
import '../widgets/orders_today/orders_arrival_toast.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import 'history_issue_sent_page.dart';
import 'package:routex_mobile/features/main_layout/presentation/widgets/shell_nav_bar.dart';

/// The record of one closed stop: how it ended, and what the app logged on
/// the way there, so the driver can answer for it later.
///
/// Everything above the timeline comes with [stop] from the day's list and
/// paints at once; only the log is fetched.
class HistoryStopRecordPage extends StatelessWidget {
  const HistoryStopRecordPage({
    super.key,
    required this.stop,
    required this.dayLabel,
    required this.totalStops,
  });

  final HistoryStopEntity stop;

  /// The day it belongs to, for the back button: `Sat 10 Oct`.
  final String dayLabel;

  /// Stops on that day, for "Stop 4 of 8".
  final int totalStops;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryStopRecordCubit(
        getHistoryStopRecordUseCase: getIt(),
        stop: stop,
      )..load(),
      child: HistoryStopRecordView(
        stop: stop,
        dayLabel: dayLabel,
        totalStops: totalStops,
      ),
    );
  }
}

class HistoryStopRecordView extends StatelessWidget {
  const HistoryStopRecordView({
    super.key,
    required this.stop,
    required this.dayLabel,
    required this.totalStops,
    this.issueSent = false,
  });

  final HistoryStopEntity stop;
  final String dayLabel;
  final int totalStops;

  /// The driver has just reported this stop: the outcome is flagged, the
  /// report button gives way to a note on where the answer will come, and a
  /// toast confirms the send.
  final bool issueSent;

  /// Swaps this record for its issue-sent state rather than pushing on top,
  /// so Back goes to the day, not to a record that still offers to report.
  void _showIssueSent(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HistoryIssueSentPage(
          stop: stop,
          dayLabel: dayLabel,
          totalStops: totalStops,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final gutter = EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w);
    final delivered = stop.outcome == HistoryStopOutcome.delivered;

    return Scaffold(
      bottomNavigationBar: const ShellNavBar(),
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: _content(context, l10n, gutter, delivered)),
            if (issueSent)
              Positioned(
                left: HistoryMetrics.gutter.w,
                right: HistoryMetrics.gutter.w,
                bottom:
                    OrdersTodayMetrics.arrivalToastBottom.h +
                    MediaQuery.paddingOf(context).bottom,
                child: Center(
                  child: OrdersArrivalToast(
                    arrivalId: 1,
                    label: l10n.historyIssueSentToast,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    EdgeInsets gutter,
    bool delivered,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderDetailBackButton(
          label: dayLabel,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 10.h,
              bottom:
                  HistoryMetrics.bottomPadding.h +
                  MediaQuery.paddingOf(context).bottom,
            ),
            child: Padding(
              padding: gutter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _StatusPill(stop: stop),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          '#${stop.orderCode} · '
                          '${l10n.historyStopOfTotal(stop.sequence, totalStops)}',
                          style: AppTextStyles.s12Medium.scaled.copyWith(
                            height: 1.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    stop.addressLine,
                    style: AppTextStyles.s28Bold.scaled.copyWith(
                      height: 1.15,
                      letterSpacing: -0.28.sp,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  StopOutcomeCard(
                    badge: delivered
                        ? const HistoryDeliveredBadge()
                        : const HistoryFailureBadge(),
                    title: delivered
                        ? l10n.historyStatDelivered
                        : l10n.historyCouldNotDeliverTitle,
                    message: _outcomeMessage(l10n),
                    // Green for a delivery, whether or not it is later
                    // disputed; red only for a failure being disputed.
                    tone: delivered
                        ? StopOutcomeTone.positive
                        : issueSent
                            ? StopOutcomeTone.flagged
                            : StopOutcomeTone.plain,
                  ),
                  SizedBox(height: 12.h),
                  BlocBuilder<HistoryStopRecordCubit, HistoryStopRecordState>(
                    builder: (context, state) {
                      if (state.status == HistoryStopRecordStatus.failed) {
                        return _LoadFailed(
                          onRetry: context.read<HistoryStopRecordCubit>().load,
                        );
                      }
                      final record = state.record;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (record != null && record.hasProof) ...[
                            ProofOfDeliveryCard(
                              label: l10n.historyProofTitle,
                              photo: record.photo == null
                                  ? null
                                  : ProofItem(
                                      caption: _photoCaption(
                                        l10n,
                                        record.photo!,
                                      ),
                                      imageUrl: record.photo!.imageUrl,
                                    ),
                              signature: record.signature == null
                                  ? null
                                  : ProofItem(
                                      caption: [
                                        l10n.historyProofSignature,
                                        record.signature!.time,
                                      ].join(' · '),
                                      imageUrl: record.signature!.imageUrl,
                                    ),
                            ),
                            // Figma H12: 29 between the proof card and the timeline.
                            SizedBox(height: 29.h),
                          ],
                          StopTimelineCard(
                            label: l10n.historyWhatHappened,
                            entries: record == null
                                ? null
                                : [
                                    for (final event in record.events)
                                      _entry(l10n, event),
                                  ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          (HistoryMetrics.labelGutter - HistoryMetrics.gutter)
                              .w,
                    ),
                    child: Text(
                      l10n.historyClosedPrivacy,
                      style: AppTextStyles.s12Regular.scaled.copyWith(
                        height: 1.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (issueSent)
                    IssueSentCard(
                      title: l10n.historyIssueSentTitle,
                      message: l10n.historyIssueSentBody,
                    )
                  else
                    _ReportIssueButton(
                      label: l10n.historyReportIssue,
                      orderCode: stop.orderCode,
                      onSent: () => _showIssueSent(context),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _outcomeMessage(AppLocalizations l10n) {
    if (stop.outcome == HistoryStopOutcome.delivered) {
      return switch (stop.handover) {
        HandoverKind.customerAtDoor => l10n.historyHandoverCustomer,
        HandoverKind.reception => l10n.historyHandoverReception,
        HandoverKind.guard => l10n.historyHandoverGuard,
        null => l10n.historyDeliveredAt(stop.time),
      };
    }
    final reason = stop.failureReason;
    final said = reason == null ? '' : _sentenceCase(_reason(l10n, reason));
    return stop.inReview
        ? l10n.historyFailedInReview(said)
        : l10n.historyFailedClosed(said);
  }
}

StopTimelineEntry _entry(AppLocalizations l10n, StopEventEntity event) {
  String? callDetail() {
    final answered = event.answered;
    final waited = event.waitedMinutes;
    return [
      if (answered != null)
        answered ? l10n.historyEventAnswered : l10n.historyEventNoAnswer,
      if (waited != null) l10n.historyEventWaited(waited),
    ].join(' · ');
  }

  return switch (event.kind) {
    StopEventKind.arrived => StopTimelineEntry(
      title: l10n.historyEventArrived,
      time: event.time,
      tone: StopEventTone.good,
      detail: event.distanceMeters == null
          ? null
          : l10n.historyEventArrivedDetail(event.distanceMeters!),
    ),
    StopEventKind.called => StopTimelineEntry(
      title: l10n.historyEventCalled,
      time: event.time,
      tone: StopEventTone.neutral,
      detail: callDetail(),
    ),
    StopEventKind.calledAgain => StopTimelineEntry(
      title: l10n.historyEventCalledAgain,
      time: event.time,
      tone: StopEventTone.neutral,
      detail: callDetail(),
    ),
    StopEventKind.markedFailed => StopTimelineEntry(
      title: l10n.historyEventMarkedFailed,
      time: event.time,
      tone: StopEventTone.bad,
      detail: event.reason == null
          ? null
          : l10n.historyEventReason(_reason(l10n, event.reason!)),
    ),
    StopEventKind.photoTaken => StopTimelineEntry(
      title: l10n.historyEventPhoto,
      time: event.time,
      tone: StopEventTone.neutral,
      detail: event.note,
    ),
    StopEventKind.signed => StopTimelineEntry(
      title: l10n.historyEventSigned,
      time: event.time,
      tone: StopEventTone.neutral,
    ),
    StopEventKind.delivered => StopTimelineEntry(
      title: l10n.historyEventDelivered,
      time: event.time,
      tone: StopEventTone.good,
    ),
    StopEventKind.returnedToDepot => StopTimelineEntry(
      title: l10n.historyEventReturned,
      time: event.time,
      tone: StopEventTone.neutral,
    ),
  };
}

/// "Photo · 08:31 · 14 m away".
String _photoCaption(AppLocalizations l10n, DeliveryPhotoEntity photo) => [
      l10n.historyProofPhoto,
      photo.time,
      if (photo.distanceMeters != null)
        l10n.historyProofDistance(photo.distanceMeters!),
    ].join(' · ');

String _reason(AppLocalizations l10n, DeliveryFailureReason reason) =>
    switch (reason) {
      DeliveryFailureReason.customerNotAnswering => l10n.historyReasonNoAnswer,
      DeliveryFailureReason.addressNotFound => l10n.historyReasonAddress,
      DeliveryFailureReason.refused => l10n.historyReasonRefused,
    };

/// Reasons are stored mid-sentence; opening a sentence they need a capital.
/// Arabic has no case, so this leaves it untouched.
String _sentenceCase(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// In review (grey, hourglass), Delivered (green) or Not delivered (grey).
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.stop});

  final HistoryStopEntity stop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    if (stop.inReview) return InReviewPill(label: l10n.historyStopInReview);
    if (stop.outcome == HistoryStopOutcome.delivered) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.statusSuccessSurface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: AppColors.brandMain, width: 1.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.svg.delivered16.svg(width: 16.w, height: 16.w),
            SizedBox(width: 4.w),
            Text(
              l10n.historyStatDelivered,
              style: AppTextStyles.s10Bold.scaled
                  .copyWith(height: 1.4, color: AppColors.brandMain),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceBadge,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        l10n.historyStopNotDelivered,
        style: AppTextStyles.s10Bold.scaled.copyWith(
          height: 1.4,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _ReportIssueButton extends StatelessWidget {
  const _ReportIssueButton({
    required this.label,
    required this.orderCode,
    required this.onSent,
  });

  final String label;
  final String orderCode;

  /// Called once the sheet reports a successful send.
  final VoidCallback onSent;

  Future<void> _report(BuildContext context) async {
    final sent = await ReportStopIssueSheet.show(context, orderCode: orderCode);
    if (sent != true || !context.mounted) return;
    onSent();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _report(context),
        child: SizedBox(
          height: 56.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.svg.review24.svg(width: 24.w, height: 24.w),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.s16Bold.scaled.copyWith(
                      height: 1.4,
                      color: AppColors.brandBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(HistoryMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ordersLoadFailedTitle,
            style: AppTextStyles.s16Bold.scaled.copyWith(
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.ordersLoadFailedMessage,
            style: AppTextStyles.s14Regular.scaled.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.brandMain,
              foregroundColor: AppColors.onBrand,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: Text(
              l10n.ordersTryAgain,
              style: AppTextStyles.s16SemiBold.scaled,
            ),
          ),
        ],
      ),
    );
  }
}
