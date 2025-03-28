import 'package:flutter/material.dart'; // Убедитесь, что путь к GET_CITIES правильный
import 'dart:convert';

import '../../Storage/UserStorage.dart';
import '../../api/routs/Dto/City/CityDto.dart';
import '../../api/routs/cities/city.dart';
import '../../api/routs/root.dart'; // Для jsonDecode

class CitySelector extends StatefulWidget {
  final List<CityDto> selectedCities;
  final Function(CityDto) onCityAdd;
  final Function(int) onCityRemove;

  const CitySelector({
    Key? key,
    required this.selectedCities,
    required this.onCityAdd,
    required this.onCityRemove,
  }) : super(key: key);

  @override
  _CitySelectorState createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  List<CityDto> cities = [];

  @override
  void initState() {
    super.initState();
    _getCities();
  }

  // Метод для получения городов
  Future<void> _getCities() async {
    try {
      final token = await UserStorage.getToken();
      final resCities = await GET_CITIES(token);

      final isSuccessCities = await CHECK_API(resCities, context);
      if (!isSuccessCities) return;

      final decodedBody = jsonDecode(resCities.body);

      setState(() {
        cities = ((decodedBody['data']['cities'] ?? []) as List)
            .map((json) => CityDto.fromJson(json))
            .toList();
      });
    } catch (e) {
      print("Error fetching cities: $e");
      // Можете добавить обработку ошибки (например, выводить сообщение)
    }
  }

  @override
  Widget build(BuildContext context) {
    String? selectedCityName; // Переменная для отслеживания выбранного города

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ряд с текстом слева и выпадающим списком справа
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Пространство между элементами
            children: [
              const Text(
                "Міста",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
              const SizedBox(width: 18),
              // Немного отступа между текстом и списком
              Expanded(
                child: DropdownButtonFormField<String>(
                  hint: const Text("Оберіть місто"),
                  value: selectedCityName,
                  items: cities
                      .map((city) => DropdownMenuItem<String>(
                            value: city.name,
                            child: Text(city.name),
                          ))
                      .toList(),
                  onChanged: (selectedCity) {
                    if (selectedCity != null) {
                      final selectedCityObj = cities.firstWhere(
                        (city) => city.name == selectedCity,
                      );
                      // Добавление города в список и очистка выбора
                      setState(() {
                        widget.onCityAdd(selectedCityObj);
                        selectedCityName = '';
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Список выбранных городов
          Wrap(
            spacing: 8.0, // Отступ между тегами по горизонтали
            runSpacing: 4.0, // Отступ между строками тегов
            children: List.generate(widget.selectedCities.length, (index) {
              return Chip(
                label: Text(widget.selectedCities[index].name),
                deleteIcon: const Icon(Icons.close, color: Colors.red),
                onDeleted: () {
                  widget.onCityRemove(index);
                },
                backgroundColor: Colors.transparent,
                labelStyle: const TextStyle(color: Colors.black),
                elevation: 0, // Убираем тень
              );
            }),
          ),
        ],
      ),
    );
  }
}
