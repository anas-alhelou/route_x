import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/features/home/data/models/attention_item_model.dart';
import 'package:routex_mobile/features/home/data/models/first_day_check_item_model.dart';
import 'package:routex_mobile/features/home/data/models/first_day_step_model.dart';
import 'package:routex_mobile/features/home/data/models/incoming_order_notification_model.dart';
import 'package:routex_mobile/features/home/data/models/next_stop_info_model.dart';
import 'package:routex_mobile/features/home/data/models/today_summary_model.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

class DeliveryDashboardModel extends DeliveryDashboard {
  const DeliveryDashboardModel({
    required super.driverName,
    required super.profileImagePath,
    required super.dateLabel,
    required super.scenario,
    super.today,
    super.nextStop,
    super.attentionItems,
    super.firstDayChecklist,
    super.firstDaySteps,
    super.readyOrderCount,
    super.companyName,
    super.isOffline,
    super.incomingOrderNotification,
  });

  factory DeliveryDashboardModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDashboardModel(
      driverName: json['driverName'] as String? ?? 'Hamza',
      profileImagePath:
          json['profileImagePath'] as String? ?? AppAssets.imgDriverAvatar,
      dateLabel: json['dateLabel'] as String? ?? 'Sunday, 11 October',
      scenario: DeliveryScenario.values.firstWhere(
        (e) => e.name == json['scenario'],
        orElse: () => DeliveryScenario.onRoute,
      ),
      today: json['today'] != null
          ? TodaySummaryModel.fromJson(json['today'] as Map<String, dynamic>)
          : null,
      nextStop: json['nextStop'] != null
          ? NextStopInfoModel.fromJson(json['nextStop'] as Map<String, dynamic>)
          : null,
      attentionItems: (json['attentionItems'] as List<dynamic>?)
              ?.map((e) => AttentionItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      firstDayChecklist: (json['firstDayChecklist'] as List<dynamic>?)
              ?.map((e) =>
                  FirstDayCheckItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      firstDaySteps: (json['firstDaySteps'] as List<dynamic>?)
              ?.map((e) => FirstDayStepModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      readyOrderCount: json['readyOrderCount'] as int? ?? 0,
      companyName: json['companyName'] as String? ?? 'Red Sea Express',
      isOffline: json['isOffline'] as bool? ?? false,
      incomingOrderNotification: json['incomingOrderNotification'] != null
          ? IncomingOrderNotificationModel.fromJson(
              json['incomingOrderNotification'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverName': driverName,
      'profileImagePath': profileImagePath,
      'dateLabel': dateLabel,
      'scenario': scenario.name,
      'today': (today as TodaySummaryModel?)?.toJson(),
      'nextStop': (nextStop as NextStopInfoModel?)?.toJson(),
      'attentionItems': attentionItems
          .map((e) => (e is AttentionItemModel ? e : AttentionItemModel(
                id: e.id,
                type: e.type,
                title: e.title,
                subtitle: e.subtitle,
              )).toJson())
          .toList(),
      'firstDayChecklist': firstDayChecklist
          .map((e) => (e is FirstDayCheckItemModel ? e : FirstDayCheckItemModel(
                id: e.id,
                title: e.title,
                status: e.status,
                isComplete: e.isComplete,
                iconAsset: e.iconAsset,
              )).toJson())
          .toList(),
      'firstDaySteps': firstDaySteps
          .map((e) => (e is FirstDayStepModel ? e : FirstDayStepModel(
                stepNumber: e.stepNumber,
                title: e.title,
                description: e.description,
              )).toJson())
          .toList(),
      'readyOrderCount': readyOrderCount,
      'companyName': companyName,
      'isOffline': isOffline,
      'incomingOrderNotification':
          (incomingOrderNotification as IncomingOrderNotificationModel?)
              ?.toJson(),
    };
  }

  DeliveryDashboard toEntity() => DeliveryDashboard(
        driverName: driverName,
        profileImagePath: profileImagePath,
        dateLabel: dateLabel,
        scenario: scenario,
        today: today,
        nextStop: nextStop,
        attentionItems: attentionItems,
        firstDayChecklist: firstDayChecklist,
        firstDaySteps: firstDaySteps,
        readyOrderCount: readyOrderCount,
        companyName: companyName,
        isOffline: isOffline,
        incomingOrderNotification: incomingOrderNotification,
      );
}
