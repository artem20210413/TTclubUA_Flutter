import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccentColorCache {
  static Color? _accentColor;
  static const _key = 'accent_color';

  static Color get accentColor => _accentColor ?? Colors.white;

  /// Инициализация из SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getInt(_key);
    _accentColor = raw != null ? Color(raw) : Colors.white;
  }

  /// Установка нового цвета (и сохранение)
  static Future<void> setColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, color.value);
  }
}
