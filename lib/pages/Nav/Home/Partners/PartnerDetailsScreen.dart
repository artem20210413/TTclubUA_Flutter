import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Dto/Partners/Promotions/PromotionsPage.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../config/default.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Слайдер изображений ---
              ImagesCarousel(
                images: item.images,
                height: MediaQuery.of(context).size.width * 0.7,
                borderRadius: 0,
                // На детальной странице можно сделать на весь верх
                showDots: true,
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Заголовок ---
                    Text(
                      item.titleController.text,
                      style: TTTextStyle.title.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 12),

                    // --- Описание ---
                    Text(
                      item.descriptionController.text.isNotEmpty
                          ? item.descriptionController.text
                          : 'Опис відсутній',
                      style: TTTextStyle.subtitle,
                    ),
                    const SizedBox(height: 24),

                    // --- Блок контактов/ссылок ---
                    Text("Контакти та локація", style: TTTextStyle.title18),
                    const SizedBox(height: 12),

                    if (item.instagramUrlController.text.isNotEmpty)
                      _buildLinkTile(
                        icon: 'assets/svg/instagram.svg',
                        label: 'Instagram',
                        onTap: () =>
                            _launchUrl(item.instagramUrlController.text),
                      ),

                    if (item.websiteUrlController.text.isNotEmpty)
                      _buildLinkTile(
                        icon: 'assets/svg/globe.svg',
                        label: 'Веб-сайт',
                        onTap: () => _launchUrl(item.websiteUrlController.text),
                      ),

                    if (item.googleMapsUrlController.text.isNotEmpty)
                      _buildLinkTile(
                        icon: 'assets/svg/location.svg',
                        label: 'Ми на карті',
                        onTap: () =>
                            _launchUrl(item.googleMapsUrlController.text),
                      ),
                    const SizedBox(height: 24),
                    if (item.hasPromotions)
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
                    const SizedBox(height: 40),
                  ],
                ),
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
