import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildPlaceholder();
    }

    final url = imageUrl!.trim();

    // Trường hợp 1: Ảnh lưu dạng Base64
    if (url.startsWith('data:image') || (!url.startsWith('http') && url.length > 100)) {
      try {
        final base64Str = url.contains(',') ? url.split(',').last : url;
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    // Trường hợp 2: Ảnh lưu dạng URL (Firebase Storage hoặc web link)
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0E7DD),
      child: const Center(
        child: Icon(Icons.coffee, color: AppColors.primary, size: 28),
      ),
    );
  }
}
