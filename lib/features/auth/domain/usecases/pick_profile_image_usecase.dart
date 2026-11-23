import 'dart:io';
import 'package:routex_mobile/core/services/local/media/image_picker_service.dart';

/// UseCase to pick a profile image, strictly depending on the [ImagePickerService] abstraction.
class PickProfileImageUseCase {
  final ImagePickerService imagePickerService;

  PickProfileImageUseCase({required this.imagePickerService});

  Future<File?> call({required bool isCamera}) async {
    return await imagePickerService.pickImage(isCamera);
  }
}
