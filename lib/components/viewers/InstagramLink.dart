import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tt_club_ua/config/default.dart';

class InstagramLink extends StatelessWidget {
  final String? username;
  final Color color;

  const InstagramLink({
    super.key,
    this.username,
    this.color = TTColors.text,
  });

  Future<void> _launchInstagram(String handle) async {
    // final url = Uri.parse('https://instagram.com/$handle');
    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url, mode: LaunchMode.externalApplication);
    // }

    final Uri url = Uri.parse('https://instagram.com/$handle');

    await launchUrl(url, mode: LaunchMode.externalApplication);
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
          SvgPicture.asset(
            'assets/svg/instagram.svg',
            width: 18,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '@$username',
            style: TTTextStyle.subtitle.copyWith(
              color: color,
              // decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
