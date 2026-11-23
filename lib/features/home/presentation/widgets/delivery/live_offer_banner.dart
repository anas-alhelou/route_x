// lib/features/home/presentation/widgets/delivery/live_offer_banner.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routex_mobile/features/home/presentation/widgets/new_order_offer_banner.dart';

/// The NF3 banner with a live countdown ("answer in 09:58").
class LiveOfferBanner extends StatefulWidget {
  const LiveOfferBanner({
    required this.orderCount,
    required this.fleetName,
    required this.deadline,
    required this.onView,
    this.onExpired,
    super.key,
  });

  final int orderCount;
  final String fleetName;

  /// When the soonest offer runs out; null shows no countdown.
  final DateTime? deadline;
  final VoidCallback onView;

  /// The countdown reached zero — the offer is gone.
  final VoidCallback? onExpired;

  @override
  State<LiveOfferBanner> createState() => _LiveOfferBannerState();
}

class _LiveOfferBannerState extends State<LiveOfferBanner> {
  Timer? _timer;
  bool _expiredReported = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      final deadline = widget.deadline;
      if (deadline != null &&
          !_expiredReported &&
          !deadline.isAfter(DateTime.now())) {
        _expiredReported = true;
        widget.onExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _clock() {
    final deadline = widget.deadline;
    if (deadline == null) return '';
    var left = deadline.difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    final minutes = left.inMinutes.toString().padLeft(2, '0');
    final seconds = (left.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return NewOrderOfferBanner(
      orderCount: widget.orderCount,
      fleetName: widget.fleetName,
      deadline: _clock(),
      onView: widget.onView,
    );
  }
}
