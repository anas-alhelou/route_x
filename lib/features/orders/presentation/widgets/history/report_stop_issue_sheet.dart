// lib/features/orders/presentation/widgets/history/report_stop_issue_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../../domain/entities/stop_issue_entity.dart';
import '../../controllers/report_stop_issue_cubit.dart';
import '../../controllers/report_stop_issue_state.dart';
import '../orders_today/orders_today_metrics.dart';
import 'history_primary_button.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// "What's wrong with this stop?" — a closed stop disputed in four taps.
///
/// Reasons first, words second: most disputes fit one of four shapes, and
/// a driver on a kerbside should not have to compose a paragraph to say
/// "the gate was locked". The note is there for the detail, and required
/// only when the reason itself says nothing ("Something else").
class ReportStopIssueSheet extends StatelessWidget {
  const ReportStopIssueSheet({super.key});

  /// Opens the sheet for [orderCode]. Resolves to true once the report has
  /// been sent, false or null if the driver backed out.
  static Future<bool?> show(BuildContext context, {required String orderCode}) {
    return showRoutexSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => ReportStopIssueCubit(
          reportStopIssueUseCase: getIt(),
          orderCode: orderCode,
        ),
        child: const ReportStopIssueSheet(),
      ),
    );
  }

  static const double _gutter = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return BlocConsumer<ReportStopIssueCubit, ReportStopIssueState>(
      listenWhen: (previous, current) =>
          current.status == ReportStopIssueStatus.sent,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final cubit = context.read<ReportStopIssueCubit>();
        final kind = state.kind;

        return Padding(
          // Rides above the keyboard while the note is typed.
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                _gutter.w,
                12.h,
                _gutter.w,
                16.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderDeactivated,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    l10n.reportIssueTitle,
                    style: AppTextStyles.s24Bold.scaled.copyWith(
                      fontSize: 22.sp,
                      height: 1.4,
                      letterSpacing: -0.22.sp,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  for (final option in StopIssueKind.values) ...[
                    if (option != StopIssueKind.values.first)
                      SizedBox(height: 8.h),
                    _IssueOption(
                      label: _label(l10n, option),
                      selected: option == kind,
                      onTap: () => cubit.select(option),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  _NoteField(
                    hint: kind != null && StopIssueEntity.needsNote(kind)
                        ? l10n.reportIssueNoteHintRequired
                        : l10n.reportIssueNoteHint,
                    enabled: !state.isSending,
                    onChanged: cubit.noteChanged,
                  ),
                  if (state.status == ReportStopIssueStatus.failed) ...[
                    SizedBox(height: 10.h),
                    Text(
                      l10n.reportIssueFailed,
                      style: AppTextStyles.s14Regular.scaled
                          .copyWith(color: AppColors.textError),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  HistoryPrimaryButton(
                    label: l10n.reportIssueSend,
                    busy: state.isSending,
                    onPressed: state.canSend ? cubit.send : null,
                  ),
                  SizedBox(height: 14.h),
                  TextButton(
                    onPressed: state.isSending
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandBlack,
                      minimumSize: Size.fromHeight(44.h),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: AppTextStyles.s14SemiBold.scaled.copyWith(
                        fontSize: 15.sp,
                        height: 1.4,
                        color: AppColors.brandBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _label(AppLocalizations l10n, StopIssueKind kind) =>
      switch (kind) {
        StopIssueKind.statusWrong => l10n.reportIssueStatusWrong,
        StopIssueKind.notInMyControl => l10n.reportIssueNotInControl,
        StopIssueKind.timesWrong => l10n.reportIssueTimesWrong,
        StopIssueKind.other => l10n.reportIssueOther,
      };
}

class _IssueOption extends StatelessWidget {
  const _IssueOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.iconBrand : AppColors.surfaceCanvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: BorderSide(
            color: selected ? AppColors.brandMain : AppColors.borderDeactivated,
            width: 1.w,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 52.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  _Radio(selected: selected),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s14SemiBold.scaled.copyWith(
                        fontSize: 15.sp,
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
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final size = 22.w;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.brandMain : AppColors.surfaceWhite,
        border: selected
            ? null
            : Border.all(color: AppColors.borderDeactivated, width: 1.5.w),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({
    required this.hint,
    required this.enabled,
    required this.onChanged,
  });

  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.s14Regular.scaled.copyWith(
      fontSize: 15.sp,
      height: 1.4,
      color: AppColors.brandBlack,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
    );

    return TextField(
      enabled: enabled,
      onChanged: onChanged,
      minLines: 2,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: AppColors.brandBlack,
      style: style,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surfaceWhite,
        // Figma H05: 84 tall with two lines — 14 above, 26 below.
        contentPadding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 26.h),
        border: border,
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: AppColors.brandMain, width: 1.5.w),
        ),
      ),
    );
  }
}

