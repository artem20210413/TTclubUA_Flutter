import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../Storage/UserStorage.dart';
import '../../../api/routs/cities/city.dart';
import '../../../api/routs/root.dart';
import '../../../api/routs/Dto/City/CityDto.dart';

import '../../../Storage/Cache/AccentColorCache.dart';
import '../../../components/TTNeumorphicBox.dart';
import '../../../components/buttons/GlowingButton.dart';
import '../../../components/generalModule.dart';
import '../../../config/default.dart';
import '../../Storage/Cache/DeviceInsetsCache.dart';
import 'CustomInputField.dart'; // TTColors

class UserCitiesPicker extends StatefulWidget {
  /// Текущие города пользователя (только это ты передаёшь внутрь)
  final List<CityDto> currentCities;

  /// Коллбек: вернёт обновлённый список городов
  final ValueChanged<List<CityDto>> onChanged;

  /// Необязательные настройки UI
  final String title;
  final String labelSelected;
  final String buttonText;

  const UserCitiesPicker({
    super.key,
    required this.currentCities,
    required this.onChanged,
    this.title = 'Оберіть міста',
    this.labelSelected = 'Обрані міста',
    this.buttonText = 'Змінити міста',
  });

  @override
  State<UserCitiesPicker> createState() => _UserCitiesPickerState();
}

class _UserCitiesPickerState extends State<UserCitiesPicker> {
  final accentColor = AccentColorCache.accentColor;

  List<CityDto> _allCities = [];
  bool _loadingCities = true;

  // локально храним выбранные города (чтобы виджет сам перерисовывался)
  late List<CityDto> _selectedCities;

  @override
  void initState() {
    super.initState();
    _selectedCities = List<CityDto>.from(widget.currentCities);
    _fetchCities();
  }

  @override
  void didUpdateWidget(covariant UserCitiesPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // если родитель обновил currentCities — синхронизируемся
    if (oldWidget.currentCities != widget.currentCities) {
      _selectedCities = List<CityDto>.from(widget.currentCities);
      setState(() {});
    }
  }

  String _citiesToText(List<CityDto> items) {
    if (items.isEmpty) return 'Міста не вказані';
    return items.map((c) => c.name).join(', ');
  }

  Future<void> _fetchCities() async {
    setState(() => _loadingCities = true);

    try {
      final token = await UserStorage.getToken();
      final resCities = await GET_CITIES(token);

      final ok = await CHECK_API(resCities, context);
      if (!ok) return;

      final decoded = jsonDecode(resCities.body);
      final list = ((decoded['data']['cities'] ?? []) as List)
          .map((j) => CityDto.fromJson(j))
          .toList();

      if (!mounted) return;
      setState(() {
        _allCities = list;
        _loadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCities = false);
      // можешь убрать, если не надо
      MessageModule(context, 'Помилка завантаження міст', MessageType.error);
    }
  }

  Future<void> _openPicker() async {
    if (_loadingCities) {
      MessageModule(
          context, 'Список міст ще завантажується…', MessageType.information);
      return;
    }
    if (_allCities.isEmpty) {
      MessageModule(context, 'Список міст порожній', MessageType.information);
      return;
    }

    final selectedIds = _selectedCities.map((e) => e.id).toSet();

    final result = await showModalBottomSheet<List<CityDto>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TTColors.background,
      builder: (ctx) {
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final q = searchCtrl.text.trim().toLowerCase();

            final filtered = q.isEmpty
                ? _allCities
                : _allCities.where((c) {
                    final s = '${c.name} ${c.country}'.toLowerCase();
                    return s.contains(q);
                  }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: DeviceInsetsCache.viewPaddingBottom + 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TTTextStyle.title18,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close, color: TTColors.text_secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  CustomInputField(
                    controller: searchCtrl,
                    label: 'Пошук міста…',
                    onChanged: (_) => setLocal(() {}),
                    prefixIcon:
                        Icon(Icons.search, color: TTColors.text_secondary),
                  ),
                  // search
                  // TTNeumorphicBox(
                  //   radius: 18,
                  //   padding: const EdgeInsets.symmetric(horizontal: 12),
                  //   child: TextField(
                  //     controller: searchCtrl,
                  //     onChanged: (_) => setLocal(() {}),
                  //     style: TextStyle(
                  //       color: TTColors.text,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //     decoration: InputDecoration(
                  //       border: InputBorder.none,
                  //       hintText: 'Пошук міста…',
                  //       hintStyle: TextStyle(color: TTColors.text_secondary),
                  //       icon: Icon(Icons.search,
                  //           color: TTColors.text_secondary),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 12),

                  // list
                  SizedBox(
                    height: MediaQuery.of(ctx).size.height * 0.55,
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Нічого не знайдено',
                              style: TTTextStyle.title18,
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final city = filtered[i];
                              final checked = selectedIds.contains(city.id);

                              return TTNeumorphicBox(
                                radius: 35,
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    setLocal(() {
                                      if (checked) {
                                        selectedIds.remove(city.id);
                                      } else {
                                        selectedIds.add(city.id);
                                      }
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              city.name,
                                              style: TTTextStyle.title18,
                                              // style: TextStyle(
                                              //   color: TTColors.text,
                                              //   fontWeight: FontWeight.w800,
                                              // ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              city.country,
                                              style: TTTextStyle.subtitle,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Checkbox(
                                        value: checked,
                                        onChanged: (v) {
                                          setLocal(() {
                                            if (v == true) {
                                              selectedIds.add(city.id);
                                            } else {
                                              selectedIds.remove(city.id);
                                            }
                                          });
                                        },
                                        activeColor: accentColor,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlowingButton(
                          text: 'Очистити',
                          colorGrowing: TTColors.text_secondary,
                          onPressed: () {
                            setLocal(() => selectedIds.clear());
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GlowingButton(
                          text: 'Готово',
                          colorGrowing: accentColor,
                          onPressed: () {
                            final selected = _allCities
                                .where((c) => selectedIds.contains(c.id))
                                .toList();
                            Navigator.pop(ctx, selected);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() => _selectedCities = result);
      widget.onChanged(result);
    }
  }

  Widget _infoReadonlyRow({required String label, required String value}) {
    return TTNeumorphicBox(
      radius: 35,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TTTextStyle.subtitle,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _infoReadonlyRow(
          label: widget.labelSelected,
          value: _citiesToText(_selectedCities),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _openPicker,
          child: TTNeumorphicBox(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.buttonText,
                    style: TTTextStyle.subtitle
                        .copyWith(fontSize: 16, color: TTColors.text),
                    // style: TextStyle(
                    //   color: TTColors.text,
                    //   fontWeight: FontWeight.w800,
                    // ),
                  ),
                ),
                if (_loadingCities)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: TTColors.text_secondary,
                    ),
                  )
                else
                  Icon(Icons.chevron_right, color: TTColors.text_secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
