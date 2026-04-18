import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../api/routs/Dto/ExternalCars/ExternalCarDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/card/UserAvatar.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../components/viewers/PlaceLink.dart';
import '../../../../config/default.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../utils/url_launcher.dart';
import '../../Mention/Profile.dart';

class ExternalCarDetailsScreen extends StatefulWidget {
  final ExternalCarDto item;

  const ExternalCarDetailsScreen({super.key, required this.item});

  @override
  State<ExternalCarDetailsScreen> createState() =>
      _ExternalCarDetailsScreenState();
}

class _ExternalCarDetailsScreenState extends State<ExternalCarDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Color accentColor = AccentColorCache.accentColor;
    final item = widget.item;
    return TTScaffold(
      // title: "${item.markName} ${item.modelName}",
      body: TTNeumorphicBox(
        margin: const EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Слайдер зображень ---
              ImagesCarousel(
                images: item.images,
                height: MediaQuery.of(context).size.width * 0.7,
                borderRadius: 20,
                showDots: true,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        item.title,
                        textAlign: TextAlign.center,
                        // Центруємо рядки всередині тексту
                        style: TTTextStyle.title,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {
                        if (item.user != null)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(id: item.user!.id),
                            ),
                          )
                      },
                      child: Row(
                        children: [
                          if (item.user != null) ...[
                            UserAvatar(
                              name: item.user!.name,
                              imageUrl: item.user!.profileImageString,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.user!.name,
                                style: TTTextStyle.title.copyWith(fontSize: 14),
                                maxLines: 3, // ✅ максимум 2 строки
                                softWrap: true, // ✅ разрешаем перенос
                                overflow:
                                    TextOverflow.visible, // ✅ не обрезаем текст
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            "\$${item.priceUsd.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}",
                            style: TTTextStyle.title
                                .copyWith(fontSize: 26, color: accentColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- Назва та Покоління ---
                    // Text(
                    //   "${item.year} ${item.markName} ${item.modelName}",
                    //   style: TTTextStyle.title.copyWith(fontSize: 22),
                    // ),
                    Builder(
                      builder: (context) {
                        // 1. Збираємо тільки ті поля, які не є порожніми
                        final List<String> parts = [
                          item.generationName,
                          item.modificationName ?? '',
                          // якщо modificationName nullable
                          item.equipmentName,
                        ].where((str) => str.trim().isNotEmpty).toList();

                        // 2. З'єднуємо їх через сепаратор
                        final String fullText = parts.join('  •  ');

                        // 3. Якщо тексту взагалі немає — не виводимо нічого або заглушку
                        if (fullText.isEmpty) return const SizedBox.shrink();

                        return Text(
                          fullText,
                          style: TTTextStyle.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    if (item.plateNumber != '') ...[
                      Text(
                        item.plateNumber,
                        style: TTTextStyle.title18,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign
                            .center, // Меняем TextAlign.right на center
                      ),
                      const SizedBox(height: 16),
                    ],
                    Divider(
                      color: TTColors.text_secondary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 10),

                    // --- Технічні характеристики (Сітка) ---
                    _buildSpecsGrid(item),

                    const SizedBox(height: 20),
                    Divider(
                      color: TTColors.text_secondary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 10),

                    // --- Опис ---
                    Text("Опис",
                        style: TTTextStyle.title.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      item.description ?? 'Опис відсутній',
                      style: TTTextStyle.subtitle,
                    ),

                    const SizedBox(height: 24),

                    // --- Кнопка переходу на Auto.ria ---
                    GlowingButton(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      text: 'Джерело',
                      colorGrowing: accentColor,
                      onPressed: () async {
                        final uri = Uri.parse(item.linkToView);
                        UrlHelper.openExternal(
                          context,
                          uri,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecsGrid(ExternalCarDto item) {
    return Column(
      children: [
        _specRow('assets/svg/speedometer.svg', 'Пробіг', item.race,
            icon2: 'assets/svg/gas-pump.svg',
            label2: 'Паливо',
            val2: item.fuelName),
        const SizedBox(height: 12),
        _specRow('assets/svg/gear.svg', 'КПП', item.gearboxName,
            icon2: 'assets/svg/tire.svg',
            label2: 'Привід',
            val2: item.driveName),
        const SizedBox(height: 12),
        _specRow('assets/svg/fingerprint-pattern.svg', 'Номер', item.plateNumber,
            icon2: 'assets/svg/car.svg',
            label2: 'Кузов',
            val2: item.subCategory),
        const SizedBox(height: 12),
        _specRow('assets/svg/location.svg', 'Місто', item.cityName),
      ],
    );
  }

  Widget _specRow(String icon1, String label1, String val1,
      {String? icon2, String? label2, String? val2}) {
    return Row(
      children: [
        Expanded(child: _specItem(icon1, label1, val1)),
        if (icon2 != null || label2 != null || val2 != null) ...[
          const SizedBox(width: 10),
          Expanded(child: _specItem(icon2!, label2!, val2!)),
        ]
      ],
    );
  }

  Widget _specItem(String icon, String label, String value) {
    return Row(
      children: [
        SvgPicture.asset(icon,
            width: 18, height: 18, color: TTColors.text_secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TTTextStyle.subtitle
                      .copyWith(fontSize: 10, color: TTColors.text_secondary)),
              Text(value,
                  style: TTTextStyle.subtitle.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
