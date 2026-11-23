// lib/features/orders/presentation/pages/order_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/utils/external_launcher.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/order_detail_entity.dart';
import '../../domain/entities/orders_today_entity.dart';
import '../controllers/order_detail_cubit.dart';
import '../controllers/order_detail_state.dart';
import '../widgets/order_detail/message_dispatch_button.dart';
import '../widgets/order_detail/order_action_row.dart';
import '../widgets/order_detail/order_detail_cards.dart';
import '../widgets/order_detail/order_detail_header.dart';
import '../widgets/order_detail/order_detail_metrics.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import 'search_page.dart';
import 'package:routex_mobile/features/main_layout/presentation/widgets/shell_nav_bar.dart';

/// Everything the driver needs at one stop: who, how to reach them, where
/// exactly, by when, what to hand over, and what dispatch said about it.
///
/// Opened from a row on the Today list. The row's [stop] paints the header
/// immediately; the rest loads by [TodayStopEntity.id].
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.stop});

  final TodayStopEntity stop;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrderDetailCubit(getOrderDetailUseCase: getIt())..load(stop.id),
      child: OrderDetailView(stop: stop),
    );
  }
}

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.stop});

  final TodayStopEntity stop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final isOnTheWay = stop.status == TodayStopStatus.onTheWay;

    return Scaffold(
      bottomNavigationBar: const ShellNavBar(),
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
          builder: (context, state) {
            final detail =
                state is OrderDetailLoaded ? state.detail : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OrderDetailBackButton(
                  label: l10n.ordersTitle,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: OrderDetailMetrics.backToStatus.h,
                      bottom: OrderDetailMetrics.bottomPadding.h +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OrderDetailHero(
                          statusLabel: isOnTheWay
                              ? l10n.ordersOnTheWay
                              : l10n.orderStatusToDo,
                          isOnTheWay: isOnTheWay,
                          customerName: stop.customerName,
                          orderCode: detail?.orderCode,
                          routePosition: detail == null
                              ? null
                              : _routePosition(l10n, detail, isOnTheWay),
                        ),
                        SizedBox(
                          height: OrderDetailMetrics.subtitleToActions.h,
                        ),
                        OrderActionRow(
                          actions: _actions(context, l10n, detail: detail),
                        ),
                        SizedBox(
                          height: OrderDetailMetrics.actionsToFirstCard.h,
                        ),
                        if (state is OrderDetailError)
                          _ErrorMessage(
                            message:
                                context.translateValidationKey(state.messageKey),
                          )
                        else if (detail != null)
                          _DetailCards(stop: stop, detail: detail),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// "Stop 3 of 5 · Today", plus "· 6 min away" on the stop being driven to
  /// — the one question the driver has about it that the list cannot answer.
  String _routePosition(
    AppLocalizations l10n,
    OrderDetailEntity detail,
    bool isOnTheWay,
  ) {
    final position = l10n.orderStopOfTotal(stop.sequence, detail.totalStops);
    final minutes = detail.minutesAway;
    if (!isOnTheWay || minutes == null) return position;
    return '$position · ${l10n.orderMinutesAway(minutes)}';
  }

  /// Every action needs the loaded detail (phone, coordinates), so all three
  /// stay disabled until it lands rather than failing on tap.
  List<OrderActionItem> _actions(
    BuildContext context,
    AppLocalizations l10n, {
    required OrderDetailEntity? detail,
  }) {
    final d = detail;
    Widget icon(SvgGenImage asset) => asset.svg(
          width: 24.w,
          height: 24.w,
          colorFilter: ColorFilter.mode(
            AppColors.brandBlack,
            BlendMode.srcIn,
          ),
        );

    /// Opens the phone's app; when nothing can handle it, tells the driver.
    Future<void> open(Future<bool> Function() launch) async {
      final ok = await launch();
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.orderActionUnavailable)),
        );
      }
    }

    return [
      OrderActionItem(
        icon: icon(Assets.icons.svg.call),
        label: l10n.orderActionCall,
        onPressed: d != null
            ? () => open(() => ExternalLauncher.call(d.customerPhone))
            : null,
      ),
      OrderActionItem(
        icon: icon(Assets.icons.svg.note),
        label: l10n.orderActionMessage,
        onPressed: d != null
            ? () => open(() => ExternalLauncher.sms(d.customerPhone))
            : null,
      ),
      OrderActionItem(
        icon: icon(Assets.icons.svg.navigate),
        label: l10n.orderActionNavigate,
        onPressed: d != null
            ? () => open(
                  () => ExternalLauncher.googleMaps(
                    d.addressLine,
                    latitude: d.latitude,
                    longitude: d.longitude,
                  ),
                )
            : null,
      ),
    ];
  }
}

class _DetailCards extends StatelessWidget {
  const _DetailCards({required this.stop, required this.detail});

  final TodayStopEntity stop;
  final OrderDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final gap = SizedBox(height: OrderDetailMetrics.cardGap.h);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: OrderDetailMetrics.gutter.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderAddressCard(
            label: l10n.orderSectionAddress,
            addressLine: detail.addressLine,
            addressDetails: detail.addressDetails,
            gateCodeLabel: l10n.orderGateCode,
            gateCode: detail.gateCode,
            emphasizeGateCode: stop.status == TodayStopStatus.onTheWay,
          ),
          gap,
          OrderDeliveryWindowCard(
            label: l10n.orderSectionDeliveryWindow,
            timeWindow: stop.timeWindow,
            etaLabel: detail.isOnTime
                ? l10n.orderEtaOnTime(detail.eta)
                : l10n.orderEtaLate(detail.eta),
            isOnTime: detail.isOnTime,
            // Opens search on this customer's first name, so their other
            // orders — tomorrow's, next week's — are listed straight away.
            onEtaPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SearchPage(
                  initialQuery: stop.customerName.split(' ').first,
                ),
              ),
            ),
          ),
          gap,
          OrderPackagesCard(
            label: l10n.orderSectionPackages,
            countLabel: l10n.orderPackagesCount(detail.packagesCount),
            scannedLabel: l10n.orderPackagesScanned(
              detail.scannedCount,
              detail.packagesCount,
            ),
            requirements: [
              for (final requirement in detail.requirements)
                switch (requirement) {
                  DeliveryRequirement.signature =>
                    l10n.orderRequirementSignature,
                  DeliveryRequirement.photo => l10n.orderRequirementPhoto,
                },
            ],
          ),
          if (detail.dispatchNote != null) ...[
            gap,
            OrderDispatchNoteCard(
              label: l10n.orderSectionDispatchNote,
              note: detail.dispatchNote!,
            ),
          ],
          SizedBox(height: OrderDetailMetrics.lastCardToButton.h),
          MessageDispatchButton(
            label: l10n.orderMessageDispatch,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: OrderDetailMetrics.gutter.w,
        vertical: 24.h,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.s14Regular.scaled
            .copyWith(color: AppColors.textError),
      ),
    );
  }
}
