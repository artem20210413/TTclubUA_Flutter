import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../Storage/Search/ImageUrlDto.dart';
import 'ConfirmAndRun.dart';

class GoodsImagesEditor extends StatefulWidget {
  final List<ImageUrlDto> images;
  final VoidCallback onAdd;
  final Color accentColor;
  final Function(ImageUrlDto img, int index)? onDelete;

  const GoodsImagesEditor({
    super.key,
    required this.images,
    required this.onAdd,
    this.accentColor = Colors.white,
    this.onDelete,
  });

  @override
  State<GoodsImagesEditor> createState() => _GoodsImagesEditorState();
}

class _GoodsImagesEditorState extends State<GoodsImagesEditor> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length + 1, // + кнопка добавления
        itemBuilder: (_, index) {
          if (index == widget.images.length) return _buildAddButton();

          return _buildPhotoItem(widget.images[index], index);
        },
      ),
    );
  }

  Widget _buildPhotoItem(ImageUrlDto img, int index) {
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
              image: img.networkImage,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ❌ кнопка удаления
        if (widget.onDelete != null)
          Positioned(
            top: 4,
            right: 16,
            child: GestureDetector(
              onTap: () => ConfirmAndRun(
                context: context,
                action: () async {
                  widget.onDelete!(img, index);
                },
                dialogTitle: 'Видалити зображення?',
                dialogMessage: 'Ви дійсно хочете видалити зображення?',
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: widget.onAdd,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: TTColors.card,
          border: Border.all(color: widget.accentColor),
        ),
        child: Center(
          child: Icon(Icons.add_a_photo,
              color: widget.accentColor.withOpacity(0.7), size: 32),
        ),
      ),
    );
  }
}
