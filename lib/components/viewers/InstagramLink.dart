import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../config/LoadingTypeConfig.dart';
import '../../utils/url_launcher.dart';

class InstagramLink extends StatelessWidget {
  final String? username;
  final Color color;
  final BuildContext context;

  const InstagramLink({
    super.key,
    this.username,
    required this.context,
    this.color = TTColors.text,
  });

  Future<void> _launchInstagram(String handle) async {
    final Uri url = Uri.parse('https://instagram.com/$handle');

    // await launchUrl(url, mode: LaunchMode.externalApplication);

    await UrlHelper.openExternal(
      context,
      url,
      title: 'Перехід до Instagram',
      message:
          'Ви збираєтесь відкрити зовнішній застосунок Instagram. Продовжити?',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Если нет ни профессии, ни ника — ничего не рендерим
    if (username == null || username!.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _launchInstagram(username!),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LoadingTypeConfig.personalInformationMask(username, defaultValue: "instagram"),
            // '$username',
            style: TTTextStyle.subtitle.copyWith(
              color: color,
              // decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          SvgPicture.asset(
            'assets/svg/instagram.svg',
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
