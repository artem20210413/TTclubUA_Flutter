import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/config/default.dart';
import '../TTNeumorphicBox.dart';

class PhotoPickerInput extends StatefulWidget {
  final Function(XFile) onImageSelected;
  final XFile? initialImage;
  final double height;

  const PhotoPickerInput({
    super.key,
    required this.onImageSelected,
    this.initialImage,
    this.height = 200,
  });

  @override
  State<PhotoPickerInput> createState() => _PhotoPickerInputState();
}

class _PhotoPickerInputState extends State<PhotoPickerInput> {
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _pickedImage = widget.initialImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = pickedFile);
      widget.onImageSelected(pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTNeumorphicBox(
      radius: 32,
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: _pickImage,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: _pickedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TTColors.input,
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/image_add.svg',
                        fit: BoxFit.scaleDown,
                        colorFilter: ColorFilter.mode(
                          TTColors.text_secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Завантажити фото',
                      style: TTTextStyle.subtitle
                          .copyWith(color: TTColors.text_secondary),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.file(
                    File(_pickedImage!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}
