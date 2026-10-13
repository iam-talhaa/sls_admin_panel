import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../theme/app_color_scheme.dart';
import '../constants/app_text_styles.dart';
import '../constants/firebase_asset_urls.dart';
import 'safe_image.dart';

class ImageUploader extends ConsumerStatefulWidget {
  final String label;
  final String? initialImageUrl;
  final String storagePath;
  final ValueChanged<String> onImageUploaded;
  final bool isRequired;
  final double? height;
  final double? width;
  final BoxFit fit;

  const ImageUploader({
    super.key,
    this.label = 'Image (Optional)',
    this.initialImageUrl,
    this.storagePath = '',
    required this.onImageUploaded,
    this.isRequired = false,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  ConsumerState<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends ConsumerState<ImageUploader> {
  String? _currentUrl;
  Uint8List? _previewBytes;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialImageUrl;
    _currentUrl = (initial != null && initial.isNotEmpty)
        ? FirebaseAssetUrls.getUrl(initial)
        : initial;
  }

  @override
  void didUpdateWidget(covariant ImageUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      final initial = widget.initialImageUrl;
      final resolved = (initial != null && initial.isNotEmpty)
          ? FirebaseAssetUrls.getUrl(initial)
          : initial;
      _currentUrl = resolved;
      if (resolved != null && resolved.isNotEmpty) {
        _previewBytes = null;
      }
    }
  }


  List<String> _getPresetsForCategory() {
    final path = widget.storagePath.toLowerCase();
    if (path.contains('fleet') || path.contains('jet')) {
      return const ['assets/jet1.png', 'assets/jet2.png', 'assets/jet3.png', 'assets/chopper.png'];
    } else if (path.contains('blog')) {
      return const ['assets/blog3.png', 'assets/blog4.png', 'assets/blog5.png', 'assets/blog6.png', 'assets/blog7.png', 'assets/blog8.png', 'assets/blog9.png', 'assets/blog10.png', 'assets/blog11.png'];
    } else if (path.contains('dest')) {
      return const ['assets/des1.jpg', 'assets/des2.png', 'assets/des3.png', 'assets/des4.png', 'assets/des5.png', 'assets/des6.png', 'assets/des7.png', 'assets/des8.png'];
    } else if (path.contains('concierge')) {
      return const ['assets/hotelBooking.png', 'assets/conciergeService.png', 'assets/concierge2.png', 'assets/concierge3.png', 'assets/concierge4.png', 'assets/concierge5.png'];
    }
    return const ['assets/jet1.png', 'assets/des1.jpg', 'assets/blog3.png', 'assets/hotelBooking.png', 'assets/slslogo.png'];
  }

  Future<void> _pickAndUpload() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        setState(() {
          _errorMessage = 'Could not read file data. Please select another file.';
        });
        return;
      }

      // Show immediate local preview and enter uploading state
      setState(() {
        _previewBytes = bytes;
        _isUploading = true;
        _errorMessage = null;
      });

      // Upload directly to Firebase Storage
      final folder = widget.storagePath.isNotEmpty ? widget.storagePath : 'uploads';
      final downloadUrl = await ref.read(storageServiceProvider).uploadImageBytes(
        bytes: bytes,
        path: folder,
        fileName: file.name,
      );

      if (!mounted) return;

      setState(() {
        _currentUrl = downloadUrl;
        _isUploading = false;
        _errorMessage = null;
      });

