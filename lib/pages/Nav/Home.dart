import 'package:flutter/material.dart';
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
import 'Calendar.dart';
import 'Home/AnnualFeePage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '---';

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
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisAlignment: MainAxisAlignment.start,
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
                      );
                    },
                  ),

                  const SizedBox(width: 20),
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
                  const SizedBox(width: 20),
                  TopActionCard(
                    iconAsset: 'assets/svg/instagram.svg',
                    iconSize: 30,
                    iconColor: accentColor,
                    onTap: () async {
                      UrlHelper.openExternal(context,
                          Uri.parse('https://www.instagram.com/ttclub_ua?igsh=MTEwaHFieXBsdmZxZQ=='));
                      // final Uri url = Uri.parse(
                      //     'https://www.instagram.com/ttclub_ua?igsh=MTEwaHFieXBsdmZxZQ==');
                      // await launchUrl(url,
                      //     mode: LaunchMode.externalApplication);
                    },
                  ),
                  // TopActionCard(
                  //   iconAsset: 'assets/svg/question-mark.svg',
                  //   iconSize: 30,
                  //   iconColor: Colors.white.withOpacity(0.4),
                  //   onTap: () {},
                  // ),
                ],
              ),
            ),
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
              imagePath: 'assets/ui/banners/calendar_of_events.webp',
              title: 'Календар подій',
              // enabled: false,
              onButtonTap: () {
                final navState = context.findAncestorStateOfType<NavState>();
                navState?.setTab(2); // 2 — индекс вкладки Calendar
              },
            ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/budget.webp',
            //   title: 'Бюджет TTclubUA',
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            const SizedBox(height: 20),
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
            //   imagePath: 'assets/ui/banners/partners.webp',
            //   title: 'Партнери TTclubUA',
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

    setState(() {
      userName = name ?? '--';
    });
  }
}
