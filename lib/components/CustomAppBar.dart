import 'package:flutter/material.dart';

AppBar CustomAppBar(String text, {bool automaticallyImplyLeading = false}) {
  return AppBar(
    title: Text(text),
    centerTitle: true,
    automaticallyImplyLeading: automaticallyImplyLeading,
  );
}
