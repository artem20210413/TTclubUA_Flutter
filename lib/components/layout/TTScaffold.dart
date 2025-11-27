import 'package:flutter/material.dart';

import '../../config/default.dart';

class TTScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBack;
  final Color backgroundColor;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const TTScaffold({
    super.key,
    this.title = '',
    required this.body,
    this.showBack = true,
    this.backgroundColor = const Color(0xFF2B2F35),
    this.bottom,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: TTColors.background,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: showBack
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Text(
            title,
            style: TTTextStyle.title18,
          ),
          bottom: bottom,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
