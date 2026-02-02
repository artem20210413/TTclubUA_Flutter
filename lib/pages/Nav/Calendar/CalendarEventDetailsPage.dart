import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/layout/TTScaffold.dart';
import 'package:tt_club_ua/components/TTNeumorphicBox.dart';
import 'package:tt_club_ua/components/viewers/FullImageViewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/routs/Dto/Event/CalendarItemDto.dart';
import '../../../components/viewers/ImagesCarousel.dart';
import '../../../components/viewers/PlaceLink.dart';
import 'ShareEventButton.dart';

class CalendarEventDetailsPage extends StatelessWidget {
  final CalendarItemDto item;

  const CalendarEventDetailsPage({
    super.key,
    required this.item,
  });

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd.$mm.$yyyy';
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget buildPlaceRow(CalendarItemDto item) {
    final hasMap = item.googleMaps != null && item.googleMaps!.isNotEmpty;

    if (item.place == null || item.place!.isEmpty) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: hasMap ? () => _openUrl(item.googleMaps!) : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Левый блок — иконка + место
          SvgPicture.asset(
            'assets/svg/map-pin.svg',
            width: 20,
            colorFilter: ColorFilter.mode(
              TTColors.text_secondary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Text(
              item.place!,
              style: TTTextStyle.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Правый блок — иконка карты (только если есть ссылка)
          if (hasMap)
            SvgPicture.asset(
              'assets/svg/map-trifold.svg',
              width: 20,
              colorFilter: ColorFilter.mode(
                TTColors.text_secondary,
                BlendMode.srcIn,
              ),
            ),
           const SizedBox(width: 8), //if (item.type == 'event_ttclubua')
           ShareEventButton(item: item),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = item.images.isNotEmpty;

    return TTScaffold(
      title: '',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TTNeumorphicBox(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 24),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImagesCarousel(
                    images: item.dtoImages,
                    height: MediaQuery.of(context).size.width * 0.6,
                    borderRadius: 32,
                  ),

                  const SizedBox(height: 8),
                  if (item.date != null ||
                      (item.time != null && item.time!.isNotEmpty)) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          [
                            if (item.date != null) _formatDate(item.date),
                            if (item.time != null && item.time!.isNotEmpty)
                              item.time!,
                          ].join(' • '),
                          style: TTTextStyle.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // PLACE + GOOGLE MAPS (одной логикой)
                  buildPlaceRow(item),

                  const SizedBox(height: 16),

                  Text(
                    item.title,
                    style: TTTextStyle.title18,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),

                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TTTextStyle.subtitle,
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
