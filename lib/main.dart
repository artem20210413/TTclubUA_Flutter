import 'package:flutter/material.dart';
import 'package:tt_club_ua/pages/Login.dart';
import 'package:tt_club_ua/pages/Nav.dart';
import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateCarScreen.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Черная шапка
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.white, // Белый фон
        primarySwatch: Colors.amber,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/nav': (context) => Nav(),
      },
    ));
