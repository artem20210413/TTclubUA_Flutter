import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Storage/Cache/AccentColorCache.dart';
import '../../config/default.dart';

class ColorAccentPicker extends StatefulWidget {
  const ColorAccentPicker({
    Key? key,
    this.colors,
    this.storageKey = 'accent_color',
    this.onChanged,
  }) : super(key: key);

  /// Набор доступных цветов (по умолчанию – 7 кружков)
  final List<Color>? colors;

  /// Ключ в SharedPreferences
  final String storageKey;

  /// Колбек при выборе
  final ValueChanged<Color>? onChanged;

  @override
  State<ColorAccentPicker> createState() => _ColorAccentPickerState();
}

class _ColorAccentPickerState extends State<ColorAccentPicker> {
  static const List<Color> _default = [
    Color(0xFFFFFFFF), // white
    Color(0xFFFFD900), // yellow
    Color(0xFF00FF09), // green
    Color(0xFFFF130B), // red
    Color(0xFF004DDB), // blue
    Color(0xFFDB00BE), // purple
    Color(0xFFFF3C00), // orange
  ];

  late List<Color> _colors;
  Color? _selected;

  @override
  void initState() {
    super.initState();
    _colors = widget.colors ?? _default;
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    // final prefs = await SharedPreferences.getInstance();
    // final raw = prefs.getInt(widget.storageKey);
    setState(() {
      // _selected = raw != null ? Color(raw) : _colors.first;
      _selected = AccentColorCache.accentColor;
    });
  }

  Future<void> _select(Color c) async {
    if (_selected == c) return;
    setState(() => _selected = c);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(widget.storageKey, c.value);
    widget.onChanged?.call(c);
    await AccentColorCache.setColor(c);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Обрати колір підсвітки додатку:',
        //   style: TTTextStyle.title.copyWith(fontSize: 16),
        // ),
        // const SizedBox(height: 12),
        Wrap(
          spacing: 18,
          runSpacing: 14,
          children: _colors.map((c) {
            final bool isActive = _selected?.value == c.value;
            return GestureDetector(
              onTap: () => _select(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? Colors.white
                        : Colors.black.withOpacity(0.35),
                    width: isActive ? 2 : 1.2,
                  ),
                  boxShadow: [
                    // мягкая «неоновая» подсветка у выбранного
                    if (isActive)
                      BoxShadow(
                        color: c.withOpacity(0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
