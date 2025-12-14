import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import '../../../Storage/Cache/AccentColorCache.dart';
import '../../../Storage/UserStorage.dart';
import '../../../api/routs.dart';
import '../../../components/TTNeumorphicBox.dart';
import '../../../components/buttons/GlowingButton.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../config/default.dart';

class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  // Future<void> _launchMonobankJar() async {
  //   final userID = await UserStorage.getId();
  //
  //   final Uri url =
  //   Uri.parse(URL_REDIRECT_JAK.replaceAll('{userId}', userID.toString()));
  //
  //   await launchUrl(url, mode: LaunchMode.externalApplication);
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color accentColor = AccentColorCache.accentColor;

    return TTScaffold(
      title: 'Спільнота покращень',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TTNeumorphicBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Разом робимо додаток кращим! 🤝',
                    style: TTTextStyle.title.copyWith(fontSize: 18, color: accentColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ваші ідеї, пропозиції та повідомлення про помилки є ключем до розвитку TT Club UA. Напишіть, що варто додати чи покращити, або опишіть проблему, з якою ви зіткнулися.',
                    style: TTTextStyle.subtitle,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Ваш зворотний зв\'язок допомагає нам створювати стабільний та корисний продукт для всієї спільноти.',
                    style: TTTextStyle.subtitle.copyWith(fontSize: 12),
                  ),const SizedBox(height: 20),

                  // --- БЛОК 2: ФОРМА ДЛЯ ПРОПОЗИЦІЙ ТА БАГІВ ---

                  // 1. ОПИС ТЕКСТУ
                  Text('Опис пропозиції або проблеми (макс. 500 символів)', style: TTTextStyle.subtitle.copyWith(color: accentColor)),
                  const SizedBox(height: 8),

                  //Опишіть детально: що ви пропонуєте, або як відтворити баг...

                  //Скриншоти або фото

                  // 3. КНОПКА ВІДПРАВКИ
                  GlowingButton(
                    text: 'Надіслати відгук',
                    onPressed: () {
                      // _sendFeedback(); 👈 Тут має бути метод для відправки даних на бекенд
                    },
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

