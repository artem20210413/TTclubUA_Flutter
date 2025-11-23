import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tt_club_ua/config/default.dart';

class PlaceLink extends StatelessWidget {
  final String? text;
  final String? url;
  final TextStyle? style;

  const PlaceLink({
    super.key,
    this.text,
    this.url,
    this.style,
  });

  bool get hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.trim().isEmpty) return const SizedBox();
    final baseStyle = style ?? TTTextStyle.subtitle;
    return GestureDetector(
      onTap: hasUrl
          ? () async {
              final uri = Uri.parse(url!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          : null,
      child: Text(
        text!,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
      ),
    );
  }
}
