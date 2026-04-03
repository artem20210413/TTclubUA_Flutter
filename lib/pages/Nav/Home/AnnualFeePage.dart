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
import '../../../utils/url_launcher.dart';

class AnnualFeePage extends StatefulWidget {
  const AnnualFeePage({super.key});

  @override
  State<AnnualFeePage> createState() => _AnnualFeePageState();
}

class _AnnualFeePageState extends State<AnnualFeePage> {
  Future<void> _launchMonobankJar() async {
    final userID = await UserStorage.getId();

    final Uri url =
        Uri.parse(URL_REDIRECT_JAK.replaceAll('{userId}', userID.toString()));

    UrlHelper.openExternal(
      context,
      url,
    );
    // await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color accentColor = AccentColorCache.accentColor;

    return TTScaffold(
      title: 'Підтримка TT Club UA',
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
                  Text('Підтримай спільноту TT Club UA.',
                      textAlign: TextAlign.center, style: TTTextStyle.subtitle),
                  // const SizedBox(height: 20),
                  // TTNeumorphicBox(
                  //   padding: const EdgeInsets.all(12),
                  //   color: TTColors.input,
                  //   child: Center(
                  //     child: Text('- UAH', style: TTTextStyle.title),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  GlowingButton(
                    text: 'Підтримати клуб',
                    onPressed: _launchMonobankJar,
                    colorGrowing: accentColor,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Підтримка через офіційне посилання Monobank.\n'
                    'Для зарахування коштів не змінюйте поле коментаря',
                    textAlign: TextAlign.center,
                    style: TTTextStyle.subtitle
                        .copyWith(fontSize: 10, color: TTColors.text),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Це добровільна підтримка реального автомобільного клубу TT Club UA. '
                    'Переказ не є покупкою цифрових товарів чи послуг, '
                    'а оплата здійснюється поза межами App Store та Google Play.',
                    textAlign: TextAlign.center,
                    style: TTTextStyle.subtitle.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // секція "Що входить"
            // TTNeumorphicBox(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text('Що входить у річний внесок?',
            //           textAlign: TextAlign.center, style: TTTextStyle.title),
            //       SizedBox(height: 12),
            //       _BulletPoint('Участь у закритих заходах клубу'),
            //       _BulletPoint('Знижки у партнерських сервісах'),
            //       _BulletPoint('Цифровий клубний бейдж'),
            //       _BulletPoint('Подарунковий мерч'),
            //       SizedBox(height: 20),
            //       Text('Часті питання',
            //           textAlign: TextAlign.center, style: TTTextStyle.title),
            //       SizedBox(height: 10),
            //       Text(
            //         'Чи обовʼязковий внесок?',
            //         style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
            //       ),
            //       Text('Так, він підтримує розвиток клубу.\n',
            //           style: TTTextStyle.subtitle),
            //       Text(
            //         'Як отримати мерч?',
            //         style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
            //       ),
            //       Text('Після оплати вам надійде форма для заповнення адреси.',
            //           style: TTTextStyle.subtitle),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// Маркер-рядок списка
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.white54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
