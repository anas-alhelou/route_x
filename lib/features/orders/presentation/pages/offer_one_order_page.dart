// lib/features/orders/presentation/pages/offer_one_order_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/notifications/app_notification_service.dart';
import 'package:routex_mobile/core/notifications/app_shell_bus.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/order_offer_entity.dart';
import '../controllers/order_offer_cubit.dart';
import '../widgets/history/history_primary_button.dart';
import '../widgets/offers/offer_decline_sheet.dart';
import '../widgets/offers/order_offer_widgets.dart';
import '../widgets/order_detail/order_detail_header.dart';
import '../widgets/orders_today/orders_card.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import 'order_offer_accepted_page.dart';

/// How an offer screen ended, for whoever opened it.
enum OrderOfferOutcome { accepted, declined }

/// What the driver already chose before the offer opened: a button on the
/// notification (NF1) answers the offer as soon as the screen is up.
enum OrderOfferIntent {
  /// Just show the offer (OF1 / OF2).
  none,

  /// "Accept" on the notification -> OF5.
  accept,

  /// "Decline" on the notification -> the reason sheet, OF4.
  decline,
}

/// Opens an offer on [navigator] from anywhere — Home, a system notification —
/// and lets every screen that lists offers know once it has been answered.
Future<OrderOfferOutcome?> pushOrderOffer(
  NavigatorState navigator,
  OrderOfferEntity offer, {
  OrderOfferIntent intent = OrderOfferIntent.none,
}) async {
  final outcome = await navigator.push<OrderOfferOutcome>(
    MaterialPageRoute(
      builder: (_) => OrderOfferPage(offer: offer, intent: intent),
    ),
  );
  AppShellBus.instance.offersChanged();
  AppNotificationService.instance.cancelOffer(offer.id);
  return outcome;
}

/// An offer to answer before its timer runs out: one order, or a group the
/// driver can trim. Pops with [OrderOfferOutcome.declined]; on accept it is
/// replaced by "Added to your route" and completes with
/// [OrderOfferOutcome.accepted]. Pops with null when the driver backs out or
/// the offer is gone.
class OrderOfferPage extends StatelessWidget {
  const OrderOfferPage({
    super.key,
    required this.offer,
    this.intent = OrderOfferIntent.none,
  });

  final OrderOfferEntity offer;
  final OrderOfferIntent intent;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderOfferCubit(
        offer: offer,
        acceptOfferUseCase: getIt(),
        declineOfferUseCase: getIt(),
      ),
      child: _OfferIntentRunner(
        intent: intent,
        child: const OrderOfferView(),
      ),
    );
  }
}

/// Carries out [OrderOfferIntent] once, right after the offer screen opens.
class _OfferIntentRunner extends StatefulWidget {
  const _OfferIntentRunner({required this.intent, required this.child});

  final OrderOfferIntent intent;
  final Widget child;

  @override
  State<_OfferIntentRunner> createState() => _OfferIntentRunnerState();
}

