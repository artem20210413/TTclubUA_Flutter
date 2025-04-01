import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';

import '../../api/routs/homepage.dart';
import '../../api/routs/root.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '---';
  List<dynamic> birthdaysNextWeek = [];
  List<dynamic> newMembersThisMonth = [];
  int totalMembers = 0;
  int totalCars = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    homepageData();
  }

  Future<void> homepageData() async {
    final token = await UserStorage.getToken();
    final res = await HOMEPAGE_DATA(token);

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      setState(() {
        final data = jsonDecode(res.body)['data'];
        birthdaysNextWeek = data['birthdays_next_week'];
        newMembersThisMonth = data['new_members_this_month'];
        totalMembers = data['total_members'];
        totalCars = data['total_cars'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Text('Статистика'),
          subtitle: Text('Учасників: $totalMembers\nАвто: $totalCars'),
          leading: Icon(Icons.pie_chart),
        ),
      ),
    ]);
    //   Column(
    //   children: [
    //     Text('Найближчі дні народження'),
    //     Text('Кількість учасніків та авто'),
    //     Text('Пошук авто та власника (функція "фа-фа")'),
    //     Text('інформація про події'),
    //     Text('Нові учасники (за месяц)'),
    //     Text('донат'),
    //     // ElevatedButton(
    //     //   onPressed: () {
    //     //     // Navigator.pushReplacementNamed(context, '/user');
    //     //     // Navigator.pushNamed(context, '/user');
    //     //     // Navigator.popAndPushNamed(context, '/user');
    //     //     // Navigator.pushNamedAndRemoveUntil(
    //     //     //     context, '/user', (route) => true);
    //     //   },
    //     //   child: const Text('User'),
    //     // ),
    //   ],
    // );
  }

  Future<void> _loadUser() async {
    final name = await UserStorage.getUserName();

    setState(() {
      userName = name ?? '--';
    });
  }
}
