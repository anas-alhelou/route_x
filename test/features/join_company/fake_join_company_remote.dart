import 'package:routex_mobile/features/join_company/data/datasources/join_company_remote_datasource.dart';

/// Stand-in for the backend in widget tests: the first status check after a
/// request answers APPROVED, or REJECTED for the code in [declinedCode].
class FakeJoinCompanyRemote implements JoinCompanyRemoteDataSource {
  FakeJoinCompanyRemote({
    this.declinedCode = 'RSX483',
    this.pendingCode = 'RSX484',
  });

  final String declinedCode;

  /// This code stays PENDING (the "under review" screen keeps showing).
  final String pendingCode;
  String _code = '';

  @override
  Future<JoinByCodeResult?> findCompanyByCode(String code) async => null;

  @override
  Future<JoinByCodeResult> joinByCode(String code) async {
    _code = code.toUpperCase();
    if (_code == 'RSX481') throw const JoinCodeNotFoundException();
    if (_code == 'KTW210') throw const JoinNotAllowedException();
    return JoinByCodeResult(companyId: 'c_$_code', companyName: 'Red Sea Express');
  }

  @override
  Future<DriverMembershipsModel> fetchMemberships() async {
    final declined = _code == declinedCode;
    final pending = _code == pendingCode;
    return DriverMembershipsModel(
      driverName: 'Hamza Barakat',
      memberships: [
        MembershipModel(
          companyId: 'c_$_code',
          companyName: 'Red Sea Express',
          status: declined ? 'REJECTED' : (pending ? 'PENDING' : 'APPROVED'),
          rejectionReason: declined ? 'Not taking drivers right now' : null,
        ),
      ],
    );
  }
}
