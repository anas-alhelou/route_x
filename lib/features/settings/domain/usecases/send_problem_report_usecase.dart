// lib/features/settings/domain/usecases/send_problem_report_usecase.dart
import '../repositories/settings_repository.dart';

/// Sends a problem report: its [category] key, the driver's [description],
/// optional screenshot file paths and, if allowed, device details. Resolves to
/// the report reference (e.g. `RPT-2291`) the driver can quote to support.
class SendProblemReportUseCase {
  const SendProblemReportUseCase(this._repository);
  final SettingsRepository _repository;

  Future<String> call({
    required String category,
    required String description,
    List<String> screenshotPaths = const [],
    bool includeDeviceDetails = true,
  }) =>
      _repository.sendProblemReport(
        category: category,
        description: description.trim(),
        screenshotPaths: screenshotPaths,
        includeDeviceDetails: includeDeviceDetails,
      );
}
