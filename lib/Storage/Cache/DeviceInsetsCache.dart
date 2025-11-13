import 'package:flutter/cupertino.dart';

class DeviceInsetsCache {
  static double? _notchHeight;

  static double get notchHeight => _notchHeight ?? 0;

  static void init(BuildContext context) {
    if (_notchHeight == null) {
      _notchHeight = MediaQuery.of(context).viewPadding.top;
    }
  }
}
