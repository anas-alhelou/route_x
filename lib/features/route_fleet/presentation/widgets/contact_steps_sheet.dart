import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ContactStepsSheet extends StatefulWidget {
  const ContactStepsSheet({
    super.key,
    required this.stopIndex,
    required this.totalStops,
    required this.customerName,
    this.initialWaitSeconds = 134, // 2:14 default per Figma frame
    this.totalWaitSeconds = 300, // 5 minutes
    required this.onCallAgainTapped,
    required this.onMessageTapped,
    required this.onMarkCouldntDeliverTapped,
  });

  final int stopIndex;
  final int totalStops;
  final String customerName;
  final int initialWaitSeconds;
  final int totalWaitSeconds;
  // TODO: Launch phone call to customer
  final VoidCallback onCallAgainTapped;
  // TODO: Open messaging app
  final VoidCallback onMessageTapped;
  // TODO: Mark stop as failed & transition to next stop (R17)
  final VoidCallback onMarkCouldntDeliverTapped;

  @override
  State<ContactStepsSheet> createState() => _ContactStepsSheetState();
}

class _ContactStepsSheetState extends State<ContactStepsSheet> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialWaitSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  bool get _canMarkFailed => _remainingSeconds <= 0;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.customerName.split(' ').first;

    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Overline
          Text(
            context.tr.routeStopOfCustomer(widget.stopIndex.toString(), widget.totalStops.toString(), widget.customerName.toUpperCase()),
            style: AppTextStyles.s10Bold12.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 12.h),

          // 2. Title
          Text(
            context.tr.routeTryingToReach(firstName),
            style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
          ),
          SizedBox(height: 12.h),

          // 3. Wait Timer Row (Ring 72x72 + Text)
          Row(
            children: [
              SizedBox(
                width: 72.w,
                height: 72.h,
                child: CustomPaint(
                  painter: _TimerRingPainter(
                    remainingSeconds: _remainingSeconds,
                    totalSeconds: widget.totalWaitSeconds,
                  ),
                  child: Center(
                    child: Text(
                      _formattedTime,
                      style: AppTextStyles.s17ExtraBold.copyWith(color: AppColors.brandBlack),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  context.tr.routeWaitBeforeMarking,
                  style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 4. Contact Log Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(AppSizes.r16),
              border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
            ),
            child: Column(
              children: [
                _buildLogItem(context.tr.routeCalled, context.tr.routeNoAnswerAt('10:21')),
                Divider(color: AppColors.borderDeactivated, height: 1),
                _buildLogItem(context.tr.routeCalled, context.tr.routeNoAnswerAt('10:23')),
                Divider(color: AppColors.borderDeactivated, height: 1),
                _buildLogItem(context.tr.routeMessageSent, '10:23'),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // 5. Actions (Call again / Message)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWhite,
                      side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                    ),
                    onPressed: widget.onCallAgainTapped,
                    child: Text(
                      context.tr.routeCallAgain,
                      style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 52.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWhite,
                      side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                    ),
                    onPressed: widget.onMessageTapped,
                    child: Text(
                      context.tr.routeMessage,
                      style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 6. Mark as couldn't deliver button (Disabled until timer ends)
          Opacity(
            opacity: _canMarkFailed ? 1.0 : 0.5,
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerSurface,
                  elevation: 0,
                  side: BorderSide(color: AppColors.dangerIcon, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: _canMarkFailed ? widget.onMarkCouldntDeliverTapped : null,
                child: Text(
                  context.tr.routeMarkCouldntDeliver,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.dangerIcon),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // 7. Footnote
          Center(
            child: Text(
              context.tr.routeAvailableAfterWait,
              style: AppTextStyles.s12Medium145.copyWith(color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String title, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.s14SemiBold.copyWith(color: AppColors.brandBlack),
          ),
          Text(
            time,
            style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.w;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.borderDeactivated
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    // Elapsed/Remaining Arc
    final sweepAngle = (remainingSeconds / totalSeconds) * 2 * 3.1415926535;
    final arcPaint = Paint()
      ..color = AppColors.brandMain
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2, // Start at top
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.remainingSeconds != remainingSeconds;
  }
}