      widget.onImageUploaded(downloadUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Image successfully uploaded to Firebase Storage!'),
            ],
          ),
          backgroundColor: Color(0xFF22C55E),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      dev.log('Firebase Storage upload error: $e', name: 'ImageUploader');
      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _errorMessage = 'Firebase Storage upload failed: $e';
      });

      _showUploadErrorDialog(e.toString());
    }
  }

  void _showUploadErrorDialog(String error) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.warning, size: 24),
            const SizedBox(width: 10),
            Text('Firebase Storage Upload', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The image could not be uploaded to Firebase Storage:\n$error',
              style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceElevatedHigher,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Troubleshooting checklist:', style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('1. Go to Firebase Console -> Storage and verify Storage is enabled.', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  Text('2. Ensure Storage Rules allow read/write.', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  Text('3. You can still select an image preset or enter an external image URL below.', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPresetPicker();
            },
            child: const Text('Pick Preset'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _manualUrlEntry();
            },
            child: const Text('Enter URL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primaryRed, foregroundColor: Colors.white),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPresetPicker() {
    final colors = context.colors;
    final presets = _getPresetsForCategory();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Text('Select Preset Image', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
        content: SizedBox(
          width: 480,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((assetPath) {
              final firebaseUrl = FirebaseAssetUrls.getUrl(assetPath);
              final isSelected = _currentUrl == firebaseUrl || _currentUrl == assetPath;
              return InkWell(
                onTap: () {
                  setState(() {
                    _currentUrl = firebaseUrl;
                    _previewBytes = null;
                    _errorMessage = null;
                  });
                  widget.onImageUploaded(firebaseUrl);
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? colors.primaryRed : colors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(assetPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.image, color: colors.textSecondary))),
                      if (isSelected)
                        Container(
                          color: colors.primaryRed.withOpacity(0.3),
                          child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 20)),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: colors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _manualUrlEntry() {
    final colors = context.colors;
    final controller = TextEditingController(text: _currentUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Text('Enter Image URL', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
        content: TextField(
          controller: controller,
          style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'https://...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() {
                  _currentUrl = val;
                  _previewBytes = null;
                  _errorMessage = null;
                });
                widget.onImageUploaded(val);
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _clearImage() {
    setState(() {
      _currentUrl = null;
      _previewBytes = null;
      _errorMessage = null;
    });
    widget.onImageUploaded('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage = _previewBytes != null || (_currentUrl != null && _currentUrl!.isNotEmpty);
    final isFirebaseUrl = _currentUrl != null && _currentUrl!.contains('firebasestorage');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
            if (widget.isRequired)
              Text(' *', style: TextStyle(color: colors.primaryRed, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isFirebaseUrl)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done, size: 13, color: colors.success),
                    const SizedBox(width: 4),
                    Text('Stored in Firebase', style: TextStyle(color: colors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: widget.height ?? 180,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _errorMessage != null ? colors.error : colors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: SafeImage(
                      imageUrl: _currentUrl ?? '',
                      bytes: _previewBytes,
                      fit: widget.fit,
                    ),
                  ),
                )
              else
                _buildPlaceholder(colors),

              if (_isUploading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colors.primaryRed),
                        const SizedBox(height: 12),
                        const Text(
                          'Uploading image to Firebase...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Storing in Firebase Storage bucket',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

              // Action buttons overlay
              if (!_isUploading)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevatedHigher.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.cloud_upload_outlined, size: 19, color: colors.primaryRed),
                          onPressed: _pickAndUpload,
                          tooltip: 'Upload to Firebase Storage',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        IconButton(
                          icon: Icon(Icons.collections_outlined, size: 18, color: colors.textPrimary),
                          onPressed: _showPresetPicker,
                          tooltip: 'Select Preset Image',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        IconButton(
                          icon: Icon(Icons.link, size: 18, color: colors.textPrimary),
                          onPressed: _manualUrlEntry,
                          tooltip: 'Set Direct Image URL',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        if (hasImage)
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                            onPressed: _clearImage,
                            tooltip: 'Remove Image',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: colors.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: colors.error, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (_currentUrl != null && _currentUrl!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Saved URL: $_currentUrl',
            style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder(dynamic colors) {
    return InkWell(
      onTap: _pickAndUpload,
      borderRadius: BorderRadius.circular(9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 38, color: colors.textSecondary.withOpacity(0.7)),
            const SizedBox(height: 10),
            Text('Click to upload image to Firebase', style: AppTextStyles.subtitle.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Uploads directly to Firebase Storage bucket (PNG, JPG, WEBP)', style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
