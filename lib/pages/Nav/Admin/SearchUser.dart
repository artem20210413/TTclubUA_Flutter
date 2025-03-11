import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/Storage/Search/UserSearchDto.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/api/routs/user.dart';

import '../../../Storage/UserStorage.dart';
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
  String _token = '';
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
      fetchSearchResults();
      // print("Поиск: $searchText"); // Здесь можно добавить реальный поиск
    }
  }

  Future<void> fetchSearchResults() async {
    final token = await UserStorage.getToken();
    final res = await SEARCH_USER(token, _searchController.text.trim());

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      print(jsonDecode(res.body)['data']);
      setState(() {
        searchResults = jsonDecode(res.body)['data'];
        isLoading = false;
      });
    } else {
      print("Ошибка загрузки: ${res.statusCode}");
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
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      UserSearchDto dto = UserSearchDto.fromJson(user);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading:  CircleAvatar(
                            radius: 50,
                            backgroundImage: dto.profileImage,
                          ),
                          title: Text(
                              dto.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📍 ${dto.citiesText}"),
                              Text("🚗 ${dto.carsText}"),
                              Text("📅 ${dto.birthDateText}"),
                              Text("📞 ${dto.phone}"),
                              // Text(
                              //     "📧 Email: ${user["email"] ?? "Не вказано"}"),
                              Text("💼 ${dto.occupationDescription}"),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Действие при нажатии
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
// Открыть новое окно в которое предают текст поиска отравка в апи на поиск. Отобразить результат пользователей
