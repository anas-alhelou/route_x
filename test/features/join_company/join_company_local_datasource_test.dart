import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/join_company/data/datasources/join_company_local_datasource.dart';
import 'package:routex_mobile/features/join_company/domain/entities/company_review_status.dart';

void main() {
  late JoinCompanyLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = JoinCompanyLocalDataSourceImpl();
  });

  group('JoinCompanyLocalDataSourceImpl - Verification Logic', () {
    test('entering RSX481 throws InvalidCompanyCodeException (J02)', () async {
      expect(
        () => dataSource.verifyCode('RSX481'),
        throwsA(isA<InvalidCompanyCodeException>()),
      );
      // Case-insensitive check
      expect(
        () => dataSource.verifyCode('rsx481'),
        throwsA(isA<InvalidCompanyCodeException>()),
      );
    });

    test('entering KTW210 throws CompanyCodeDisabledException (J03)', () async {
      expect(
        () => dataSource.verifyCode('KTW210'),
        throwsA(isA<CompanyCodeDisabledException>()),
      );
      expect(
        () => dataSource.verifyCode('ktw210'),
        throwsA(isA<CompanyCodeDisabledException>()),
      );
    });

    test('entering RSX482 returns Red Sea Express CompanyModel (J04)', () async {
      final company = await dataSource.verifyCode('RSX482');
      expect(company.name, 'Red Sea Express');
      expect(company.code, 'RSX482');
      expect(company.isActive, true);
    });

    test('entering any other valid 6-char alphanumeric code returns company', () async {
      final company = await dataSource.verifyCode('ABC123');
      expect(company.code, 'ABC123');
      expect(company.isActive, true);
    });

    test('entering code shorter than 6 characters throws InvalidCompanyCodeException', () async {
      expect(
        () => dataSource.verifyCode('RSX48'),
        throwsA(isA<InvalidCompanyCodeException>()),
      );
    });
  });

  group('JoinCompanyLocalDataSourceImpl - Request Flow', () {
    test('sendRequest returns CompanyReviewStatusModel with Under Review step', () async {
      final status = await dataSource.sendRequest('RSX482');
      expect(status.company.name, 'Red Sea Express');
      expect(status.currentStep, CompanyReviewStep.companyReview);
      expect(status.sentTimeFormatted, 'Today, 10:24 AM');
      expect(status.driverName, 'Hamza Barakat');
    });

    test('getStatus returns active request or default mock', () async {
      await dataSource.sendRequest('RSX482');
      final status = await dataSource.getStatus('RSX482');
      expect(status.company.code, 'RSX482');
      // The legacy mock approves on the first status check.
      expect(status.currentStep, CompanyReviewStep.approved);
    });

    test('cancelRequest clears pending request', () async {
      await dataSource.sendRequest('RSX482');
      await dataSource.cancelRequest('RSX482');
      // Should not throw
    });
  });
}
