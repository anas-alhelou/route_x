// lib/core/network/jwt_payload.dart
import 'dart:convert';

/// Reads the claims out of a JSON Web Token.
///
/// **This does not verify the signature, and must not be used to make a trust
/// decision.** Decoding is purely for reading values the app already *has* — the
/// token came from the backend over TLS in response to credentials we supplied,
/// so the claims are a local convenience (e.g. showing who is signed in), not an
/// authority. Anything security-relevant (authorisation, roles used to unlock a
/// feature, token validity) is the server's call, enforced on its endpoints.
///
/// Lives next to [ApiEnvelope] because it is the same kind of helper: parsing
/// part of a wire format without leaking `FormatException`s to callers.
class JwtPayloadDecoder {
  const JwtPayloadDecoder();

  /// Returns the claims of [token], or `null` when it is not a decodable JWT.
  ///
  /// A `null` result is deliberately not an exception: "this string is not a
  /// JWT" is an expected input for callers that accept several token shapes,
  /// and it lets them decide whether the absence is a hard contract violation
  /// (throw) or just a missing optional source.
  Map<String, dynamic>? decode(String token) {
    // A JWS compact serialization is `header.payload.signature`. The header and
    // signature are not read; only the middle segment holds claims.
    final segments = token.split('.');
    if (segments.length != 3) return null;

    final payloadSegment = segments[1];
    if (payloadSegment.isEmpty) return null;

    try {
      // `normalize` accepts both the padded (`eyJ...=`) and unpadded (`eyJ...`)
      // forms and fixes the length for us — base64url decoders reject a payload
      // whose length is not a multiple of 4, and JWTs are routinely sent
      // without the `=` padding.
      final bytes = base64Url.decode(base64Url.normalize(payloadSegment));
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      // Not valid base64url, not valid UTF-8, or not valid JSON.
      return null;
    }
  }
}
