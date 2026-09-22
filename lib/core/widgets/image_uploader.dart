import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_color_scheme.dart';
import '../constants/app_text_styles.dart';
import '../services/storage_service.dart';

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
    this.label = 'Image',
    this.initialImageUrl,
    required this.storagePath,
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
    _currentUrl = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(covariant ImageUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      _currentUrl = widget.initialImageUrl;
    }
  }

  Future<void> _pickAndUpload() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        setState(() {
          _errorMessage = 'Could not read file data';
        });
        return;
      }

      setState(() {
        _previewBytes = bytes;
        _isUploading = true;
      });

      final extension = file.extension?.toLowerCase() ?? 'png';
      final contentType = 'image/$extension';
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final fullPath = '${widget.storagePath}/$fileName';

      final storageService = ref.read(storageServiceProvider);
      final downloadUrl = await storageService.uploadImageBytes(
        bytes: bytes,
        path: fullPath,
        contentType: contentType,
      );

      setState(() {
        _currentUrl = downloadUrl;
        _isUploading = false;
      });

      widget.onImageUploaded(downloadUrl);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Upload failed: $e';
      });
    }
  }

  void _manualUrlEntry() {
    final colors = context.colors;
    final controller = TextEditingController(text: _currentUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Text('Enter Image URL / Asset Path', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
        content: TextField(
          controller: controller,
          style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'https://... or assets/jet1.png',
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
    });
    widget.onImageUploaded('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage = _previewBytes != null || (_currentUrl != null && _currentUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
            if (widget.isRequired)
              Text(' *', style: TextStyle(color: colors.primaryRed, fontWeight: FontWeight.bold)),
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
                    child: _previewBytes != null
                        ? Image.memory(
                            _previewBytes!,
                            fit: widget.fit,
                          )
                        : (_currentUrl!.startsWith('http')
                            ? Image.network(
                                _currentUrl!,
                                fit: widget.fit,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(colors),
                              )
                            : Image.asset(
                                _currentUrl!,
                                fit: widget.fit,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(colors),
                              )),
                  ),
                )
              else
                _buildPlaceholder(colors),

              if (_isUploading)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colors.primaryRed),
                        const SizedBox(height: 12),
                        const Text('Uploading image...', style: TextStyle(color: Colors.white)),
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
                          icon: Icon(Icons.upload_file, size: 18, color: colors.textPrimary),
                          onPressed: _pickAndUpload,
                          tooltip: 'Upload File',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        IconButton(
                          icon: Icon(Icons.link, size: 18, color: colors.textPrimary),
                          onPressed: _manualUrlEntry,
                          tooltip: 'Set URL / Asset Path',
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
          const SizedBox(height: 4),
          Text(_errorMessage!, style: TextStyle(color: colors.error, fontSize: 12)),
        ],
        if (_currentUrl != null && _currentUrl!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Path: $_currentUrl',
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
            Text('Click to upload image or drop file', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
            const SizedBox(height: 4),
            Text('PNG, JPG, WEBP up to 10MB', style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
