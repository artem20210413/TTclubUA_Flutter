import 'package:flutter/material.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Publication/CreatePostScreen.dart';

import '../../../../components/CustomAppBar.dart';
import '../../../../components/layout/TTScaffold.dart';

class MerchScreen extends StatefulWidget {
  @override
  _MerchScreenState createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Підтримка TT Club UA',
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) =>
          //           CreatePostScreen()), // Переход на экран публикаций
          // );
        },
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ]),
    );
  }
}
