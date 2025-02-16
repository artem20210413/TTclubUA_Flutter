import 'package:flutter/material.dart';

import 'Admin/CreateCarScreen.dart';
import 'Admin/CreateUserScreen.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Spacer(),
        // Text('АДМИН'),
        Row(
          children: [
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUserScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  // backgroundColor: Color(0xFF8B0000),
                  ),
              child: const Text(
                '+ Коричтувача',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateCarScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  // backgroundColor: Color(0xFF8B0000),
                  ),
              child: const Text(
                '+ Авто',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Spacer(),
          ],
        )

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
}
