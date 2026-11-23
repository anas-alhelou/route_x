import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

class RouteXSkeleton extends StatefulWidget {
  const RouteXSkeleton.line({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6.0,
    this.opacity = 1.0,
  }) : isCircle = false;

  const RouteXSkeleton.circle({
    super.key,
    required double size,
    this.opacity = 1.0,
  }) : width = size,
       height = size,
       radius = size / 2,
       isCircle = true;

  const RouteXSkeleton.block({
    super.key,
    required this.width,
    required this.height,
    this.radius = 32.0,
    this.opacity = 1.0,
  }) : isCircle = false;

  final double width;
  final double height;
  final double radius;
  final double opacity;
  final bool isCircle;

  @override
  State<RouteXSkeleton> createState() => _RouteXSkeletonState();
}

class _RouteXSkeletonState extends State<RouteXSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.opacity * _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.borderDeactivated, // #D0D0D0
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}
