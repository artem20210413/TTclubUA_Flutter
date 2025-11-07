import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tt_club_ua/config/default.dart';

class TelegramLink extends StatelessWidget {
  final String? username;
  final Color color;

  const TelegramLink({
    super.key,
    this.username,
    this.color = TTColors.text,
  });

  Future<void> _launchTelegram(String handle) async {
    final normalizedHandle = handle.startsWith('@')
        ? handle.substring(1)
        : handle; // убираем @ если есть

    final Uri url = Uri.parse('https://t.me/$normalizedHandle');
    await launchUrl(url, mode: LaunchMode.externalApplication);
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
            '$username',
            style: TTTextStyle.subtitle.copyWith(
              color: color,
              // decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          SvgPicture.asset(
            'assets/svg/telegram.svg', // добавь иконку telegram.svg в assets/svg/
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
