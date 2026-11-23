// lib/features/orders/presentation/widgets/history/history_format.dart
import 'package:routex_mobile/core/l10n/app_localizations.dart';

import '../../../domain/entities/order_history_entity.dart';

/// `21h 40m`, `4h 05m` — minutes padded so a column of days lines up.
String historyDuration(AppLocalizations l10n, int totalMinutes) =>
    l10n.historyDuration(
      totalMinutes ~/ 60,
      (totalMinutes % 60).toString().padLeft(2, '0'),
    );

/// `9:42` — the unpadded 24-hour form the Orders tab's "Updated" line uses.
String historyClockTime(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

/// The reason in lower case, to sit inside a sentence.
String historyReason(AppLocalizations l10n, DeliveryFailureReason reason) =>
    switch (reason) {
      DeliveryFailureReason.customerNotAnswering => l10n.historyReasonNoAnswer,
      DeliveryFailureReason.addressNotFound => l10n.historyReasonAddress,
      DeliveryFailureReason.refused => l10n.historyReasonRefused,
    };
