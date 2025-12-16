import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Storage/Cache/AccentColorCache.dart';
import '../../../Storage/UserStorage.dart';
import '../../../api/routs/suggestions.dart';
import '../../../components/TTNeumorphicBox.dart';
import '../../../components/buttons/GlowingButton.dart';
import '../../../components/generalModule.dart';
import '../../../components/inputs/BigTextInput.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../components/viewers/ImagesPickerEditor.dart';
import '../../../config/default.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  Color accentColor = AccentColorCache.accentColor;

  // final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  bool isLoading = false;

  TextEditingController descriptionController = new TextEditingController();

  Future<void> _sendFeedback() async {
    final description = descriptionController.text.trim();

    if (description.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Опис не може бути порожнім')),
      // );
      MessageModule(
        context,
        'Опис не може бути порожнім',
        MessageType.information,
      );
      return;
    }

    if (description.length < 10) {
      MessageModule(
        context,
        'Опис занадто короткий (мінімум 10 символів)',
        MessageType.information,
      );
      return;
    }

    if (description.length > 500) {
      MessageModule(
        context,
        'Опис занадто довгий (максимум 500 символів)',
        MessageType.information,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await UserStorage.getToken();

      final response = await SEND_SUGGESTIONS(
        token!,
        _images,
        description,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        descriptionController.clear();
        _images.clear();

        MessageModule(
          context,
          'Дякуємо за відгук! 🙌',
          MessageType.information,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Дякуємо за відгук! 🙌')),
        // );
      } else {
        MessageModule(
          context,
          'Помилка: ${response.statusCode}',
          MessageType.error,
        );
      }
    } catch (e) {

      MessageModule(
        context,
        'Помилка відправки: $e',
        MessageType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = AccentColorCache.accentColor;

    return TTScaffold(
      title: 'Покращення додатку',
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 0, left: 24, right: 16),
        child: Column(
          children: [
            TTNeumorphicBox(
              child: Column(
                children: [
                  Text(
                    'Разом робимо додаток кращим!',
                    style: TTTextStyle.title18.copyWith(
                      color: accentColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    textAlign: TextAlign.center,
                    'Ваші ідеї, пропозиції та повідомлення про помилки допомагають нам розвивати TT Club UA кожного дня. Діліться своїм досвідом — разом ми зробимо додаток ще кращим для всієї спільноти.',
                    style: TTTextStyle.subtitle,
                  ),
                  const SizedBox(height: 20),

                  // Text(
                  //   'Опис пропозиції або проблеми (макс. 500 символів)',
                  //   style: TTTextStyle.subtitle.copyWith(color: accentColor),
                  // ),
                  // const SizedBox(height: 8),
                  BigTextInput(
                    controller: descriptionController,
                    hint: 'Опишіть вашу ідею або проблему (макс. 500 символів)',
                    minHeight: 80,
                    minLines: 3,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Скріншоти або фото до 5 шт. (необовʼязково)',
                    style: TTTextStyle.subtitle,
                  ),
                  const SizedBox(height: 10),
                  ImagesPickerEditor(
                    images: _images,
                    accentColor: accentColor,
                    maxImages: 5,
                    onChanged: (images) {
                      setState(() {
                        _images = images;
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  GlowingButton(
                    text: isLoading ? 'Відправка...' : 'Надіслати відгук',
                    onPressed: isLoading ? () => {} : _sendFeedback,
                    colorGrowing: accentColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
