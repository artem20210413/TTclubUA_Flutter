import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../Helpers/TTFormatter.dart';
import '../../../../Helpers/UrlFormatter.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../components/viewers/DateRangeWidget.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../components/viewers/PlaceLink.dart';
import '../../../../config/default.dart';
import '../../../../components/TTNeumorphicBox.dart';
import 'PartnerDetailsScreen.dart';

class PartnerCard extends StatelessWidget {
  final PartnerDto partner;
  final Color accentColor;

  const PartnerCard({
    super.key,
    required this.partner,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor = AccentColorCache.accentColor;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PartnerDetailsScreen(item: partner),
          ),
        );
      },
      child: TTNeumorphicBox(
        padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImagesCarousel(
              images: partner.images,
              height: 180,
              borderRadius: 24,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DateRangeWidget(
                    startDate: partner.startDate,
                    endDate: partner.endDate,
                  ),
                ),
                if (partner.hasPromotionsActual)
                  Expanded(
                    child:Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15), // Легкий фон в цвет акцента
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentColor.withOpacity(0.5), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_offer_outlined, size: 12, color: accentColor),
                            const SizedBox(width: 4),
                            Text(
                              'АКЦІЯ',
                              style: TTTextStyle.subtitle.copyWith(
                                color: accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              partner.titleController.text,
              style: TTTextStyle.title18,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              partner.descriptionController.text,
              style: TTTextStyle.subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     if (partner.instagramUrlController.text.isNotEmpty)
            //       PlaceLink(
            //         iconPosition: IconPosition.left,
            //         text: ' instagram',
            //         iconPath: 'assets/svg/instagram.svg',
            //         url: partner.instagramUrlController.text,
            //         color: accentColor,
            //         dialogTitle: 'Перехід до Instagram',
            //         dialogMessage:
            //             'Відкрити сторінку партнера в застосунку Instagram?',
            //       ),
            //     if (partner.instagramUrlController.text.isNotEmpty &&
            //         partner.websiteUrlController.text.isNotEmpty)
            //       const SizedBox(width: 8),
            //     if (partner.websiteUrlController.text.isNotEmpty)
            //       PlaceLink(
            //         iconPosition: partner.instagramUrlController.text.isNotEmpty
            //             ? IconPosition.right
            //             : IconPosition.left,
            //         text: UrlFormatter.getInstagramHandle(
            //             partner.instagramUrlController.text),
            //         iconPath: 'assets/svg/globe.svg',
            //         url: partner.websiteUrlController.text,
            //         color: accentColor,
            //         dialogTitle: 'Перехід до Instagram',
            //         dialogMessage:
            //             'Відкрити сторінку партнера в застосунку Instagram?',
            //       )
            //   ],
            // ),
            // const SizedBox(height: 8),
            // if (partner.googleMapsUrlController.text.isNotEmpty)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       PlaceLink(
            //         iconPosition: IconPosition.left,
            //         text: 'google maps',
            //         iconPath: 'assets/svg/location.svg',
            //         url: partner.googleMapsUrlController.text,
            //         color: accentColor,
            //         dialogTitle: 'Перехід до Instagram',
            //         dialogMessage:
            //             'Відкрити сторінку партнера в застосунку Instagram?',
            //       ),
            //     ],
            //   ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TTColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
