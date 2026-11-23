import 'package:routex_mobile/core/errors/failures.dart';

/// Emitted when a company code is not found in the system (J02).
class InvalidCompanyCodeFailure extends Failure {
  const InvalidCompanyCodeFailure([super.message = 'Invalid company code']);
}

/// Emitted when a company code exists but has been turned off / disabled (J03).
class CompanyCodeDisabledFailure extends Failure {
  const CompanyCodeDisabledFailure([super.message = 'Company code turned off']);
}
