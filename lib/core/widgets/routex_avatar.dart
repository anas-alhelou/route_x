import 'package:flutter/material.dart';
import 'package:routex_mobile/core/session/driver_identity.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_profile_image.dart';

/// The driver's round avatar: the picture they chose, or — when there is none
/// (or it cannot load) — the first two letters of their name on a brand tint.
///
/// [photo] and [name] default to the signed-in driver ([DriverIdentity]).
class RouteXAvatar extends StatelessWidget {
  const RouteXAvatar({
    super.key,
    required this.size,
    this.photo,
    this.name,
    this.ringColor,
    this.ringWidth = 2,
    this.fontSize,
  });

  final double size;
  final String? photo;
  final String? name;
  final Color? ringColor;
  final double ringWidth;
  final double? fontSize;

  /// First two letters of [name], upper-cased; empty when it has none.
  static String initialsOf(String name) {
    final letters = name.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
    return String.fromCharCodes(letters.runes.take(2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<({String name, String? photo})>(
      valueListenable: DriverIdentity.current,
      builder: (context, who, _) {
        final shownPhoto = (photo != null && photo!.isNotEmpty)
            ? photo
            : who.photo;
        final initials = initialsOf(
          (name != null && name!.trim().isNotEmpty) ? name! : who.name,
        );
        final placeholder = ColoredBox(
          color: AppColors.iconBrand,
          child: Center(
            child: initials.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    size: size * 0.5,
                    color: AppColors.textPrimary,
                  )
                : Text(
                    initials,
                    style: TextStyle(
                      fontSize: fontSize ?? size * 0.36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        );
        return Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(ringColor == null ? 0 : 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: ringColor == null
                ? null
                : Border.all(color: ringColor!, width: ringWidth),
          ),
          child: ClipOval(
            child: RouteXProfileImage(path: shownPhoto, placeholder: placeholder),
          ),
        );
      },
    );
  }
}
