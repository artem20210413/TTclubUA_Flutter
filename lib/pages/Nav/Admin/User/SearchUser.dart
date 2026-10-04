import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/Storage/Search/UserSearchDto.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/api/routs/user.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateUserScreen.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/card/UserAvatar.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';
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

    setState(() {
      _searchController.text = widget.searchQuery;
    });
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
    return TTScaffold(
      title: "Користувачі",
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onSearch: fetchSearchResults,
          ),
          isLoading
              ? const Expanded(child: Center(child: TTLoading()))
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // ← добавь это
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      UserSearchDto dto = UserSearchDto.fromJson(user);
                      bool isActiveUser = dto.active == true;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateUserScreen(dtoSearch: dto),
                            ),
                          );
                        },
                        child: TTNeumorphicBox(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserAvatar(
                                name: dto.name,
                                imageUrl: dto.profileImageString,
                                uniqueKey: 'search-user-${dto.id}',
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dto.name,
                                      style: TTTextStyle.title18,
                                    ),
                                    const SizedBox(height: 4),
                                    if (!isActiveUser)
                                      Text(
                                        "⚠️ Учасник не активний",
                                        style: TTTextStyle.caption
                                            .copyWith(color: TTColors.danger),
                                      ),
                                    if (isActiveUser)
                                      Text(
                                        "📍 ${dto.citiesText}",
                                        style: TTTextStyle.caption,
                                      ),
                                    Text(
                                      "🚗 ${dto.carsText}",
                                      style: TTTextStyle.caption,
                                    ),
                                    if (isActiveUser)
                                      Text(
                                        "📅 ${dto.birthDateText}",
                                        style: TTTextStyle.caption,
                                      ),
                                    if (isActiveUser)
                                      Text(
                                        "📞 ${dto.phone}",
                                        style: TTTextStyle.caption,
                                      ),
                                    if (isActiveUser)
                                      Text(
                                        "💼 ${dto.occupationDescription}",
                                        style: TTTextStyle.caption,
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "#${dto.id}",
                                      style: TTTextStyle.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  size: 16, color: TTColors.text_secondary),
                            ],
                          ),
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
