import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class ProofOfDeliveryData extends Equatable {
  const ProofOfDeliveryData({
    this.photoPath,
    this.signaturePngBytes,
    required this.signerName,
    this.cantSignReasonCode,
    this.isPhotoOnly = false,
    this.requiresSignature = false,
  });

  final String? photoPath;
  final Uint8List? signaturePngBytes;
  final String signerName;
  final String? cantSignReasonCode;
  final bool isPhotoOnly;
  final bool requiresSignature;

  ProofOfDeliveryData copyWith({
    String? photoPath,
    Uint8List? signaturePngBytes,
    String? signerName,
    String? cantSignReasonCode,
    bool? isPhotoOnly,
    bool? requiresSignature,
  }) {
    return ProofOfDeliveryData(
      photoPath: photoPath ?? this.photoPath,
      signaturePngBytes: signaturePngBytes ?? this.signaturePngBytes,
      signerName: signerName ?? this.signerName,
      cantSignReasonCode: cantSignReasonCode ?? this.cantSignReasonCode,
      isPhotoOnly: isPhotoOnly ?? this.isPhotoOnly,
      requiresSignature: requiresSignature ?? this.requiresSignature,
    );
  }

  @override
  List<Object?> get props => [
        photoPath,
        signaturePngBytes,
        signerName,
        cantSignReasonCode,
        isPhotoOnly,
        requiresSignature,
      ];
}
