// lib/features/home/data/models/setup_progress_model.dart
import 'package:routex_mobile/features/home/domain/entities/setup_progress.dart';

/// Data-layer shape of [SetupProgress].
///
/// The wire format names the steps as strings rather than as the enum's index,
/// so reordering [SetupStepId] can never silently repoint a step.
class SetupProgressModel extends SetupProgress {
  const SetupProgressModel({required super.steps});

  factory SetupProgressModel.fromJson(Map<String, dynamic> json) {
    final rawSteps = (json['steps'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return SetupProgressModel(
      steps: rawSteps
          .map(
            (step) => SetupStep(
              id: SetupStepId.values.byName(step['id'] as String),
              status: SetupStepStatus.values.byName(step['status'] as String),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'steps': steps
        .map((step) => {'id': step.id.name, 'status': step.status.name})
        .toList(growable: false),
  };
}
