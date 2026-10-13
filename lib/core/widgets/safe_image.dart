import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../constants/firebase_asset_urls.dart';

class SafeImage extends StatelessWidget {
  final String imageUrl;
  final Uint8List? bytes;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final BorderRadius? borderRadius;

  const SafeImage({
    super.key,
    required this.imageUrl,
    this.bytes,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (bytes != null && bytes!.isNotEmpty) {
      content = Image.memory(
        bytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (imageUrl.trim().isEmpty) {
      content = _buildPlaceholder();
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      final localAsset = FirebaseAssetUrls.getAssetPath(imageUrl);
      if (localAsset != null) {
        content = Image.asset(
          localAsset,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildNetworkImage(imageUrl),
        );
      } else {
        content = _buildNetworkImage(imageUrl);
      }
    } else if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final decodedBytes = base64Decode(base64Data);
        content = Image.memory(
          decodedBytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (_) {
        content = _buildPlaceholder();
      }
    } else {
      final assetPath = imageUrl.startsWith('assets/') ? imageUrl : 'assets/$imageUrl';
      content = Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.black12,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;
    return Container(
      width: width,
      height: height,
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 22, color: Colors.grey),
      ),
    );
  }
}
