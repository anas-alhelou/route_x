// lib/features/route_fleet/presentation/services/proof_camera_service.dart
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of asking the camera to start.
enum ProofCameraStatus { ready, permissionDenied, unavailable }

/// Small abstraction over the device camera so the proof screen can be
/// tested with a fake (no real camera in widget tests).
abstract class ProofCameraService {
  /// Asks for the permission and starts the back camera.
  Future<ProofCameraStatus> start();

  /// The live preview (valid only after [start] returned [ProofCameraStatus.ready]).
  Widget buildPreview();

  /// Takes a photo and returns the saved file path (null on failure).
  Future<String?> takePhoto();

  Future<void> dispose();
}

/// Real implementation backed by the `camera` package.
class DeviceProofCameraService implements ProofCameraService {
  CameraController? _controller;

  @override
  Future<ProofCameraStatus> start() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) return ProofCameraStatus.permissionDenied;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return ProofCameraStatus.unavailable;
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      _controller = controller;
      return ProofCameraStatus.ready;
    } catch (_) {
      return ProofCameraStatus.unavailable;
    }
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    // Fill the whole area (cover) like a native camera screen.
    final size = controller.value.previewSize;
    if (size == null) return CameraPreview(controller);
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          // previewSize is landscape; swap for portrait.
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  @override
  Future<String?> takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || controller.value.isTakingPicture) {
      return null;
    }
    try {
      final file = await controller.takePicture();
      return file.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}
