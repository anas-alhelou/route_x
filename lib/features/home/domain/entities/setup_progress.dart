// lib/features/home/domain/entities/setup_progress.dart
import 'package:equatable/equatable.dart';

import 'fleet_request.dart';

/// The three onboarding gates shown in the "Get started" card, in display order.
enum SetupStepId {
  /// Identity is filled in — always complete once the account exists.
  account,

  /// A verified phone number.
  phone,

  /// Membership of at least one fleet.
  fleet,
}

/// Whether a [SetupStepId] is finished, in review, or still outstanding.
enum SetupStepStatus {
  /// Finished; rendered with its label and a brand-coloured dot.
  done,

  /// Outstanding; rendered muted ("To do" or "Next").
  todo,

  /// In review / awaiting dispatcher approval.
  pending,
}

/// Which state of the "Get started" card a [FleetRequestStatus] puts the driver
/// in.
///
/// Lives here rather than in the data source that used to write the checklist,
/// because it is a rule about the driver journey rather than about storage: the
/// checklist has exactly one gate that a request can move, and how each status
/// moves it is the same fact wherever it is applied. Before this mapping
/// existed, four near-identical copies of it sat in one `switch`, each rebuilding
/// the whole step list by hand, and the copies had already drifted — one of them
/// marked a declined request as pending.
extension FleetRequestStepMapping on FleetRequestStatus {
  /// The status of the fleet gate for this request status.
  SetupStepStatus get setupStepStatus => switch (this) {
    // Nothing requested, and a request the dispatcher turned down, both leave the
    // gate outstanding — but for different reasons. The design draws them the
    // same way, so the UI cannot tell them apart and neither does this mapping.
    FleetRequestStatus.none || FleetRequestStatus.declined =>
      SetupStepStatus.todo,
    FleetRequestStatus.pending => SetupStepStatus.pending,
    FleetRequestStatus.approved => SetupStepStatus.done,
  };
}

/// One gate of the "Get started" card.
class SetupStep extends Equatable {
  const SetupStep({required this.id, required this.status});

  final SetupStepId id;
  final SetupStepStatus status;

  @override
  List<Object?> get props => [id, status];
}

/// How far the driver has got through the setup checklist.
class SetupProgress extends Equatable {
  const SetupProgress({required this.steps});

  /// Always three entries, in [SetupStepId] declaration order.
  final List<SetupStep> steps;

  /// Number of finished steps — drives the card's "2 of 3 done" meta line.
  int get completedCount =>
      steps.where((s) => s.status == SetupStepStatus.done).length;

  /// Whether any step is pending dispatcher approval.
  bool get hasPendingStep =>
      steps.any((s) => s.status == SetupStepStatus.pending);

  /// Returns a copy with the fleet gate set to [status], leaving the account and
  /// phone gates exactly as they were.
  ///
  /// The only step a fleet request can move: identity and phone number are
  /// settled by other parts of onboarding, so a request must never rewrite them.
  /// Rebuilding the list by hand at each call site is what previously let one
  /// transition quietly drop a step.
  SetupProgress withFleetStatus(SetupStepStatus status) {
    return SetupProgress(
      steps: [
        for (final step in steps)
          if (step.id == SetupStepId.fleet)
            SetupStep(id: SetupStepId.fleet, status: status)
          else
            step,
      ],
    );
  }

  @override
  List<Object?> get props => [steps];
}
