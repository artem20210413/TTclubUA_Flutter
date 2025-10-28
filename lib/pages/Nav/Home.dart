import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/routs.dart';
import '../../components/card/PromoCard.dart';
import '../../components/generalModule.dart';

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

  Future<void> _launchMonobankJar() async {
    final userID = await UserStorage.getId();

    final Uri url =
        Uri.parse(URL_REDIRECT_JAK.replaceAll('{userId}', userID.toString()));

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Найближчі дні народження'),
        Text('Кількість учасніків та авто'),
        Text('Пошук авто та власника (функція "фа-фа")'),
        Text('інформація про події'),
        Text('Нові учасники (за месяц)'),
        Text('донат'),
        ElevatedButton.icon(
          icon: const Icon(Icons.monetization_on),
          label: const Text('Підтримати'),
          onPressed: _launchMonobankJar,
        ),
        PromoCard(
          imagePath: 'assets/ui/banners/calendar_of_events.png',
          // или 'assets/banners/calendar.jpg'
          title: 'Календар подій',
          onButtonTap: () {
            // TODO: действие по нажатию
          },
        ),
        // SizedBox(
        //   height: MediaQuery.of(context).size.width * 0.5,
        //   width: MediaQuery.of(context).size.width * 0.95,
        //   child: PromoCard(
        //     imagePath: 'assets/ui/banners/calendar_of_events.png', // или 'assets/banners/calendar.jpg'
        //     title: 'Календар подій',
        //     onButtonTap: () {
        //       // TODO: действие по нажатию
        //     },
        //   ),
        // ),
        // ElevatedButton(
        //   onPressed: () {
        //     // Navigator.pushReplacementNamed(context, '/user');
        //     // Navigator.pushNamed(context, '/user');
        //     // Navigator.popAndPushNamed(context, '/user');
        //     // Navigator.pushNamedAndRemoveUntil(
        //     //     context, '/user', (route) => true);
        //   },
        //   child: const Text('User'),
        // ),
      ],
    );
  }

  Future<void> _loadUser() async {
    final name = await UserStorage.getUserName();

    setState(() {
      userName = name ?? '--';
    });
  }
}
