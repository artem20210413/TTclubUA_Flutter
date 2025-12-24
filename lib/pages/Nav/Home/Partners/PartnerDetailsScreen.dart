import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Helpers/UrlFormatter.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/DateRangeWidget.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../components/viewers/PlaceLink.dart';
import '../../../../config/default.dart';
import 'Promotions/PromotionsPage.dart';

class PartnerDetailsScreen extends StatelessWidget {
  final PartnerDto item;

  const PartnerDetailsScreen({super.key, required this.item});

  // Функция для открытия ссылок
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Можно добавить уведомление об ошибке, если ссылка не открывается
    }
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = AccentColorCache.accentColor;

    return TTScaffold(
      title: item.titleController.text,
      // Кнопка назад уже встроена в твой TTScaffold или AppBar
      body: TTNeumorphicBox(
        margin: const EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 8),
        // radius: 20,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Слайдер изображений ---
              ImagesCarousel(
                images: item.images,
                height: MediaQuery.of(context).size.width * 0.7,
                // На детальной странице можно сделать на весь верх
                showDots: true,
              ),

              const SizedBox(height: 8),
              DateRangeWidget(
                startDate: item.startDate,
                endDate: item.endDate,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.instagramUrlController.text.isNotEmpty)
                    PlaceLink(
                      iconPosition: IconPosition.left,
                      text: ' instagram',
                      iconPath: 'assets/svg/instagram.svg',
                      url: item.instagramUrlController.text,
                      color: accentColor,
                      dialogTitle: 'Перехід до Instagram',
                      dialogMessage:
                          'Відкрити сторінку партнера в застосунку Instagram?',
                    ),
                  if (item.instagramUrlController.text.isNotEmpty &&
                      item.websiteUrlController.text.isNotEmpty)
                    const SizedBox(width: 8),
                  if (item.websiteUrlController.text.isNotEmpty)
                    PlaceLink(
                      iconPosition: item.instagramUrlController.text.isNotEmpty
                          ? IconPosition.right
                          : IconPosition.left,
                      text: UrlFormatter.getInstagramHandle(
                          item.instagramUrlController.text),
                      iconPath: 'assets/svg/globe.svg',
                      url: item.websiteUrlController.text,
                      color: accentColor,
                      dialogTitle: 'Перехід до Instagram',
                      dialogMessage:
                          'Відкрити сторінку партнера в застосунку Instagram?',
                    )
                ],
              ),
              const SizedBox(height: 8),
              if (item.googleMapsUrlController.text.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlaceLink(
                      iconPosition: IconPosition.left,
                      text: 'google maps',
                      iconPath: 'assets/svg/location.svg',
                      url: item.googleMapsUrlController.text,
                      color: accentColor,
                      dialogTitle: 'Перехід до Instagram',
                      dialogMessage:
                          'Відкрити сторінку партнера в застосунку Instagram?',
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text(
                item.descriptionController.text.isNotEmpty
                    ? item.descriptionController.text
                    : 'Опис відсутній',
                style: TTTextStyle.subtitle,
              ),
              const SizedBox(height: 24),

              if (item.hasPromotionsActual)
                GlowingButton(
                  text: 'Акції партнера',
                  colorGrowing: accentColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PromotionsPage(
                            partner: item), // item — это твой PartnerDto
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет для строк с ссылками
  Widget _buildLinkTile({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: TTColors.card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TTTextStyle.subtitle
                  .copyWith(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                color: TTColors.text_secondary, size: 14),
          ],
        ),
      ),
    );
  }
}
