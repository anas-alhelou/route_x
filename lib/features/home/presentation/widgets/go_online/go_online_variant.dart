// lib/features/home/presentation/widgets/go_online/go_online_variant.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/presentation/navigation/home_navigator.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_actions.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_declined_panel.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_progress_panel.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_request_panel.dart';

/// Why the driver cannot go online.
///
/// Presentation-level, not domain-level: the *reason* is derived by `HomeBloc`
/// from [FleetRequestStatus] and is only ever used to choose a frame. The status
/// enum is the domain's; this is the design's answer to it.
enum GoOnlineBlockedReason {
  /// The driver has not joined or requested any fleet yet.
  noFleet,

  /// A join request is awaiting fleet manager review.
  pending,

  /// The join request was declined by the fleet manager.
  declined,
}

/// Everything that differs between the three Go Online frames, in one place.
///
/// The sheet used to answer "which frame is this?" in four separate
/// `switch (reason)` blocks — one in the icon well, one in the headers, one in
/// the panel slot and one in the actions. That put the same four-way question in
/// four files' worth of a single widget, and adding a frame meant finding all
/// four. Each subclass now *is* its frame: the shell asks it for its glyph, its
/// copy, its panel and its buttons, and never branches.
///
/// Sealed so the shell's `buildPanel` is checked against this hierarchy — a
/// fourth frame cannot be added without every consumer seeing it.
sealed class GoOnlineVariant {
  const GoOnlineVariant({required this.overview});

  /// The snapshot the frame draws from, if the caller had one.
  ///
  /// Nullable throughout: the sheet is also shown from a preview or a test with
  /// no snapshot, and every read of it already has a documented fallback.
  final HomeOverview? overview;

  /// The block between the title and the actions. Unique to each frame — this is
  /// the half of the design that genuinely differs.
  Widget buildPanel(BuildContext context);

  /// The stack of buttons at the foot of the sheet.
  List<Widget> buildActions(BuildContext context);

  /// Which variant [reason] selects.
  ///
  /// The one place the enum and the hierarchy meet. Exhaustive on purpose: no
  /// default branch, so adding a case to [GoOnlineBlockedReason] without a
  /// variant is a compile error rather than a blank sheet in production.
  factory GoOnlineVariant.of(
    GoOnlineBlockedReason reason, {
    HomeOverview? overview,
    HomeNavigator navigator = const HomeNavigator(),
  }) => switch (reason) {
    GoOnlineBlockedReason.noFleet => GoOnlineNoFleetVariant(
      overview: overview,
      navigator: navigator,
    ),
    GoOnlineBlockedReason.pending => GoOnlinePendingVariant(
      overview: overview,
      navigator: navigator,
    ),
    GoOnlineBlockedReason.declined => GoOnlineDeclinedVariant(
      overview: overview,
      navigator: navigator,
    ),
  };
}

/// Shared pieces of the shell: the handle, the tinted disc, and the headings.
///
/// These do not vary per frame, so they are not part of [GoOnlineVariant]. What
/// *does* vary is the glyph and the two strings, which are declared once here
/// rather than re-switched inside each of the three widgets below.
abstract base class GoOnlineVariantBase extends GoOnlineVariant {
  const GoOnlineVariantBase({required super.overview, required this.navigator});

  /// How the frame's buttons leave the screen.
  ///
  /// Injected so the sheet can be driven in a test without a real router.
  final HomeNavigator navigator;

  /// The glyph drawn inside the tinted disc.
  String get iconPath;

  /// Fill of that disc.
  Color get discFill;

  /// Colour the glyph is tinted with.
  Color get iconTint;

  /// The frame's title.
  String title(BuildContext context);

  /// The frame's body copy.
  String body(BuildContext context);
}

/// The "you have no fleet" frame.
///
/// The only one of the three whose panel is not about a specific request: it
/// shows the setup checklist with Fleet as the next step, so the driver is shown
/// what is still missing rather than being told what went wrong.
final class GoOnlineNoFleetVariant extends GoOnlineVariantBase {
  const GoOnlineNoFleetVariant({
    required super.overview,
    required super.navigator,
  });

  @override
  String get iconPath => AppAssets.icFleetVan;

  @override
  Color get discFill => AppColors.surfaceSheetIcon;

  @override
  Color get iconTint => AppColors.textPrimary;

  @override
  String title(BuildContext context) => context.tr.goOnlineSheetNoFleetTitle;

  @override
  String body(BuildContext context) => context.tr.goOnlineSheetNoFleetBody;

  @override
  Widget buildPanel(BuildContext context) => const GoOnlineProgressPanel();

  @override
  List<Widget> buildActions(BuildContext context) =>
      GoOnlineActions.noFleet(context, navigator);
}

/// The "waiting for a decision" frame.
///
/// Names the fleet and when it was asked for, so the driver can tell at a glance
/// whether this is their request and not someone else's.
final class GoOnlinePendingVariant extends GoOnlineVariantBase {
  const GoOnlinePendingVariant({
    required super.overview,
    required super.navigator,
  });

  @override
  String get iconPath => AppAssets.icList;

  @override
  Color get discFill => AppColors.surfaceSheetIcon;

  @override
  Color get iconTint => AppColors.textPrimary;

  @override
  String title(BuildContext context) => context.tr.goOnlineSheetPendingTitle(
    overview?.fleetRequest?.fleetName ?? kFallbackFleetName,
  );

  @override
  String body(BuildContext context) => context.tr.goOnlineSheetPendingBody;

  @override
  Widget buildPanel(BuildContext context) => GoOnlineRequestPanel(
    overview: overview,
  );

  @override
  List<Widget> buildActions(BuildContext context) =>
      GoOnlineActions.pending(context, navigator);
}

/// The "declined" frame.
///
/// Carries the dispatcher's own words where there are any. Left null in the data
/// layer rather than defaulted to English copy, so the panel's localized fallback
/// is what runs in every other case.
final class GoOnlineDeclinedVariant extends GoOnlineVariantBase {
  const GoOnlineDeclinedVariant({
    required super.overview,
    required super.navigator,
  });

  @override
  String get iconPath => AppAssets.icClose;

  @override
  Color get discFill => AppColors.surfaceSheetIconDeclined;

  @override
  Color get iconTint => AppColors.textError;

  @override
  String title(BuildContext context) => context.tr.goOnlineSheetDeclinedTitle(
    overview?.fleetRequest?.fleetName ?? kFallbackFleetName,
  );

  @override
  String body(BuildContext context) => context.tr.goOnlineSheetDeclinedBody;

  @override
  Widget buildPanel(BuildContext context) => GoOnlineDeclinedPanel(
    overview: overview,
  );

  @override
  List<Widget> buildActions(BuildContext context) =>
      GoOnlineActions.declined(context, navigator);
}

/// Stands in for a fleet name when the sheet is opened without a snapshot.
///
/// Only reachable from a preview or a test; every real path through Home has a
/// request to name. Named rather than inlined so the two frames that print it
/// cannot drift apart.
const String kFallbackFleetName = 'Red Sea Express';