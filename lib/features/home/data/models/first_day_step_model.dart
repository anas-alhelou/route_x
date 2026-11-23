// lib/features/home/data/models/first_day_step_model.dart
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

class FirstDayStepModel extends FirstDayStep {
  const FirstDayStepModel({
    required super.stepNumber,
    required super.title,
    required super.description,
  });

  factory FirstDayStepModel.fromJson(Map<String, dynamic> json) {
    return FirstDayStepModel(
      stepNumber: json['stepNumber'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
    };
  }

  FirstDayStep toEntity() => FirstDayStep(
        stepNumber: stepNumber,
        title: title,
        description: description,
      );
}
