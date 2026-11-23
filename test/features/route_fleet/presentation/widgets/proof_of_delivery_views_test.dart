// test/features/route_fleet/presentation/widgets/proof_of_delivery_views_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/presentation/services/proof_camera_service.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/delivery_camera_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/check_photo_view.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/delivery_illustration_view.dart';

class FakeProofCameraService implements ProofCameraService {
  FakeProofCameraService({this.status = ProofCameraStatus.ready, this.photo = '/tmp/photo.jpg'});

  final ProofCameraStatus status;
  final String? photo;
  int takeCount = 0;

  @override
  Future<ProofCameraStatus> start() async => status;

  @override
  Widget buildPreview() => const SizedBox.expand(key: Key('fake-camera-preview'));

  @override
  Future<String?> takePhoto() async {
    takeCount++;
    return photo;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapCamera(ProofCameraService camera, {ValueChanged<String>? onShutter, VoidCallback? onClose}) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DeliveryCameraView(
            stopNumber: 1,
            customerName: 'Omar Haddad',
            doorNumber: '12',
            requiresSignature: false,
            cameraService: camera,
            onCloseTapped: onClose ?? () {},
            onShutterTapped: onShutter ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('DeliveryCameraView shows the live camera and returns the photo path on shutter', (tester) async {
    final camera = FakeProofCameraService();
    String? taken;

    await tester.pumpWidget(wrapCamera(camera, onShutter: (p) => taken = p));
    await tester.pump(); // camera started

    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
    expect(find.byType(DeliveryIllustrationView), findsNothing);
    expect(find.text('Stop 1 · Omar Haddad'), findsOneWidget);

    await tester.tap(find.byType(GestureDetector).last);
    await tester.pump();
    await tester.pump();

    expect(camera.takeCount, 1);
    expect(taken, '/tmp/photo.jpg');
  });

  testWidgets('DeliveryCameraView falls back to the illustration when the permission is denied', (tester) async {
    final camera = FakeProofCameraService(status: ProofCameraStatus.permissionDenied);
    String? taken;

    await tester.pumpWidget(wrapCamera(camera, onShutter: (p) => taken = p));
    await tester.pump();

    expect(find.byType(DeliveryIllustrationView), findsOneWidget);
    expect(find.text('Allow camera access to take the photo'), findsOneWidget);

    // The shutter does not produce a photo without the camera.
    await tester.tap(find.byType(GestureDetector).last);
    await tester.pump();
    expect(camera.takeCount, 0);
    expect(taken, isNull);
  });

  testWidgets('CheckPhotoView renders primary action label based on requiresSignature', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CheckPhotoView(
              doorNumber: '12',
              requiresSignature: false,
              onRetakeTapped: () {},
              onPrimaryActionTapped: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Use photo'), findsOneWidget);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CheckPhotoView(
              doorNumber: '12',
              requiresSignature: true,
              onRetakeTapped: () {},
              onPrimaryActionTapped: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Next: signature'), findsOneWidget);
  });

  testWidgets('DeliveryIllustrationView smoke test renders without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 440,
            child: DeliveryIllustrationView(doorNumber: '12', isFullFrame: false),
          ),
        ),
      ),
    );

    expect(find.byType(DeliveryIllustrationView), findsOneWidget);
  });
}
