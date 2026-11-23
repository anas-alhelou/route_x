// lib/features/home/presentation/pages/enter_fleet_code_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_info_card.dart';
import 'package:routex_mobile/core/widgets/routex_screen_entry.dart';
import 'package:routex_mobile/core/widgets/routex_top_bar.dart';
import 'package:routex_mobile/features/home/presentation/bloc/enter_fleet_code_bloc.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_entry.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_footer.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_help_button.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_title.dart';

/// Enter Fleet Code screen supporting default and invalid frames.
///
/// Drivers land here from the Home quick action, the Find a fleet invite footer,
/// or the "no fleet yet" Go Online sheet, so it has to work as a destination that
/// is replaced (after a successful join) and as one that is popped back from.
///
/// Painted on [AppColors.surfaceBackground] rather than white, and with a
/// [RouteXTopBar] rather than an [AppBar]: the design draws this screen on the
/// same near-white canvas as Find a fleet, so a white bar would draw a hard
/// horizontal edge across a page that has none.
///
/// **The page holds no code.** It renders `state.code` and forwards the row's
/// callbacks as events. It keeps no `setState`, no `GlobalKey` and no local
/// mirror of the value — the previous version kept all three, and the mirror was
/// what let the input row write to its parent mid-build.
class EnterFleetCodePage extends StatelessWidget {
  const EnterFleetCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EnterFleetCodeBloc>(
      create: (_) => getIt<EnterFleetCodeBloc>(),
      child: const _EnterFleetCodeView(),
    );
  }
}

/// The page body: state wiring plus navigation out.
///
/// Stateless, because the entry animation lives in [RouteXScreenEntry] and the
/// code lives in the BLoC — neither needs a [State] here. The previous version
/// was a `StatefulWidget` whose only state was an animation controller it never
/// read, and which meant the page could set its own state during a build.
class _EnterFleetCodeView extends StatelessWidget {
  const _EnterFleetCodeView();

  /// Reads the clipboard and hands the raw string to the BLoC.
  ///
  /// The BLoC applies `FleetCode.normalize`; doing it here would duplicate the
  /// rules in the one layer that has no business knowing them. The `context.mounted`
  /// check is not optional — reading the clipboard is an await, and the driver
  /// can leave the screen while it is in flight, at which point adding an event
  /// would throw.
  Future<void> _handlePaste(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return;
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      context.read<EnterFleetCodeBloc>().add(PasteRequested(text));
    }
  }

  /// "Try again": drop the rejected code and put the caret back in box one.
  ///
  /// Replaces the old `GlobalKey<FleetCodeInputRowState>.clearBoxes()` call.
  /// The row no longer exposes an imperative clear, because a widget that has to
  /// be *told* to clear its own boxes is a widget that can disagree with its
  /// value; here the event empties the state, and the row redraws itself empty.
  void _clearAndRefocus(BuildContext context) {
    context.read<EnterFleetCodeBloc>().add(const CodeCleared());
  }

  /// Leaves for Find a fleet, replacing this screen rather than stacking on it.
  ///
  /// A driver who has given up on their code and gone to browse fleets should not
  /// be able to swipe back into an empty code form, and a second visit should not
  /// leave a stack of identical dead entries behind. Popping would satisfy
  /// neither.
  void _goToFindFleet(BuildContext context) {
    context.pushReplacementNamed(RoutersName.findFleetScreen);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return BlocConsumer<EnterFleetCodeBloc, EnterFleetCodeState>(
      listener: (context, state) {
        // Verified: the request is already recorded by the data layer, so there
        // is nothing to pass back — just leave the screen the driver came from.
        if (state.isSuccess) {
          context.pop();
        }
      },
      builder: (context, state) {
        final isInvalid = state.isInvalid;
        final isSubmitting = state.isSubmitting;

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          body: SafeArea(
            child: RouteXScreenEntry(
              child: Column(
                children: [
                  RouteXTopBar(
                    backgroundColor: AppColors.surfaceBackground,
                    onBack: () => context.pop(),
                    // The design only offers Help once a code has been
                    // rejected — before then there is nothing to be stuck on.
                    trailing: isInvalid
                        ? EnterCodeHelpButton(label: tr.enterFleetCodeHelp)
                        : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.p24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSpacing.s12.h),
                          EnterCodeTitle(
                            leading: tr.enterFleetCodeTitleStart,
                            accent: tr.enterFleetCodeTitleEnd,
                          ),
                          SizedBox(height: AppSpacing.s8.h),
                          Text(
                            tr.enterFleetCodeSubtitle,
                            style: AppTextStyles.s14Regular.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          SizedBox(height: AppSpacing.s28.h),
                          EnterCodeEntry(
                            code: state.code,
                            isInvalid: isInvalid,
                            isSubmitting: isSubmitting,
                            onCodeChanged: (code) => context
                                .read<EnterFleetCodeBloc>()
                                .add(CodeChanged(code)),
                            onEditAttempted: isInvalid
                                ? () => context.read<EnterFleetCodeBloc>().add(
                                    const ErrorCleared(),
                                  )
                                : null,
                            onPaste: () => _handlePaste(context),
                          ),
                          SizedBox(height: AppSpacing.s32.h),
                          RouteXInfoCard(
                            title: tr.enterFleetCodeWhereFindTitle,
                            body: tr.enterFleetCodeWhereFindBody,
                          ),
                          SizedBox(height: AppSpacing.s24.h),
                        ],
                      ),
                    ),
                  ),
                  EnterCodeFooter(
                    isInvalid: isInvalid,
                    isLoading: isSubmitting,
                    canSubmit: state.isSubmitEnabled,
                    tryAgainLabel: tr.enterFleetCodeTryAgain,
                    askManagerLabel: tr.enterFleetCodeAskManager,
                    joinLabel: tr.enterFleetCodeJoinButton,
                    stillStuckPrompt: tr.enterFleetCodeStillStuck,
                    lostCodePrompt: tr.enterFleetCodeLostCode,
                    findFleetLabel: tr.enterFleetCodeFindFleetInstead,
                    onTryAgain: () => _clearAndRefocus(context),
                    // TODO: contact-manager flow — no destination designed yet.
                    onAskManager: () {},
                    onSubmit: () =>
                        context.read<EnterFleetCodeBloc>().add(const Submitted()),
                    onFindFleet: () => _goToFindFleet(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}