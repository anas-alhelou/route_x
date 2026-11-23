import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/tracking/data/codec/tracking_frame_encoder.dart';

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join(' ');

void main() {
  // Golden vectors produced by running the reference implementation, using
  // the library defaults (profile 0, no heading) so they stay independent of
  // the RouteX configuration.
  const enc = TrackingFrameEncoder(TrackingCodecConfig());

  test('RouteX backend sample frame (01-valid-gaza-city.bin)', () {
    // Backend config: south 31.2, west 34.2, scale 1e5, offsetBytes 2,
    // speedStep 0.25, heading on, profile 1.
    // Message: lat 31.5017, lon 34.4668, speed 8, heading 90, ageSec 0.
    // The sample file received by chat was damaged by a UTF-8 conversion
    // (0xDA became EF BF BD); the intact frame is 9 bytes.
    const routex = TrackingFrameEncoder(); // defaults to TrackingCodecConfig.routex
    final out = routex.encode(const TrackingSample(
      lat: 31.5017,
      lng: 34.4668,
      speedMps: 8,
      headingDeg: 90,
      ageSec: 0,
    ));
    expect(hex(out), '12 01 05 75 da 68 38 20 40');
    expect(out.length, 9);
  });

  test('A: point without speed is 7 bytes', () {
    final out = enc.encode(const TrackingSample(
      lat: 31.51234567891234,
      lng: 34.45678912345678,
      ageSec: 3,
    ));
    expect(hex(out), '12 00 0c 7a 03 64 4f');
  });

  test('B: speed 8.33 and age 3.9 (truncated to 3)', () {
    final out = enc.encode(const TrackingSample(
      lat: 31.51234567891234,
      lng: 34.45678912345678,
      speedMps: 8.33,
      ageSec: 3.9,
    ));
    expect(hex(out), '12 00 0d 7a 03 64 4f 21');
  });

  test('D: point outside the box uses zigzag absolute units', () {
    final out = enc.encode(const TrackingSample(lat: 31.9, lng: 35.2));
    expect(hex(out), '12 00 02 e0 b3 85 03 80 d8 ad 03');
  });

  test('E: heading enabled, profile 7', () {
    const e = TrackingFrameEncoder(
      TrackingCodecConfig(withHeading: true, profile: 7),
    );
    final out = e.encode(const TrackingSample(
      lat: 31.5,
      lng: 34.4,
      speedMps: 10,
      headingDeg: 271,
      ageSec: 3,
    ));
    expect(hex(out), '12 07 1d 75 30 4e 20 28 c1');
  });

  test('rejects bad coordinates', () {
    expect(
      () => enc.encode(const TrackingSample(lat: double.nan, lng: 34)),
      throwsA(isA<TrackingFrameException>()),
    );
    expect(
      () => enc.encode(const TrackingSample(lat: 91, lng: 34)),
      throwsA(isA<TrackingFrameException>()),
    );
  });

  test('negative speed is omitted, frames never exceed 64 bytes', () {
    final out = enc.encode(const TrackingSample(
      lat: 31.5,
      lng: 34.4,
      speedMps: -1,
      ageSec: 1e9,
    ));
    expect(out.length <= TrackingFrameEncoder.maxFrameBytes, isTrue);
  });
}
