import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

import '../../../components/buttons/GlowingButton.dart';
import '../../../components/card/TTInnerCard.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../config/default.dart';

class AnnualFeePage extends StatelessWidget {
  const AnnualFeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TTScaffold(
      title: 'Оплата річного внеску',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TTInsetCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Підтримай спільноту TT Club UA та отримай\nдоступ до ексклюзивних привілеїв.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2126),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '1500 UAH',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlowingButton(
                    text: 'Сплатити',
                    colorGrowing: Colors.white,
                    onPressed: () {
                      // _submitForm();
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Сплатити внесок через Monobank\nДля зарахування коштів не змінюйте поле коментаря',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // секція "Що входить"
            TTInsetCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Що входить у річний внесок?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  _BulletPoint('Участь у закритих заходах клубу'),
                  _BulletPoint('Знижки у партнерських сервісах'),
                  _BulletPoint('Цифровий клубний бейдж'),
                  _BulletPoint('Подарунковий мерч'),
                  SizedBox(height: 20),
                  Text(
                    'Часті питання',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Чи обовʼязковий внесок?\n'
                    'Так, він підтримує розвиток клубу.\n\n'
                    'Як отримати мерч?\n'
                    'Після оплати вам надійде форма для заповнення адреси.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
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
