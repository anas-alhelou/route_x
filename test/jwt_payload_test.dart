// test/jwt_payload_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/network/jwt_payload.dart';

void main() {
  // A real `/auth/login` access token, copied verbatim from the live backend.
  // The payload segment is 175 chars, i.e. not a multiple of 4, so decoding it
  // only works if the missing `=` padding is restored — the case most JWT
  // readers get wrong.
  const realToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJzdWIiOiI1Yjg0YWJiZi0zNWJmLTQzODEtOWU5Yy03ZmI2N2M3NGRhZmQi'
      'LCJlbWFpbCI6ImFuYXMuc2guYWxoaWxvQGdtYWlsLmNvbSIsInJvbGUiOiJEUklW'
      'RVIiLCJpYXQiOjE3NjcyMjU2MDAsImV4cCI6MTc2NzIyOTIwMH0'
      '.c2lnbmF0dXJl';

  /// Builds a token with the given claims, signing nothing — the decoder must
  /// not care whether the signature is real, which is also why it must not be
  /// used to make trust decisions. Segments keep their base64url padding.
  String tokenWithPadded(Map<String, dynamic> claims) {
    String segment(Map<String, dynamic> value) =>
        base64Url.encode(utf8.encode(jsonEncode(value)));
    return '${segment({'alg': 'HS256'})}.${segment(claims)}.signature';
  }

  group('JwtPayloadDecoder', () {
    const decoder = JwtPayloadDecoder();

    test('reads the claims of a real access token', () {
      final claims = decoder.decode(realToken);

      expect(claims, isNotNull);
      expect(claims!['sub'], '5b84abbf-35bf-4381-9e9c-7fb67c74dafd');
      expect(claims['email'], 'anas.sh.alhilo@gmail.com');
      expect(claims['role'], 'DRIVER');
      expect(claims['iat'], 1767225600);
      expect(claims['exp'], 1767229200);
    });

    test('accepts a padded as well as an unpadded payload segment', () {
      final claims = {'sub': 'abc', 'role': 'CUSTOMER'};
      // `base64Url.encode` keeps the `=` padding, so this is the padded form...
      final padded = tokenWithPadded(claims);
      // ...and this is the same token with the padding stripped, which is how
      // tokens actually travel.
      final unpadded = padded
          .split('.')
          .map((segment) => segment.replaceAll('=', ''))
          .join('.');

      expect(padded.split('.')[1], contains('='));
      expect(unpadded.split('.')[1], isNot(contains('=')));
      expect(decoder.decode(padded), claims);
      expect(decoder.decode(unpadded), claims);
    });

    test('ignores the header and signature segments', () {
      // Claims are data, not proof: a mangled header/signature still decodes,
      // which is precisely why nothing security-relevant may rely on this.
      final parts = realToken.split('.');
      final mangled = 'not-base64!.${parts[1]}.also-not-base64!';

      expect(decoder.decode(mangled)?['sub'], '5b84abbf-35bf-4381-9e9c-7fb67c74dafd');
    });

    test('returns null for anything that is not a decodable JWT', () {
      expect(decoder.decode(''), isNull);
      expect(decoder.decode('not-a-jwt'), isNull);
      expect(decoder.decode('only.two'), isNull);
      expect(decoder.decode('a.b.c.d'), isNull);
      expect(decoder.decode('header..signature'), isNull);
      // Valid structure, payload segment is not base64url.
      expect(decoder.decode('header.!!!not-base64!!!.signature'), isNull);
      // Valid base64url, but not UTF-8 JSON.
      final notJson = base64Url
          .encode(utf8.encode('plain text, not json'))
          .replaceAll('=', '');
      expect(decoder.decode('header.$notJson.signature'), isNull);
      // Valid JSON, but not an object of claims.
      final jsonList = base64Url.encode(utf8.encode('["a","b"]')).replaceAll('=', '');
      expect(decoder.decode('header.$jsonList.signature'), isNull);
    });
  });
}
