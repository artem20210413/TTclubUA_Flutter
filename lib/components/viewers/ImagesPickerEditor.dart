import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagesPickerEditor extends StatefulWidget {
  final List<XFile> images;
  final Color accentColor;
  final int maxImages;
  final ValueChanged<List<XFile>> onChanged;

  const ImagesPickerEditor({
    super.key,
    required this.images,
    required this.accentColor,
    required this.onChanged,
    this.maxImages = 5,
  });

  @override
  State<ImagesPickerEditor> createState() => _ImagesPickerEditorState();
}

class _ImagesPickerEditorState extends State<ImagesPickerEditor> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    final updated = List<XFile>.from(widget.images)
      ..addAll(picked);

    widget.onChanged(updated.take(widget.maxImages).toList());
  }

  void _removeImage(int index) {
    final updated = List<XFile>.from(widget.images)
      ..removeAt(index);

    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length +
            (widget.images.length < widget.maxImages ? 1 : 0),
        itemBuilder: (_, index) {
          if (index == widget.images.length) {
            return _buildAddButton();
          }

          return _buildPhotoItem(widget.images[index], index);
        },
      ),
    );
  }

  Widget _buildPhotoItem(XFile image, int index) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[900],
            image: DecorationImage(
              image: FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ❌ кнопка удаления
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addImages,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          border: Border.all(color: widget.accentColor),
        ),
        child: Center(
          child: Icon(
            Icons.add_a_photo,
            color: widget.accentColor.withOpacity(0.7),
            size: 32,
          ),
        ),
      ),
    );
  }
}
