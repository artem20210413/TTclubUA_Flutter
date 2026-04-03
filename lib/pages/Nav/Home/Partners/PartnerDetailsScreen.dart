import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Helpers/UrlFormatter.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/DateRangeWidget.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../components/viewers/PlaceLink.dart';
import '../../../../config/default.dart';
import '../../Admin/Partners/PartnerUploadScreen.dart';
import 'Promotions/PromotionsPage.dart';

class PartnerDetailsScreen extends StatefulWidget {
  final PartnerDto item;

  const PartnerDetailsScreen({super.key, required this.item});

  @override
  State<PartnerDetailsScreen> createState() => _PartnerDetailsScreenState();
}

class _PartnerDetailsScreenState extends State<PartnerDetailsScreen> {
  bool _isAdmin = false;
  late PartnerDto currentItem = PartnerDto.empty();

  @override
  void initState() {
    super.initState();
    setState(() {
      currentItem = widget.item;
    });
    fetchUser();
  }

  Future<void> fetchUser() async {
    final isAdmin = await UserStorage.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = AccentColorCache.accentColor;

    return TTScaffold(
      title: currentItem.titleController.text,
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
              accentColor: accentColor,
              iconPath: 'assets/svg/pencil.svg',
              onPressed: () async {
                // Чекаємо на результат
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          PartnerUploadScreen(partner: currentItem)),
                );

                // Перевіряємо, чи повернувся об'єкт (користувач міг просто натиснути "назад")
                if (result != null && result is PartnerDto) {
                  setState(() => currentItem = result);
                }
              },
              // onPressed: _onSearch,       // Передаєте функцію оновлення
            )
          : null,
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
                images: currentItem.images,
                height: MediaQuery.of(context).size.width * 0.7,
                // На детальной странице можно сделать на весь верх
                showDots: true,
              ),

              const SizedBox(height: 8),
              DateRangeWidget(
                startDate: currentItem.startDate,
                endDate: currentItem.endDate,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentItem.instagramUrlController.text.isNotEmpty)
                    PlaceLink(
                      iconPosition: IconPosition.left,
                      text: ' instagram',
                      iconPath: 'assets/svg/instagram.svg',
                      url: currentItem.instagramUrlController.text,
                      color: accentColor,
                      dialogTitle: 'Перехід до Instagram',
                      dialogMessage:
                          'Відкрити сторінку партнера в застосунку Instagram?',
                    ),
                  if (currentItem.instagramUrlController.text.isNotEmpty &&
                      currentItem.websiteUrlController.text.isNotEmpty)
                    const SizedBox(width: 8),
                  if (currentItem.websiteUrlController.text.isNotEmpty)
                    PlaceLink(
                      iconPosition:
                          currentItem.instagramUrlController.text.isNotEmpty
                              ? IconPosition.right
                              : IconPosition.left,
                      text: 'Відвідати сайт',
                      iconPath: 'assets/svg/globe.svg',
                      url: currentItem.websiteUrlController.text,
                      color: accentColor,
                      dialogTitle: 'Перехід на сайт',
                      dialogMessage:
                      'Ви збираєтесь перейти на зовнішній веб-сайт партнера. Продовжити?',
                    )
                ],
              ),
              const SizedBox(height: 8),
              if (currentItem.googleMapsUrlController.text.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlaceLink(
                      iconPosition: IconPosition.left,
                      text: 'Google Maps', // З великої літери виглядає краще
                      iconPath: 'assets/svg/location.svg',
                      url: currentItem.googleMapsUrlController.text,
                      color: accentColor,
                      dialogTitle: 'Перехід до Google Maps',
                      dialogMessage: 'Відкрити місцезнаходження партнера на карті?',
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text(
                currentItem.descriptionController.text.isNotEmpty
                    ? currentItem.descriptionController.text
                    : 'Опис відсутній',
                style: TTTextStyle.subtitle,
              ),
              const SizedBox(height: 24),

              if (currentItem.hasPromotionsActual)
                GlowingButton(
                  text: 'Акції партнера',
                  colorGrowing: accentColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PromotionsPage(
                            partner: currentItem), // item — это твой PartnerDto
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