class _OfferIntentRunnerState extends State<_OfferIntentRunner> {
  @override
  void initState() {
    super.initState();
    if (widget.intent == OrderOfferIntent.none) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (!mounted) return;
    final cubit = context.read<OrderOfferCubit>();
    if (widget.intent == OrderOfferIntent.accept) {
      await cubit.accept();
      return;
    }
    final reason = await OfferDeclineSheet.show(
      context,
      fleetName: cubit.state.offer.fleetName,
    );
    if (reason != null) await cubit.decline(reason);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Kept for the screens that open one order of an offer; the whole offer is
/// shown, so a group still reads as a group.
class OfferOneOrderPage extends StatelessWidget {
  const OfferOneOrderPage({
    required this.offer,
    required this.order,
    super.key,
  });

  final OrderOfferEntity offer;
  final OfferOrderEntity order;

  @override
  Widget build(BuildContext context) => OrderOfferPage(offer: offer);
}

class OrderOfferView extends StatelessWidget {
  const OrderOfferView({super.key});

  void _onState(BuildContext context, OrderOfferState state) {
    final navigator = Navigator.of(context);
    switch (state.status) {
      case OrderOfferStatus.accepted:
        navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (routeContext) => OrderOfferAcceptedPage(
              result: state.result!,
              // OF5 "See tomorrow's route" -> R03: the Route tab.
              onSeeRoute: () {
                Navigator.of(routeContext).popUntil((r) => r.isFirst);
                AppShellBus.instance.openTab(1);
              },
            ),
          ),
          result: OrderOfferOutcome.accepted,
        );
      case OrderOfferStatus.declined:
        navigator.pop(OrderOfferOutcome.declined);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final gutter = OrdersTodayMetrics.gutter.w;

    return BlocConsumer<OrderOfferCubit, OrderOfferState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onState,
      builder: (context, state) {
        final offer = state.offer;

        return Scaffold(
          backgroundColor: AppColors.brandBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The pill floats over the back row rather than sharing its
                // width: "No longer available" would otherwise squeeze Back.
                Stack(
                  children: [
                    OrderDetailBackButton(
                      label: l10n.offerOneOrderTitle,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    PositionedDirectional(
                      // Figma OF1: the timer pill sits 20 from the edge, not 26.
                      end: 20.w,
                      top: 0,
                      bottom: 0,
                      child: Center(child: _TimerPill(state: state)),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(gutter, 10.h, gutter, 24.h),
                    // Faded once it cannot be taken, or while an answer
                    // failed: the reason sits in the panel below.
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _faded(state) ? 0.5 : 1,
                      child: offer.isGroup
                          ? _GroupBody(state: state)
                          : _SingleBody(offer: offer, faded: _faded(state)),
                    ),
                  ),
                ),
                _BottomPanel(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.state});

  final OrderOfferState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    return switch (state.status) {
      OrderOfferStatus.expired =>
        OfferPill(label: l10n.offerTimesUp, tone: OfferPillTone.ended),
      OrderOfferStatus.takenBack => OfferPill(
          label: l10n.offerNoLongerAvailable,
          tone: OfferPillTone.ended,
        ),
      _ => OfferPill(
          label: l10n.offerOneOrderCountdown(offerClock(state.remaining)),
          tone: OfferPillTone.live,
        ),
    };
  }
}

/// Fleet tag, the big title and the line under it.
class _Heading extends StatelessWidget {
  const _Heading({
    required this.tag,
    required this.title,
    required this.subtitle,
  });

  final String tag;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OfferPill(label: tag),
        SizedBox(height: 6.h),
        Text(
          title,
          style: AppTextStyles.s28Bold.scaled.copyWith(
            height: 1.35,
            letterSpacing: -0.56.sp,
            color: AppColors.brandBlack,
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.s14Regular.scaled.copyWith(
            height: 1.35,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _SingleBody extends StatelessWidget {
  const _SingleBody({required this.offer, this.faded = false});

  final OrderOfferEntity offer;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final order = offer.orders.first;
    final afterStop = order.routePosition ?? 3;
    final note = offer.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(
          tag: l10n.offerOneOrderNewFromFleet(offer.fleetName),
          title: order.customerName,
          subtitle: [
            '#${order.orderCode}',
            order.deliveryDateLabel ?? l10n.offerOneOrderTomorrow,
          ].join(' · '),
        ),
        SizedBox(height: 17.h),
        OfferMapPreview(afterStop: afterStop, faded: faded),
        SizedBox(height: 10.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OfferPill(
            label: l10n.offerOneOrderRouteDistance(
              order.distanceKm,
              order.addedMinutes ?? 0,
            ),
            tone: OfferPillTone.info,
            dot: false,
          ),
        ),
        SizedBox(height: 10.h),
        OfferDetailsCard(
          items: [
            OfferDetailItem(
              icon: OfferIcons.pin(),
              title: order.addressLine ?? order.area,
              subtitle: order.addressDetails ?? l10n.offerOneOrderAddress,
            ),
            OfferDetailItem(
              icon: OfferIcons.timer(),
              title: l10n.offerOneOrderDelivery(order.timeWindow),
              subtitle: l10n.offerOneOrderFitsAfterStop(afterStop),
            ),
            OfferDetailItem(
              icon: OfferIcons.package(),
              title: l10n.offerOneOrderPackages(order.packagesCount),
              subtitle:
                  order.instructions ?? l10n.offerOneOrderSignatureNeeded,
            ),
          ],
        ),
        if (note != null) ...[
          SizedBox(height: 12.h),
          OfferNoteCard(label: l10n.offerOneOrderCompanyNote, note: note),
        ],
      ],
    );
  }
}

class _GroupBody extends StatelessWidget {
  const _GroupBody({required this.state});

  final OrderOfferState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final offer = state.offer;
    final picked = state.acceptedOrders;
    final km = picked.fold<double>(0, (sum, o) => sum + o.addedKm);
    final minutes = picked.fold<int>(0, (sum, o) => sum + (o.addedMinutes ?? 0));
    final day = offer.orders.first.deliveryDateLabel ??
        l10n.offerOneOrderTomorrow;
    final cubit = context.read<OrderOfferCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(
          tag: offer.fleetName,
          title: l10n.offerGroupTitle(offer.orders.length),
          subtitle: l10n.offerGroupSubtitle(_inSentence(day)),
        ),
        SizedBox(height: 32.h),
        OfferGroupSummary(
          stats: [
            ('${picked.length}', l10n.offerStopsAdded(picked.length)),
            (l10n.offerKmDelta(km.toStringAsFixed(1)), l10n.offerToYourRoute),
            (l10n.offerMinutesDelta(minutes), l10n.offerDriving),
          ],
        ),
        SizedBox(height: 17.h),
        OrdersCard(
          dividerInset: 17,
          children: [
            for (final order in offer.orders)
              OfferOrderRow(
                title: l10n.offerRowTitle(order.customerName, order.orderCode),
                subtitle: l10n.offerRowSubtitle(order.area, order.timeWindow),
                distance: order.distanceKm,
                packages: l10n.offerOneOrderPackages(order.packagesCount),
                skipped: state.skipped.contains(order.id),
                skippingLabel: l10n.offerSkipping,
                onTap: state.status == OrderOfferStatus.open
                    ? () => cubit.toggleSkip(order.id)
                    : null,
              ),
          ],
        ),
        SizedBox(height: 21.h),
        Text(
          l10n.offerSkipHint,
          style: AppTextStyles.s14Regular.scaled.copyWith(
            fontSize: 13.sp,
            height: 1.35,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  /// `Tomorrow, Mon 12 Oct` → `tomorrow, Mon 12 Oct`, to sit mid-sentence.
  static String _inSentence(String day) =>
      day.isEmpty ? day : day[0].toLowerCase() + day.substring(1);
}

/// The buttons, or what replaces them once the offer cannot be answered.
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.state});

  final OrderOfferState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final cubit = context.read<OrderOfferCubit>();
    final offer = state.offer;
    final gutter = OrdersTodayMetrics.gutter.w;

    Widget backToOrders() => HistoryPrimaryButton(
          label: l10n.offerBackToOrders,
          busy: false,
          onPressed: () => Navigator.of(context).maybePop(),
        );

    final List<Widget> content = switch (state.status) {
      OrderOfferStatus.expired => [
          OfferEndedNote(
            icon: OfferIcons.timer(size: 24),
            title: l10n.offerExpiredTitle,
            message: l10n.offerExpiredBody(
              offer.answerWindow.inMinutes,
              offer.fleetName,
            ),
          ),
          SizedBox(height: 24.h),
          backToOrders(),
        ],
      OrderOfferStatus.takenBack => [
          OfferEndedNote(
            icon: OfferIcons.package(size: 24),
            title: l10n.offerTakenBackTitle(offer.fleetName),
            message: l10n.offerTakenBackBody,
          ),
          SizedBox(height: 24.h),
          backToOrders(),
        ],
      _ when state.error != OrderOfferError.none => [
          OfferErrorCard(
            title: switch (state.error) {
              OrderOfferError.declineOffline => l10n.offerOfflineDeclineTitle,
              OrderOfferError.acceptOffline => l10n.offerOfflineAcceptTitle,
              _ => l10n.offerFailedTitle,
            },
            message: state.error == OrderOfferError.failed
                ? l10n.offerFailedBody
                : l10n.offerOfflineBody,
          ),
          SizedBox(height: 15.h),
          HistoryPrimaryButton(
            label: l10n.ordersTryAgain,
            busy: state.isBusy,
            onPressed: cubit.retry,
          ),
        ],
      _ => _answerButtons(context, l10n),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        gutter,
        14.h,
        gutter,
        16.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content,
      ),
    );
  }

  List<Widget> _answerButtons(BuildContext context, AppLocalizations l10n) {
    final cubit = context.read<OrderOfferCubit>();
    final offer = state.offer;
    final picked = state.acceptedOrders.length;
    final skipped = offer.orders.length - picked;

    final acceptLabel = !offer.isGroup
        ? l10n.offerOneOrderAccept
        : skipped == 0
            ? l10n.offerAcceptAll(offer.orders.length)
            : l10n.offerAcceptSome(picked, skipped);

    Future<void> decline() async {
      final reason = await OfferDeclineSheet.show(
        context,
        fleetName: offer.fleetName,
      );
      if (reason != null) await cubit.decline(reason);
    }

    return [
      Text(
        offer.isGroup
            ? l10n.offerGroupNoAnswer(offer.orders.length, offer.fleetName)
            : l10n.offerOneOrderNoAnswer(offer.fleetName),
        textAlign: TextAlign.center,
        style: AppTextStyles.s12Regular.scaled.copyWith(
          height: 1.35,
          color: AppColors.textMuted,
        ),
      ),
      SizedBox(height: 14.h),
      Row(
        children: [
          SizedBox(
            width: (offer.isGroup ? 130 : 120).w,
            child: OfferDeclineButton(
              label: offer.isGroup
                  ? l10n.offerDeclineAll
                  : l10n.offerOneOrderDecline,
              onPressed: state.isBusy ? null : decline,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: HistoryPrimaryButton(
              label: acceptLabel,
              busy: state.status == OrderOfferStatus.accepting,
              onPressed: picked == 0 || state.isBusy ? null : cubit.accept,
            ),
          ),
        ],
      ),
    ];
  }
}

/// The offer can no longer be taken, or an answer is stuck: the details
/// step back so the panel reads first.
bool _faded(OrderOfferState state) =>
    state.status == OrderOfferStatus.expired ||
    state.status == OrderOfferStatus.takenBack ||
    state.error != OrderOfferError.none;
