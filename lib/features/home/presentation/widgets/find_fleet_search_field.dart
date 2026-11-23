// lib/features/home/presentation/widgets/find_fleet_search_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_search_field.dart';

/// Search field for the Find a Fleet screen (Figma 5237:3435).
///
/// Figma: 56h, r6, hairline #D0D0D0, a search glyph on the leading edge and a
/// filter glyph on the trailing one. The box itself is [RouteXSearchField].
///
/// The controller is owned here rather than rebuilt per build. The previous
/// version constructed a fresh [TextEditingController] inside `build`, which
/// threw away the selection and put the caret back at the start on every
/// keystroke that caused a rebuild — and this field rebuilds on each character,
/// because the bloc echoes the query straight back into the state.
class FindFleetSearchField extends StatefulWidget {
  const FindFleetSearchField({
    required this.hintText,
    required this.onChanged,
    this.initialValue = '',
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  /// Seeds the field once, on first build. Later changes to it are ignored:
  /// the field is the source of truth for its own contents.
  final String initialValue;

  @override
  State<FindFleetSearchField> createState() => _FindFleetSearchFieldState();
}

class _FindFleetSearchFieldState extends State<FindFleetSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RouteXSearchField(
      controller: _controller,
      hintText: widget.hintText,
      onChanged: widget.onChanged,
      trailing: SvgPicture.asset(
        AppAssets.icFilter,
        width: AppSizes.iconSm.w,
        height: AppSizes.iconSm.w,
        colorFilter: ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
      ),
    );
  }
}
