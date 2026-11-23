import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/errors/exceptions.dart';
import 'package:routex_mobile/features/auth/data/models/verify_reset_otp_response_model.dart';

void main() {
  group('VerifyResetOtpResponseModel', () {
    test('parses valid resetToken', () {
      final m = VerifyResetOtpResponseModel.fromJson({
        'resetToken': 'abc123',
        'message': 'ok',
      });
      expect(m.resetToken, 'abc123');
    });

    test('throws when resetToken missing', () {
      expect(
        () => VerifyResetOtpResponseModel.fromJson({'message': 'ok'}),
        throwsA(isA<IncompleteAuthResponseException>()),
      );
    });

    test('throws when resetToken empty', () {
      expect(
        () => VerifyResetOtpResponseModel.fromJson({'resetToken': '  '}),
        throwsA(isA<IncompleteAuthResponseException>()),
      );
    });

    test('ignores flat tokens and user', () {
      final m = VerifyResetOtpResponseModel.fromJson({
        'resetToken': 'tok',
        'accessToken': 'a',
        'refreshToken': 'r',
        'user': {'id': 'u'},
      });
      expect(m.resetToken, 'tok');
    });
  });
}
