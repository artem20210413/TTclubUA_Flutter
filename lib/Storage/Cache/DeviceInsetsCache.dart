import 'dart:io';

import 'package:flutter/cupertino.dart';

class DeviceInsetsCache {
  static double? _viewPaddingTop;
  static double? _viewPaddingBottom;

  static double get viewPaddingTop => _viewPaddingTop ?? 0;

  static double get viewPaddingBottom => _viewPaddingBottom ?? 0;

  static bool isNavigationButtonsAndroid =
      Platform.isIOS == false && DeviceInsetsCache.viewPaddingBottom > 40;

  static void init(BuildContext context) {
    if (_viewPaddingTop == null)
      _viewPaddingTop = MediaQuery.of(context).viewPadding.top;

    if (_viewPaddingBottom == null)
      _viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
  }
}
