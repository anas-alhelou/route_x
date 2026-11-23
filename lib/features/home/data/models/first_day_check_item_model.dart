// lib/features/home/data/models/first_day_check_item_model.dart
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

class FirstDayCheckItemModel extends FirstDayCheckItem {
  const FirstDayCheckItemModel({
    required super.id,
    required super.title,
    required super.status,
    super.isComplete,
    super.iconAsset,
  });

  factory FirstDayCheckItemModel.fromJson(Map<String, dynamic> json) {
    return FirstDayCheckItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isComplete: json['isComplete'] as bool? ?? true,
      iconAsset: json['iconAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'isComplete': isComplete,
      'iconAsset': iconAsset,
    };
  }

  FirstDayCheckItem toEntity() => FirstDayCheckItem(
        id: id,
        title: title,
        status: status,
        isComplete: isComplete,
        iconAsset: iconAsset,
      );
}
