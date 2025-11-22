import 'package:cloud_firestore/cloud_firestore.dart';

class StudyMaterial {
  String? id;
  String uid;
  String fileName;
  String fileUrl;
  String fileType;
  String? hash;
  String? publicId;
  Timestamp createdAt;

  StudyMaterial({
    this.id,
    required this.uid,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.hash,
    this.publicId,
    required this.createdAt,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json, String id) {
    return StudyMaterial(
      id: id,
      uid: json['uid'] ?? '',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? 'unknown',
      hash: json['hash'],
      publicId: json['publicId'],
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'hash': hash,
      'publicId': publicId,
      'createdAt': createdAt,
    };
  }
}
