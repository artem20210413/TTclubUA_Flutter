import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Home/Merch/MerchPage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Storage/Cache/AccentColorCache.dart';
import '../../Storage/Cache/DeviceInsetsCache.dart';
import '../../api/routs.dart';
import '../../components/TTNeumorphicBox.dart';
import '../../components/card/PromoCard.dart';
import '../../components/card/TopActionCard.dart';
import '../../components/generalModule.dart';
import '../../utils/url_launcher.dart';
import '../Nav.dart';
import 'Admin/Costs/CostsListScreen.dart';
import 'Calendar.dart';
import 'Home/AnnualFeePage.dart';
import 'Home/BuyingCars/BuyingCarsList.dart';
import 'Home/Draw/DrawsPage.dart';
import 'Home/Partners/PartnersPage.dart';
import 'Home/SuggestionsPage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '---';
  bool _isEntryPaid = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AccentColorCache.accentColor;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 113),
        child: Column(
          children: [
            SizedBox(height: DeviceInsetsCache.viewPaddingTop + 6),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TopActionCard(
                    iconAsset: 'assets/svg/money.svg',
                    iconSize: 40,
                    iconColor: accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AnnualFeePage()), // Переход на экран публикаций
                        // AnnualFeePage()), // Переход на экран публикаций
                      );
                    },
                  ),

                  // const SizedBox(width: 20),
                  TopActionCard(
                    iconAsset: 'assets/svg/telegram.svg',
                    iconSize: 30,
                    iconColor: accentColor,
                    onTap: () async {
                      UrlHelper.openExternal(
                          context, Uri.parse('https://t.me/TTclubUaBot'),
                          title: 'Перехід до Telegram',
                          message:
                              'Ви збираєтесь відкрити зовнішній застосунок Telegram. Продовжити?');
                      // final Uri url = Uri.parse('https://t.me/TTclubUaBot');
                      // await launchUrl(url,
                      //     mode: LaunchMode.externalApplication);
                    },
                  ),
                  // const SizedBox(width: 20),
                  TopActionCard(
                    iconAsset: 'assets/svg/instagram.svg',
                    iconSize: 30,
                    iconColor: accentColor,
                    onTap: () async {
                      UrlHelper.openExternal(
                        context,
                        Uri.parse(
                            'https://www.instagram.com/ttclub_ua?igsh=MTEwaHFieXBsdmZxZQ=='),
                        title: 'Перехід до Instagram',
                        message:
                            'Ви збираєтесь відкрити зовнішній застосунок Instagram. Продовжити?',
                      );
                      // final Uri url = Uri.parse(
                      //     'https://www.instagram.com/ttclub_ua?igsh=MTEwaHFieXBsdmZxZQ==');
                      // await launchUrl(url,
                      //     mode: LaunchMode.externalApplication);
                    },
                  ),
                  TopActionCard(
                    iconAsset: 'assets/svg/lightbulb-filament.svg',
                    iconSize: 30,
                    iconColor: accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SuggestionsPage()), // Переход на экран публикаций
                      );
                    },
                  ),
                ],
              ),
            ),
            // --- Плашка про річний внесок ---
            // if (!_isEntryPaid) ...[
            //   const SizedBox(height: 20),
            //   Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 5),
            //     child: GestureDetector(
            //       onTap: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => AnnualFeePage()),
            //         );
            //       },
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 16, vertical: 12),
            //         decoration: BoxDecoration(
            //           // Використовуємо прозорий колір акценту для фону
            //           color: TTColors.danger.withOpacity(0.1),
            //           borderRadius: BorderRadius.circular(16),
            //           border: Border.all(
            //               color: TTColors.danger.withOpacity(0.4), width: 1),
            //         ),
            //         child: Row(
            //           children: [
            //             Icon(Icons.info_outline,
            //                 color: TTColors.danger, size: 24),
            //             const SizedBox(width: 12),
            //             Expanded(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text('Річний внесок не внесено',
            //                       style: TTTextStyle.title18),
            //                   Text(
            //                     'Зробіть це, щоб підтримати клуб. Якщо ви вважаєте, що це помилка, зверніться до адміністратора.',
            //                     style: TTTextStyle.subtitle
            //                         .copyWith(color: Colors.white70),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             Icon(Icons.arrow_forward_ios,
            //                 color: accentColor, size: 14),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
            const SizedBox(height: 20),
            PromoCard(
              imagePath: 'assets/ui/banners/merch.webp',
              title: 'Мерч',
              onButtonTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MerchPage()), // Переход на экран публикаций
                );
              },
            ),
            const SizedBox(height: 20),
            PromoCard(
              imagePath: 'assets/ui/banners/promotions_from_partners.webp',
              title: 'Партнери TTclubUA',
              // enabled: false,
              onButtonTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PartnersPage()), // Переход на экран публикаций
                );
              },
            ),
            const SizedBox(height: 20),
            PromoCard(
              imagePath: 'assets/ui/banners/banner_raffle.webp',
              title: 'Розіграші',
              onButtonTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DrawsPage()), // Переход на экран публикаций
                );
              },
            ),
            const SizedBox(height: 20),
            PromoCard(
              // imagePath: 'assets/ui/banners/banner_raffle.webp',
              imagePath: 'assets/ui/banners/buying_car.webp',
              title: 'Базар',
              onButtonTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BuyingCarsList()), // Переход на экран публикаций
                );
              },
            ),
            const SizedBox(height: 20),
            PromoCard(
              // imagePath: 'assets/ui/banners/banner_raffle.webp',
              imagePath: 'assets/ui/banners/buying_car.webp',
              title: 'Базар',
              onButtonTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CostsListScreen()), // Переход на экран публикаций
                );
              },
            ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/budget.webp',
            //   title: 'Підтримати клуб',
            //   // enabled: false,
            //   onButtonTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>
            //               AnnualFeePage()), // Переход на экран публикаций
            //     );
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/ttclubua_in_world.webp',
            //   title: 'TTclubUA у світі',
            //   enabled: false,
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/promotions_from_partners.webp',
            //   title: 'Акції  партнерів',
            //   enabled: false,
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/military_aid.webp',
            //   title: 'Допомог ЗСУ',
            //   enabled: false,
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUser() async {
    final name = await UserStorage.getUserName();
    final isEntryPaid = await UserStorage.isEntryPaid();
    setState(() {
      userName = name ?? '--';
      _isEntryPaid = isEntryPaid;
    });
  }
}
