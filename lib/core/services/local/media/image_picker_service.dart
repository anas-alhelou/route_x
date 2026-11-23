import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Abstract service to handle picking images from device storage or camera.
abstract class ImagePickerService {
  Future<File?> pickImage(bool fromCamera);
}

/// Concrete implementation of [ImagePickerService] using the `image_picker` package.
class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImage(bool fromCamera) async {
    final XFile? xFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }
}
