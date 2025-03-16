import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';

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
    return Column(
      children: [
        Text('Найближчі дні народження'),
        Text('Пошук авто та власника (функція "фа-фа")'),
        Text('інформація про події'),
        Text('Нові учасники (за месяц)'),
        Text('донат'),
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
