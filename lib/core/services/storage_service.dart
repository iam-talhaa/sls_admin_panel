import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads image bytes directly to Firebase Storage and returns the public download URL.
  /// Falls back to data URI if Firebase Storage fails or is unavailable.
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String path,
    required String contentType,
  }) async {
    try {
      final storageRef = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );

      final uploadTask = await storageRef.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      dev.log('Firebase Storage upload failed, falling back to base64: $e', name: 'StorageService');
      final base64String = base64Encode(bytes);
      return 'data:$contentType;base64,$base64String';
    }
  }

  /// Deletes an image from Firebase Storage if it matches a Firebase Storage URL.
  Future<void> deleteImageByUrl(String url) async {
    if (url.isEmpty || !url.startsWith('http') || !url.contains('firebasestorage')) {
      return;
    }

    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      dev.log('Error deleting image from storage: $e', name: 'StorageService');
    }
  }
}
