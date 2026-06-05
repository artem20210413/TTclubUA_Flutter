import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../config/LoadingTypeConfig.dart';
import '../../utils/url_launcher.dart';

class TelegramLink extends StatelessWidget {
  final String? username;
  final Color color;
  final BuildContext context;

  const TelegramLink({
    super.key,
    required this.context,
    this.username,
    this.color = TTColors.text,
  });

  Future<void> _launchTelegram(String handle) async {
    final normalizedHandle = handle.startsWith('@')
        ? handle.substring(1)
        : handle; // убираем @ если есть

    final Uri url = Uri.parse('https://t.me/$normalizedHandle');
    // await launchUrl(url, mode: LaunchMode.externalApplication);

    await UrlHelper.openExternal(context, url,
        title: 'Перехід до Telegram',
        message:
            'Ви збираєтесь відкрити зовнішній застосунок Telegram. Продовжити?');
  }

  @override
  Widget build(BuildContext context) {
    if (username == null || username!.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _launchTelegram(username!),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LoadingTypeConfig.personalInformationMask(username,
                defaultValue: "telegram"),
            // '$username',
            style: TTTextStyle.subtitle.copyWith(
              color: color,
              // decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          SvgPicture.asset(
            'assets/svg/telegram.svg',
            // добавь иконку telegram.svg в assets/svg/
            width: 18,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
