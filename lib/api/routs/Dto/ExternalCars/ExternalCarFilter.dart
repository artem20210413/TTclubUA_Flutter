import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Draw/DrawStatus.dart';
import 'package:tt_club_ua/api/routs/Dto/Draw/ParticipantDto.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';
import 'package:flutter/material.dart';

class ExternalCarFilterDto {
  // Контролери для тексту та чисел (в інпутах все одно текст)
  final TextEditingController searchController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();

  // Контролери для діапазонів (року та ціни)
  final TextEditingController yearFromController = TextEditingController();
  final TextEditingController yearToController = TextEditingController();
  final TextEditingController priceFromController = TextEditingController();
  final TextEditingController priceToController = TextEditingController();

  // Звичайні змінні для технічних параметрів
  String? colorHex; // Можна вибирати через пікер, тому не контролер
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

    if (colorHex != null) {
      params['color_hex'] = colorHex!.replaceFirst('#', '');
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
    searchController.clear();
    cityController.clear();
    modelController.clear();
    subCategoryController.clear();
    yearFromController.clear();
    yearToController.clear();
    priceFromController.clear();
    priceToController.clear();
    colorHex = null;
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
  }
}
