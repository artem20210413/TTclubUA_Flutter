import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/routs.dart';
import '../../components/TTNeumorphicBox.dart';
import '../../components/card/PromoCard.dart';
import '../../components/card/TopActionCard.dart';
import '../../components/generalModule.dart';
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 113),
        child: Column(
          children: [
            // Text('Найближчі дні народження'),
            // Text('Кількість учасніків та авто'),
            // Text('Пошук авто та власника (функція "фа-фа")'),
            // Text('інформація про події'),
            // Text('Нові учасники (за месяц)'),
            // Text('донат'),
            // ElevatedButton.icon(
            //   icon: const Icon(Icons.monetization_on),
            //   label: const Text('Підтримати'),
            //   onPressed: _launchMonobankJar,
            // ),
            // const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TopActionCard(
                  iconAsset: 'assets/svg/money.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AnnualFeePage()), // Переход на экран публикаций
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/merch.png',
            //   title: 'Мерч',
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/budget.png',
            //   title: 'Бюджет TTclubUA',
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/calendar_of_events.png',
            //   title: 'Календар подій',
            //   enabled: false,
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/ttclubua_in_world.png',
            //   title: 'TTclubUA у світі',
            //   enabled: false,
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/partners.png',
            //   title: 'Партнери TTclubUA',
            //   enabled: false,
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/promotions_from_partners .png',
            //   title: 'Акції  партнерів',
            //   enabled: false,
            //   onButtonTap: () {
            //     // TODO: действие по нажатию
            //   },
            // ),
            // const SizedBox(height: 20),
            // PromoCard(
            //   imagePath: 'assets/ui/banners/military_aid.png',
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
