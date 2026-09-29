import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/db/repositories.dart';
import '../../core/theme/app_theme.dart';

/// 图片选择 + 本地保存，返回持久路径
Future<String?> pickAndSaveImage({bool fromCamera = false}) async {
  final picker = ImagePicker();
  final XFile? file = fromCamera
      ? await picker.pickImage(source: ImageSource.camera, imageQuality: 80)
      : await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (file == null) return null;
  return Repositories.saveImage(file.path);
}

/// 图片显示组件（带删除）
class ImageField extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const ImageField({super.key, required this.imagePath, required this.onPick, this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('添加图片', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(imagePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

/// 列表里的缩略图
class ThumbImage extends StatelessWidget {
  final String? imagePath;
  final double size;

  const ThumbImage({super.key, this.imagePath, this.size = 44});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(File(imagePath!), width: size, height: size, fit: BoxFit.cover),
    );
  }
}
