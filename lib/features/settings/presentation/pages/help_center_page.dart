// lib/features/settings/presentation/pages/help_center_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_switch_tile.dart';

typedef _Faq = ({String id, String question, String answer});

/// Searchable FAQ grouped by topic, with a way to report a problem when the
/// answers are not enough.
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _searchController = TextEditingController();
  String _query = '';

  /// Open answers; the first one starts open, as in the design.
  final Set<String> _expanded = {'join_fleet'};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() => _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id));
  }

  /// Matches the question or the answer, ignoring case.
  bool _matches(_Faq faq) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return faq.question.toLowerCase().contains(q) || faq.answer.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final sections = [
      (
        title: tr.helpGettingStarted,
        faqs: <_Faq>[
          (id: 'join_fleet', question: tr.helpQJoinFleet, answer: tr.helpAJoinFleet),
          (id: 'go_online', question: tr.helpQGoOnline, answer: tr.helpAGoOnline),
          (id: 'change_vehicle', question: tr.helpQChangeVehicle, answer: tr.helpAChangeVehicle),
        ],
      ),
      (
        title: tr.helpDeliveries,
        faqs: <_Faq>[
          (id: 'proof', question: tr.helpQProofOfDelivery, answer: tr.helpAProofOfDelivery),
          (id: 'offline', question: tr.helpQOffline, answer: tr.helpAOffline),
          (id: 'not_home', question: tr.helpQCustomerNotHome, answer: tr.helpACustomerNotHome),
        ],
      ),
    ];
    final visible = [
      for (final section in sections)
        (title: section.title, faqs: section.faqs.where(_matches).toList()),
    ].where((section) => section.faqs.isNotEmpty).toList();
    final cardPadding = EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 12.h);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(title: tr.settingsHelpCenter, subtitle: tr.helpSubtitle),
            SizedBox(height: 24.h),
            RouteXTextField(
              controller: _searchController,
              hintText: tr.helpSearchHint,
              textStyle: AppTextStyles.s16Regular.copyWith(
                fontSize: AppFonts.size16.sp,
                color: AppColors.textPrimary,
              ),
              textInputAction: TextInputAction.search,
              prefixIcon: Icon(Icons.search, size: 22.r),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            SizedBox(height: 17.h),
            if (visible.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  tr.helpNoResults,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s14Regular.copyWith(
                    fontSize: AppFonts.size14.sp,
                    color: AppColors.textGray,
                  ),
                ),
              ),
            for (final section in visible) ...[
              SettingsCard(
                title: section.title,
                padding: cardPadding,
                children: [
                  for (final faq in section.faqs)
                    _FaqTile(
                      question: faq.question,
                      answer: faq.answer,
                      // While searching, matches are shown open.
                      isExpanded: _query.isNotEmpty || _expanded.contains(faq.id),
                      onTap: () => _toggle(faq.id),
                    ),
                ],
              ),
              SizedBox(height: 17.h),
            ],
            SettingsCard(
              title: tr.helpStillNeedHelp,
              padding: cardPadding,
              children: [
                SettingsOptionTile(
                  icon: Icons.flag_outlined,
                  title: tr.settingsReportProblem,
                  subtitle: tr.helpReportProblemHint,
                  onTap: () => context.push(RoutersName.reportProblemScreen),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 22.r,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Question row that expands in place to show its answer.
class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 5.5.h, 12.w, 5.5.h),
          decoration: BoxDecoration(
            color: AppColors.iconBrand,
            borderRadius: radius,
            border: Border.all(color: AppColors.brandMain),
          ),
          child: AnimatedSize(
            duration: _duration,
            curve: Curves.easeOut,
            alignment: AlignmentDirectional.topStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 44.h),
                  child: Row(
                  children: [
                    const SettingsIconBadge(icon: Icons.chat_bubble_outline),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        question,
                        style: AppTextStyles.s16Bold.copyWith(
                          fontSize: AppFonts.size16.sp,
                          height: 1.375,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: _duration,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24.r,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                ),
                if (isExpanded)
                  Padding(
                    // Lines the answer up under the question text.
                    padding: EdgeInsetsDirectional.fromSTEB(48.r, 5.h, 8.w, 8.h),
                    child: Text(
                      answer,
                      style: AppTextStyles.s14Regular.copyWith(
                        fontSize: 15.sp,
                        height: 1.35,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
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
