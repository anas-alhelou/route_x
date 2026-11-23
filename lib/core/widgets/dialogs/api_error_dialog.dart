import 'package:flutter/material.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';

import '../../theme/app_colors.dart';
import '../routex_error_dialog.dart';
import 'error_alert_dialog.dart';
import 'routex_alert_dialog.dart';

/// The one place a failed API call turns into something the user sees.
///
/// Every auth listener used to assemble its own dialog from the failure's raw
/// message, which is how the same request came out under a different headline
/// depending on which screen reported it — and how a timeout or an offline
/// device was announced with the generic "Something went wrong", leaving the
/// user with nothing to act on. Classifying the raw message once, here, keeps
/// the wording and the available actions identical everywhere.
///
/// The rule is deliberately narrow. Only two keys carry information *about the
/// request* rather than *from the server*, and they are the only ones that earn
/// their own headline:
///
///  * [ExceptionMapper.requestTimeoutKey] — the server was reachable and simply
///    did not answer in time.
///  * [NetworkFailure.noConnectionKey] — the request never reached a server.
///
/// Everything else is either one of our own validation keys or a message the
/// backend wrote for this exact failure. Both are shown **verbatim** (our keys
/// are translated first): the server's sentence is the only record of *why* it
/// said no — "Email already registered", "نوع المركبة غير مدعوم" — and
/// replacing it with generic copy is exactly the information loss this dialog
/// exists to prevent.
class ApiErrorDialog extends StatelessWidget {
  const ApiErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  /// Headline, already resolved to localized copy by [show].
  final String title;

  /// Body copy, already localized by [show].
  final String message;

  /// Re-runs the request that failed. `null` hides the retry action.
  final VoidCallback? onRetry;

  /// Presents the dialog, running [onRetry] only once it has been dismissed.
  ///
  /// The retry is deliberately *not* wired to the alert's confirm action: that
  /// handler runs before the dialog pops, so the page would go back into its
  /// loading state while the dialog is still on screen — the overlay would come
  /// up behind it and the user would be left staring at a dialog describing a
  /// request that has already restarted. Awaiting the result instead means the
  /// card is gone before anything changes.
  ///
  /// Without [onRetry] the dialog is the single-action form: an error the user
  /// cannot do anything about should not offer a button that would only fail
  /// the same way.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? confirmLabel,
  }) async {
    if (onRetry == null) {
      await RouteXAlertDialog.show(
        context: context,
        title: title,
        message: message,
        icon: Icons.cancel,
        iconColor: AppColors.iconRed,
        iconBackgroundColor: AppColors.iconWarning,
        confirmLabel: confirmLabel ?? context.tr.done,
      );
      return;
    }

    final retried = await ErrorAlertDialog.show(
      context: context,
      title: title,
      message: message,
    );
    if (retried ?? false) onRetry();
  }

  /// Renders the retry form when there is something to retry, and the
  /// single-action form when there is not.
  @override
  Widget build(BuildContext context) {
    return onRetry != null
        ? ErrorAlertDialog(title: title, message: message)
        : RouteXErrorDialog(title: title, message: message);
  }
}

extension ApiErrorDialogX on BuildContext {
  /// Reports a failed request, choosing the headline and the retry action from
  /// the failure's raw [message].
  ///
  /// [message] is the `Failure.message` the bloc exposed, which is one of:
  ///
  ///  * a key of ours (`err*`) — translated by [translateValidationKey];
  ///  * a sentence from the API's error envelope — shown as written;
  ///  * empty or missing — falls back to `tr.somethingWentWrong`, because an
  ///    empty dialog is worse than a generic one.
  ///
  /// Pass [onRetry] whenever repeating the exact same request could plausibly
  /// work — a timeout, a dropped connection, a server hiccup. Leave it out for
  /// failures that will not change on a second attempt (rejected credentials,
  /// an invalid code, an unsupported vehicle type), where a retry button only
  /// invites the user to fail again.
  /// [confirmLabel] renames the single action of the no-retry form (default
  /// "Done"); it has no effect when [onRetry] is given.
  Future<void> showApiError(
    String? message, {
    VoidCallback? onRetry,
    String? confirmLabel,
  }) {
    final raw = message?.trim() ?? '';

    final String title;
    final String body;
    if (raw == ExceptionMapper.requestTimeoutKey) {
      title = tr.requestTimeoutTitle;
      body = tr.errRequestTimeout;
    } else if (raw == NetworkFailure.noConnectionKey) {
      title = tr.noConnectionTitle;
      body = tr.errNoInternetConnection;
    } else {
      title = tr.errorAlertTitle;
      body = raw.isEmpty ? tr.somethingWentWrong : translateValidationKey(raw);
    }

    return ApiErrorDialog.show(
      context: this,
      title: title,
      message: body,
      onRetry: onRetry,
      confirmLabel: confirmLabel,
    );
  }
}
