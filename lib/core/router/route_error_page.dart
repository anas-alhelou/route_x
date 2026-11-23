import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr.routeErrorTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(context.tr.routeNotFound),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.go(RoutersName.login),
                child: Text(context.tr.continueToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
