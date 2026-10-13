import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Determines the MIME content type from file name or extension.
  String getContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    return 'image/jpeg';
  }

  /// Sanitizes folder and file names for Firebase Storage paths.
  String sanitizePath(String path) {
    return path.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_\-\/]'), '_');
  }

  /// Uploads image bytes directly to Firebase Storage and returns the public download URL.
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String path,
    String? fileName,
    String? contentType,
  }) async {
    final name = fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final mime = contentType ?? getContentType(name);
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';

    // Construct a sanitized, unique path
    String fullPath;
    final sanitizedFolder = sanitizePath(path).replaceAll(RegExp(r'\/+$'), '');
    if (sanitizedFolder.isEmpty) {
      fullPath = 'uploads/${DateTime.now().millisecondsSinceEpoch}_${sanitizePath(name)}';
    } else if (sanitizedFolder.endsWith('.$ext')) {
      fullPath = sanitizedFolder;
    } else {
      final safeName = sanitizePath(name);
      fullPath = '$sanitizedFolder/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    }

    final metadata = SettableMetadata(
      contentType: mime,
      cacheControl: 'public, max-age=31536000',
      customMetadata: {
        'uploadedAt': DateTime.now().toIso8601String(),
        'originalName': name,
      },
    );

    // Attempt 1: Upload to default Firebase Storage instance
    try {
      dev.log('Uploading ${bytes.length} bytes to Firebase Storage at $fullPath...', name: 'StorageService');
      final storageRef = _storage.ref().child(fullPath);
      final uploadTask = await storageRef.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      dev.log('Firebase Storage upload succeeded: $downloadUrl', name: 'StorageService');
      return downloadUrl;
    } catch (e) {
      dev.log('Default storage bucket upload error: $e. Retrying with explicit bucket...', name: 'StorageService');

      // Attempt 2: Explicit bucket if default app had misconfigured bucket reference
      try {
        final bucket = Firebase.app().options.storageBucket ?? 'swissproject-33b18.firebasestorage.app';
        final storageWithBucket = FirebaseStorage.instanceFor(bucket: bucket);
        final ref2 = storageWithBucket.ref().child(fullPath);
        final uploadTask2 = await ref2.putData(bytes, metadata);
        final downloadUrl2 = await uploadTask2.ref.getDownloadURL();
        dev.log('Explicit bucket ($bucket) upload succeeded: $downloadUrl2', name: 'StorageService');
        return downloadUrl2;
      } catch (err2) {
        dev.log('Firebase Storage upload failed: $err2', name: 'StorageService');
        rethrow;
      }
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
      dev.log('Deleted image from storage: $url', name: 'StorageService');
    } catch (e) {
      dev.log('Error deleting image from storage: $e', name: 'StorageService');
    }
  }
}
