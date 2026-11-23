import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_review_status.dart';
import '../../domain/errors/join_company_failures.dart';
import '../../domain/repositories/join_company_repository.dart';
import '../datasources/join_company_remote_datasource.dart';
import '../models/company_model.dart';
import '../models/company_review_status_model.dart';

/// Talks to the real backend.
///
/// There is no "validate code" endpoint: `POST /drivers/join-by-code` both
/// checks the code and creates the PENDING request. So J01 only checks the
/// format locally, and the request is sent when the driver taps "Send request".
// TODO(backend): ask for a validate-code-only endpoint so the company can be
// confirmed before the request is sent.
class JoinCompanyRepositoryImpl implements JoinCompanyRepository {
  JoinCompanyRepositoryImpl(
    this._remote, {
    ExceptionMapper exceptionMapper = const ExceptionMapper(),
    SharedPreferences? preferences,
  }) : _exceptionMapper = exceptionMapper,
       _prefs = preferences;

  final SharedPreferences? _prefs;
  static const String _sentAtKey = 'join_company.sent_at';

  DateTime? _readSentAt() {
    final raw = _prefs?.getString(_sentAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  final JoinCompanyRemoteDataSource _remote;
  final ExceptionMapper _exceptionMapper;

  static final RegExp _codeFormat = RegExp(r'^[A-Z0-9]{6}$');

  String? _companyId;
  CompanyModel? _company;
  DateTime? _sentAt;

  @override
  Future<Either<Failure, Company>> verifyCompanyCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (!_codeFormat.hasMatch(normalized)) {
      return const Left(InvalidCompanyCodeFailure());
    }
    // The name comes from the company search when it can match the code;
    // otherwise it is only known once the request is sent.
    final found = await _remote.findCompanyByCode(normalized);
    return Right(
      CompanyModel(
        id: found?.companyId ?? '',
        name: found?.companyName ?? '',
        code: normalized,
        logoAsset: found?.logoUrl ?? '',
      ),
    );
  }

  @override
  Future<Either<Failure, CompanyReviewStatus>> sendCompanyRequest(
    String companyCode,
  ) async {
    final code = companyCode.trim().toUpperCase();
    try {
      final result = await _remote.joinByCode(code);
      _sentAt = DateTime.now();
      await _prefs?.setString(_sentAtKey, _sentAt!.toIso8601String());
      _remember(result.companyId, result.companyName, code, logo: result.logoUrl);
      return Right(_pendingStatus(driverName: await _driverName()));
    } on JoinCodeNotFoundException {
      return const Left(InvalidCompanyCodeFailure());
    } on JoinNotAllowedException {
      return const Left(CompanyCodeDisabledFailure());
    } on JoinAlreadyRequestedException {
      // Already a member or already pending: show where the request stands.
      return _statusFromServer(code);
    } on DioException catch (e) {
      return Left(_exceptionMapper.map(e));
    } catch (e) {
      return Left(_exceptionMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, CompanyReviewStatus>> getRequestStatus(
    String companyCode,
  ) => _statusFromServer(companyCode.trim().toUpperCase());

  @override
  Future<Either<Failure, void>> cancelCompanyRequest(String companyCode) async {
    // The backend has no cancel endpoint: only forget the local flow state.
    _companyId = null;
    _company = null;
    _sentAt = null;
    await _prefs?.remove(_sentAtKey);
    return const Right(null);
  }

  Future<Either<Failure, CompanyReviewStatus>> _statusFromServer(
    String code,
  ) async {
    try {
      final me = await _remote.fetchMemberships();
      final id = _companyId;
      MembershipModel? m;
      if (id != null) {
        for (final x in me.memberships) {
          if (x.companyId == id) m = x;
        }
      }
      m ??= me.memberships.isEmpty ? null : me.memberships.last;
      if (m == null) return Left(const ServerFailure('No membership found'));

      _remember(m.companyId, m.companyName, code, logo: m.logoUrl);
      final company = _company!;
      switch (m.status) {
        case 'APPROVED':
          return Right(
            CompanyReviewStatusModel(
              company: company,
              currentStep: CompanyReviewStep.approved,
              sentTimeFormatted: _sentLabel(),
              driverName: me.driverName,
            ),
          );
        case 'REJECTED':
        case 'SUSPENDED':
          return Right(
            CompanyReviewStatusModel(
              company: company,
              currentStep: CompanyReviewStep.declined,
              sentTimeFormatted: _sentLabel(),
              driverName: me.driverName,
              declineReason: m.rejectionReason,
            ),
          );
        default:
          return Right(_pendingStatus(driverName: me.driverName));
      }
    } catch (e) {
      return Left(_exceptionMapper.map(e));
    }
  }

  Future<String> _driverName() async {
    try {
      return (await _remote.fetchMemberships()).driverName;
    } catch (_) {
      return '';
    }
  }

  void _remember(String id, String name, String code, {String? logo}) {
    final sameCompany = _company?.id == id;
    _companyId = id;
    _sentAt ??= _readSentAt() ?? DateTime.now();
    _company = CompanyModel(
      id: id,
      name: name,
      code: code,
      logoAsset: logo ?? (sameCompany ? _company?.logoAsset ?? '' : ''),
    );
  }

  CompanyReviewStatusModel _pendingStatus({required String driverName}) {
    return CompanyReviewStatusModel(
      company: _company!,
      currentStep: CompanyReviewStep.companyReview,
      sentTimeFormatted: _sentLabel(),
      driverName: driverName,
    );
  }

  String _sentLabel() {
    final t = _sentAt ?? DateTime.now();
    final now = DateTime.now();
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final mm = t.minute.toString().padLeft(2, '0');
    final time = '$h12:$mm ${t.hour >= 12 ? 'PM' : 'AM'}';
    if (t.year == now.year && t.month == now.month && t.day == now.day) {
      return 'Today, $time';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[t.month - 1]} ${t.day}, $time';
  }
}
