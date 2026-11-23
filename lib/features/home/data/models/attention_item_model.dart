// lib/features/home/data/models/attention_item_model.dart
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

class AttentionItemModel extends AttentionItem {
  const AttentionItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.subtitle,
  });

  factory AttentionItemModel.fromJson(Map<String, dynamic> json) {
    return AttentionItemModel(
      id: json['id'] as String? ?? '',
      type: AttentionItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttentionItemType.newOrders,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
    };
  }

  AttentionItem toEntity() => AttentionItem(
        id: id,
        type: type,
        title: title,
        subtitle: subtitle,
      );
}
