import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tt_club_ua/config/default.dart';

import '../buttons/GlowingButton.dart';

Future<File?> pickAndCropImage({
  required BuildContext context,
  double? aspectRatio, // 4/3 для авто, 1 для аватарки и т.д.
}) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  final Uint8List imageData = await pickedFile.readAsBytes();
  final cropController = CropController();
  final completer = Completer<File?>();
  final screenWidth = MediaQuery.of(context).size.width;

  showDialog(
    context: context,
    barrierDismissible: true, // ✅ позволяет закрывать по тапу вне окна
    builder: (dialogContext) {
      return WillPopScope(
        onWillPop: () async {
          if (!completer.isCompleted) completer.complete(null);
          return true; // ✅ позволяет выйти через "назад"
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!completer.isCompleted) completer.complete(null);
            Navigator.of(dialogContext).pop(); // ✅ закрываем при тапе вне
          },
          child: Center(
            child: GestureDetector(
              onTap: () {}, // чтобы не срабатывало нажатие внутри окна
              child: Dialog(
                backgroundColor: TTColors.card,
                insetPadding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.85,
                      height: screenWidth * 0.85,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Crop(
                          image: imageData,
                          controller: cropController,
                          aspectRatio: aspectRatio,
                          baseColor: Colors.transparent,
                          maskColor: Colors.black.withOpacity(0.5),
                          cornerDotBuilder: (size, edgeAlignment) =>
                              const DotControl(),
                          onCropped: (croppedData) async {
                            Navigator.of(dialogContext).pop(); // закрываем окно
                            final tempDir = await getTemporaryDirectory();
                            final file = File(
                              '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );
                            await file.writeAsBytes(croppedData);
                            if (!completer.isCompleted)
                              completer.complete(file);
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GlowingButton(
                            // margin: EdgeInsets.only(left: 30,right: 30),
                            margin: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            text: 'Обрізати та зберегти',
                            colorGrowing: Colors.white,
                            onPressed: () => cropController.crop(),
                            // isLoading: _isLoadingSubmit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  // showDialog(
  //   context: context,
  //   barrierDismissible: true,
  //   builder: (_) {
  //     return Dialog(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           SizedBox(
  //             width: 320,
  //             height: 320,
  //             child: Crop(
  //               image: imageData,
  //               controller: cropController,
  //               aspectRatio: aspectRatio, // может быть null
  //               onCropped: (croppedData) async {
  //                 // сохраняем в temp-файл
  //                 final tempDir = await getTemporaryDirectory();
  //                 final file = File(
  //                   '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
  //                 );
  //                 await file.writeAsBytes(croppedData);
  //
  //                 if (!completer.isCompleted) {
  //                   completer.complete(file);
  //                 }
  //
  //                 if (Navigator.of(context).canPop()) {
  //                   Navigator.of(context).pop();
  //                 }
  //               },
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           ElevatedButton(
  //             onPressed: () {
  //               cropController.crop(); // 🔥 запускаем обрезку
  //             },
  //             child: const Text('Обрізати та зберегти'),
  //           ),
  //           const SizedBox(height: 8),
  //         ],
  //       ),
  //     );
  //   },
  // );

  return completer.future;
}
