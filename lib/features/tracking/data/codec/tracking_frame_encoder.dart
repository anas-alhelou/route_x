import 'dart:typed_data';

/// Codec settings. Server and app MUST use identical values.
///
/// The values in [routex] were confirmed by the backend team
/// (south 31.2, west 34.2, scale 1e5, offsetBytes 2, speedStep 0.25,
/// heading on, profile 1) and verified against their sample frame.
class TrackingCodecConfig {
  const TrackingCodecConfig({
    this.south = 31.2,
    this.west = 34.2,
    this.scale = 1e5,
    this.offsetBytes = 2,
    this.speedStep = 0.25,
    this.withHeading = false,
    this.profile = 0,
  }) : assert(offsetBytes == 2 || offsetBytes == 3);

  /// South-west corner of the cheap "box", in degrees.
  final double south;
  final double west;

  /// Units per degree (1e5 ~ 1.1 m).
  final double scale;

  /// Bytes per in-box offset: 2 or 3.
  final int offsetBytes;

  /// Speed resolution in m/s. 0 = speed is not sent.
  final double speedStep;

  /// Whether a heading byte is part of the frame.
  final bool withHeading;

  /// Written in the second header byte (0..255).
  final int profile;

  /// The configuration the RouteX backend uses for POST /tracking/location.
  static const TrackingCodecConfig routex = TrackingCodecConfig(
    south: 31.2,
    west: 34.2,
    scale: 1e5,
    offsetBytes: 2,
    speedStep: 0.25,
    withHeading: true,
    profile: 1,
  );
}

/// One GPS fix.
class TrackingSample {
  const TrackingSample({
    required this.lat,
    required this.lng,
    this.speedMps,
    this.headingDeg,
    this.ageSec = 0,
  });

  final double lat;
  final double lng;

  /// Metres per second (Position.speed). Null/negative = unknown.
  final double? speedMps;

  /// Degrees clockwise from north. Null = unknown.
  final double? headingDeg;

  /// Seconds between the GPS fix and the moment the frame is built.
  final double ageSec;
}

class TrackingFrameException implements Exception {
  TrackingFrameException(this.message);
  final String message;
  @override
  String toString() => 'TrackingFrameException: $message';
}

/// Builds the binary body for `POST /tracking/location`
/// (`application/octet-stream`, max 64 bytes, kind 2 = point without id,
/// identity comes from the Tracking Token).
///
/// Layout: u8 (version<<4 | kind) · u8 profile · varint head ·
/// (uintB dLat · uintB dLon | zigzag lat · zigzag lon) ·
/// [u8 speed] [u8 heading].
/// head = ageSec * F + flags, F = 8 with heading else 4;
/// flags: 1 speed, 2 outside box, 4 heading.
class TrackingFrameEncoder {
  const TrackingFrameEncoder([this.config = TrackingCodecConfig.routex]);

  final TrackingCodecConfig config;

  static const int formatVersion = 1;
  static const int kindPoint = 2;
  static const int maxFrameBytes = 64;
  static const int _maxAgeSec = 4294967296; // 2^32

  /// JavaScript `Math.round` (halves round up), NOT Dart's `round()`.
  int _round(double x) => (x + 0.5).floor();

  void _varint(BytesBuilder b, int n) {
    while (n >= 128) {
      b.addByte((n & 127) | 128);
      n >>= 7;
    }
    b.addByte(n);
  }

  void _zigzag(BytesBuilder b, int n) =>
      _varint(b, n >= 0 ? n * 2 : -n * 2 - 1);

  Uint8List encode(TrackingSample s) {
    if (!(s.lat.isFinite &&
        s.lng.isFinite &&
        s.lat.abs() <= 90 &&
        s.lng.abs() <= 180)) {
      throw TrackingFrameException('bad coordinates');
    }
    final c = config;
    final b = BytesBuilder(copy: false);
    b.addByte((formatVersion << 4) | kindPoint);
    b.addByte(c.profile & 0xff);

    final lat = _round(s.lat * c.scale);
    final lng = _round(s.lng * c.scale);
    final dLat = lat - _round(c.south * c.scale);
    final dLng = lng - _round(c.west * c.scale);
    final maxOffset = (1 << (8 * c.offsetBytes)) - 1;
    final inside =
        dLat >= 0 && dLat <= maxOffset && dLng >= 0 && dLng <= maxOffset;

    final speed = s.speedMps;
    final hasSpeed =
        c.speedStep > 0 && speed != null && speed.isFinite && speed >= 0;
    final heading = s.headingDeg;
    final hasHeading =
        c.withHeading && heading != null && heading.isFinite;

    final flagSpan = c.withHeading ? 8 : 4;
    var age = s.ageSec.isFinite ? s.ageSec.floor() : 0;
    if (age < 0) age = 0;
    if (age > _maxAgeSec) age = _maxAgeSec;

    _varint(
      b,
      age * flagSpan +
          (hasHeading ? 4 : 0) +
          (inside ? 0 : 2) +
          (hasSpeed ? 1 : 0),
    );

    if (inside) {
      for (final v in [dLat, dLng]) {
        for (var i = c.offsetBytes - 1; i >= 0; i--) {
          b.addByte((v >> (8 * i)) & 0xff); // big-endian
        }
      }
    } else {
      _zigzag(b, lat);
      _zigzag(b, lng);
    }

    if (hasSpeed) {
      final v = _round(speed / c.speedStep);
      b.addByte(v > 255 ? 255 : v);
    }
    if (hasHeading) {
      final deg = ((heading % 360) + 360) % 360;
      b.addByte(_round(deg * (256 / 360)) & 0xff);
    }

    final out = b.toBytes();
    if (out.length > maxFrameBytes) {
      throw TrackingFrameException('frame is ${out.length} bytes (> 64)');
    }
    return out;
  }
}
