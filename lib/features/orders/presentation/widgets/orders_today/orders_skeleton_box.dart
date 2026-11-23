// lib/features/orders/presentation/widgets/orders_today/orders_skeleton_box.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// Drives the pulse for every [OrdersSkeletonBox] beneath it.
///
/// One [AnimationController] for the page, handed down through an inherited
/// scope: twenty boxes each running their own ticker would drift out of
/// phase within a second and turn a calm placeholder into noise.
class OrdersSkeletonPulse extends StatefulWidget {
  const OrdersSkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<OrdersSkeletonPulse> createState() => _OrdersSkeletonPulseState();
}

class _OrdersSkeletonPulseState extends State<OrdersSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonPulseScope(pulse: _pulse, child: widget.child);
  }
}

class _SkeletonPulseScope extends InheritedWidget {
  const _SkeletonPulseScope({required this.pulse, required super.child});

  final Animation<double> pulse;

  static Animation<double>? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SkeletonPulseScope>()
      ?.pulse;

  @override
  bool updateShouldNotify(_SkeletonPulseScope oldWidget) =>
      oldWidget.pulse != pulse;
}

/// A grey placeholder standing in for a piece of content that has not
/// arrived yet.
///
/// A slow breath between two greys, not a sweeping shimmer: the skeleton is
/// on screen for 1500 ms, and a sweep that short reads as a glitch rather
/// than as loading.
class OrdersSkeletonBox extends StatelessWidget {
  const OrdersSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  }) : _isCircle = false;

  const OrdersSkeletonBox.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = 0,
        _isCircle = true;

  /// Null stretches the box to its parent's width.
  final double? width;

  final double height;
  final double radius;
  final bool _isCircle;

  static Color get _dim => AppColors.surfaceEmpty;
  static Color get _bright =>
      AppColors.isDark ? const Color(0xFF3A4032) : const Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final pulse = _SkeletonPulseScope.maybeOf(context);

    Widget box(Color color) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            shape: _isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius:
                _isCircle ? null : BorderRadius.circular(radius.r),
          ),
        );

    if (pulse == null) return box(_dim);

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) =>
          box(Color.lerp(_dim, _bright, pulse.value) ?? _dim),
    );
  }
}
