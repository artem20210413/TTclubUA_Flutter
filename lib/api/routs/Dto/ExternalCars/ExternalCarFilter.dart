import 'package:flutter/material.dart';

class ExternalCarFilterDto {
  // Контролери для тексту та чисел (в інпутах все одно текст)
  final TextEditingController searchController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();

  // Контролери для діапазонів (року та ціни)
  final TextEditingController yearFromController = TextEditingController();
  final TextEditingController yearToController = TextEditingController();
  final TextEditingController priceFromController = TextEditingController();
  final TextEditingController priceToController = TextEditingController();

  final ValueNotifier<bool> onlyOursNotifier = ValueNotifier<bool>(false);

  // Звичайні змінні для технічних параметрів
  List<String> selectedColors = [];
  int perPage = 15;

  ExternalCarFilterDto();

  // Метод для формування Query-параметрів (для GET-запиту)
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};

    _addIfNotEmpty(params, 'search', searchController.text);
    _addIfNotEmpty(params, 'city_name', cityController.text);
    _addIfNotEmpty(params, 'model_name', modelController.text);
    _addIfNotEmpty(params, 'sub_category', subCategoryController.text);

    _addIfNotEmpty(params, 'year_from', yearFromController.text);
    _addIfNotEmpty(params, 'year_to', yearToController.text);
    _addIfNotEmpty(params, 'price_from', priceFromController.text);
    _addIfNotEmpty(params, 'price_to', priceToController.text);
    _addIfNotEmpty(params, 'plate_number', plateNumberController.text);

    if (onlyOursNotifier.value) {
      params['only_ours'] = '1';
    }

    if (selectedColors.isNotEmpty) {
      for (int i = 0; i < selectedColors.length; i++) {
        // Очищуємо решітку і додаємо індексний ключ для API
        params['color_hex[$i]'] = selectedColors[i].replaceFirst('#', '');
      }
    }

    params['per_page'] = perPage.toString();

    return params;
  }

  // Допоміжний метод, щоб не слати пусті рядки на сервер
  void _addIfNotEmpty(Map<String, String> map, String key, String value) {
    if (value.trim().isNotEmpty) {
      map[key] = value.trim();
    }
  }

  // Очищення всіх полів
  void clear() {
    // searchController.clear();
    cityController.clear();
    modelController.clear();
    subCategoryController.clear();
    yearFromController.clear();
    yearToController.clear();
    priceFromController.clear();
    priceToController.clear();
    plateNumberController.clear();
    onlyOursNotifier.value = false;
    selectedColors = [];
  }

  // Обов'язково звільняємо пам'ять
  void dispose() {
    searchController.dispose();
    cityController.dispose();
    modelController.dispose();
    subCategoryController.dispose();
    yearFromController.dispose();
    yearToController.dispose();
    priceFromController.dispose();
    priceToController.dispose();
    plateNumberController.dispose();
    onlyOursNotifier.dispose();
  }

  bool get isFiltered {
    return
        // searchController.text.trim().isNotEmpty ||
        cityController.text.trim().isNotEmpty ||
            modelController.text.trim().isNotEmpty ||
            subCategoryController.text.trim().isNotEmpty ||
            yearFromController.text.trim().isNotEmpty ||
            yearToController.text.trim().isNotEmpty ||
            priceFromController.text.trim().isNotEmpty ||
            priceToController.text.trim().isNotEmpty ||
            plateNumberController.text.trim().isNotEmpty ||
            onlyOursNotifier.value == true ||
            selectedColors.isNotEmpty;
  }
}
