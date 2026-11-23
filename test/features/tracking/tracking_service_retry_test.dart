import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routex_mobile/features/tracking/data/tracking_remote_data_source.dart';
import 'package:routex_mobile/features/tracking/domain/tracking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRemote implements TrackingRemoteDataSource {
  _FakeRemote(this.failures);

  int failures;
  int opened = 0;
  int ended = 0;

  @override
  Future<String> startSession(String appVersion) async {
    if (failures > 0) {
      failures--;
      throw Exception('offline');
    }
    opened++;
    return 'token';
  }

  @override
  Future<TrackingSendResult> sendFrame({
    required String token,
    required int seq,
    required Uint8List frame,
  }) async => TrackingSendResult.ok;

  @override
  Future<void> endSession() async => ended++;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  TrackingService build(_FakeRemote remote) => TrackingService(
    remote: remote,
    preferences: prefs,
    positionStream: () => const Stream<Position>.empty(),
  );

  test('a failed session is retried until it opens', () {
    fakeAsync((async) {
      final remote = _FakeRemote(2);
      final service = build(remote);

      service.start();
      async.flushMicrotasks();
      expect(service.status.value, TrackingStatus.retrying);

      async.elapse(const Duration(seconds: 15)); // first retry still fails
      expect(service.status.value, TrackingStatus.retrying);

      async.elapse(const Duration(seconds: 30)); // second retry succeeds
      expect(service.status.value, TrackingStatus.active);
      expect(remote.opened, 1);
    });
  });

  test('stop cancels the retries', () {
    fakeAsync((async) {
      final remote = _FakeRemote(100);
      final service = build(remote);

      service.start();
      async.flushMicrotasks();
      service.stop();
      async.flushMicrotasks();

      expect(service.status.value, TrackingStatus.idle);
      async.elapse(const Duration(minutes: 10));
      expect(remote.opened, 0);
      expect(service.status.value, TrackingStatus.idle);
    });
  });
}
