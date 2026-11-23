// lib/features/orders/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/order_search_result_entity.dart';
import '../controllers/order_search_cubit.dart';
import '../controllers/order_search_state.dart';
import '../widgets/orders_today/orders_card.dart';
import '../widgets/orders_today/orders_section_label.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import '../widgets/search/search_field_bar.dart';
import '../widgets/search/search_metrics.dart';
import '../widgets/search/search_no_results.dart';
import '../widgets/search/search_result_tile.dart';
import '../widgets/search/search_scope_chips.dart';
import 'order_detail_page.dart';

/// Finds any order on the driver's schedule — today's route or a later day —
/// by name, street, order number or the last four digits of a phone.
///
/// [initialQuery] pre-fills the field, so a screen that opens search about a
/// particular customer lands on their orders already listed.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderSearchCubit(
        searchOrdersUseCase: getIt(),
        initialQuery: initialQuery,
      ),
      child: SearchView(initialQuery: initialQuery),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final cubit = context.read<OrderSearchCubit>();

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OrderSearchCubit, OrderSearchState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchFieldBar(
                  controller: _controller,
                  hint: l10n.ordersSearchLabel,
                  cancelLabel: l10n.searchCancel,
                  scanLabel: l10n.searchScanPackage,
                  onChanged: cubit.queryChanged,
                  onCancel: () => Navigator.of(context).maybePop(),
                  onScan: _scanPackage,
                ),
                SizedBox(height: SearchMetrics.fieldToChips.h),
                SearchScopeChips(
                  scope: state.scope,
                  labels: {
                    OrderSearchScope.all: l10n.searchScopeAll,
                    OrderSearchScope.today: l10n.searchScopeToday,
                    OrderSearchScope.upcoming: l10n.searchScopeUpcoming,
                  },
                  onChanged: cubit.scopeChanged,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(
                      top: SearchMetrics.chipsToLabel.h,
                      bottom: SearchMetrics.bottomPadding.h +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    child: _Results(state: state, onScan: _scanPackage),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Shared by the box icon in the field and the empty state's button.
  /// No scanner is wired into the app yet.
  void _scanPackage() {}
}

class _Results extends StatelessWidget {
  const _Results({required this.state, required this.onScan});

  final OrderSearchState state;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final help = _MutedText(l10n.searchHelp);

    if (state.isIdle) return help;

    if (state.results.isEmpty) {
      return Padding(
        // The scroll view already pads by the label gap; top up to the
        // empty state's own distance from the chips.
        padding: EdgeInsets.only(
          top: (SearchMetrics.chipsToEmpty - SearchMetrics.chipsToLabel).h,
        ),
        child: SearchNoResults(
          title: l10n.searchNoResults(state.query.trim()),
          hint: l10n.searchNoResultsHint,
          scanLabel: l10n.searchScanInstead,
          onScan: onScan,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrdersSectionLabel(
          label: l10n.searchResultsCount(state.results.length),
        ),
        SizedBox(height: SearchMetrics.labelToList.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SearchMetrics.gutter.w),
          child: OrdersCard(
            children: [
              for (final result in state.results)
                SearchResultTile(
                  result: result,
                  todayLabel: l10n.searchScopeToday,
                  newLabel: l10n.searchNewBadge,
                  onTap: _openerFor(context, result),
                ),
            ],
          ),
        ),
        SizedBox(height: SearchMetrics.listToHelp.h),
        // The help stays under the results: it is how a driver who found
        // the wrong Ahmed learns they can search by phone digits instead.
        help,
      ],
    );
  }

  /// Today's stops open their detail. Later days have no detail screen yet,
  /// so their rows stay inert rather than opening one that would claim
  /// "Stop N of M · Today".
  VoidCallback? _openerFor(
    BuildContext context,
    OrderSearchResultEntity result,
  ) {
    final stop = result.todayStop;
    if (stop == null) return null;
    return () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailPage(stop: stop),
          ),
        );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SearchMetrics.labelGutter.w),
      child: Text(
        text,
        style: AppTextStyles.s14Regular.scaled
            .copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
