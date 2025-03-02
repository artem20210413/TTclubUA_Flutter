import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../components/form/SearchBarWidgetState.dart';
import '../../../components/generalModule.dart';

class SearchUserScreen extends StatefulWidget {
  final String searchQuery;

  SearchUserScreen({required this.searchQuery});

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _searchController.text = widget.searchQuery;
    });
    fetchSearchResults();
  }

  void _performSearch() {
    String searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      print("Поиск: $searchText"); // Здесь можно добавить реальный поиск
    }
  }

  Future<void> fetchSearchResults() async {
    final url = Uri.parse(
        "https://api.example.com/search?q=${_searchController.text.trim()}");
    print(url);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          searchResults = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Ошибка загрузки: ${response.statusCode}");
      }
    } catch (e) {
      print("Ошибка сети: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Користувачі"),
        ),
        body: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              onSearch: _performSearch,
            ),
            isLoading
                ? CenterLoadingModule
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(searchResults[index]['title']),
                        subtitle: Text(searchResults[index]['description']),
                      );
                    },
                  ),
          ],
        ));
  }
}
// Открыть новое окно в которое предают текст поиска отравка в апи на поиск. Отобразить результат пользователей
