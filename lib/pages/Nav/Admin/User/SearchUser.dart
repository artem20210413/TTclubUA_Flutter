import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/Storage/Search/UserSearchDto.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/api/routs/user.dart';
import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateUserScreen.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/generalModule.dart';

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
  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(page: 1);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }
    });

    // setState(() {
    //   _searchController.text = widget.searchQuery;
    // });
    // _performSearch();
  }

  void _performSearch() {
    String searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      fetchSearchResults();
    }
  }

  Future<void> fetchSearchResults({int page = 1, bool append = false}) async {
    final token = await UserStorage.getToken();
    final res =
        await SEARCH_USER(token, _searchController.text.trim(), page: page);

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      List<dynamic> data = jsonDecode(res.body)['data'];

      setState(() {
        if (append) {
          searchResults.addAll(data);
        } else {
          searchResults = data;
          if (data.length == 0) {
            MessageModule(context, 'Нічого не знайдено', MessageType.success);
          }
        }

        _hasMore = data.length >= 10;
        _isLoadingMore = false;
        isLoading = false;
      });
      // print(jsonDecode(res.body)['data']);
      // setState(() {
      //   searchResults = jsonDecode(res.body)['data'];
      //   isLoading = false;
      // });
    } else {
      print("Ошибка загрузки: ${res.statusCode}");
    }
  }
  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
      _page++;
    });
    fetchSearchResults(page: _page, append: true);
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
            onSearch: fetchSearchResults,
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // ← добавь это
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      UserSearchDto dto = UserSearchDto.fromJson(user);
                      bool isActiveUser = dto.active == true;
                      return Card(
                        surfaceTintColor:
                            isActiveUser ? Colors.transparent : Colors.red,
                        // shadowColor: isActiveUser ? Colors.black : Colors.red,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: dto.profileImage,
                          ),
                          title: Text(
                            dto.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isActiveUser
                                  ? SizedBox.shrink()
                                  : Text("⚠️ Учасник не активний "),
                              isActiveUser
                                  ? Text("📍 ${dto.citiesText}")
                                  : SizedBox.shrink(),
                              Text("🚗 ${dto.carsText}"),
                              isActiveUser
                                  ? Text("📅 ${dto.birthDateText}")
                                  : SizedBox.shrink(),
                              isActiveUser
                                  ? Text("📞 ${dto.phone}")
                                  : SizedBox.shrink(),
                              isActiveUser
                                  ? Text("💼 ${dto.occupationDescription}")
                                  : SizedBox.shrink(),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdateUserScreen(dtoSearch: dto),
                              ),
                            );
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
