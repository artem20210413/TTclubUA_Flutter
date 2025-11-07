import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/Search/CarSearchDto.dart';
import 'package:tt_club_ua/pages/Nav/Mention/SendMention.dart';
import 'package:tt_club_ua/pages/Nav/Mention/Profile.dart';

import '../../Storage/Search/UserSearchDto.dart';
import '../../Storage/UserStorage.dart';
import '../../api/routs/car/car.dart';
import '../../api/routs/root.dart';
import '../../api/routs/user.dart';
import '../../components/TTLoading.dart';
import '../../components/card/CarProfileCard.dart';
import '../../components/interface/SearchBarWidgetState.dart';
import '../../components/generalModule.dart';
import '../../config/default.dart';
import 'Admin/User/SearchUser.dart';

class Mention extends StatefulWidget {
  const Mention({super.key});

  @override
  State<Mention> createState() => _MentionState();
}

class _MentionState extends State<Mention> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSearchResults();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }
    });
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
        await SEARCH_CAR(token, _searchController.text.trim(), page: page);

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      List<dynamic> newData = jsonDecode(res.body)['data'];
      setState(() {
        if (append) {
          searchResults.addAll(newData);
        } else {
          searchResults = newData;
          if (newData.length == 0) {
            MessageModule(
                context, 'Ця ТТ ще не в гаражі...', MessageType.information);
          }
        }
        _hasMore =
            newData.length >= 15; // предположим, что на странице 10 записей
        _isLoadingMore = false;
        isLoading = false;
        // print(jsonDecode(res.body)['data']);
        // setState(() {
        //   searchResults = jsonDecode(res.body)['data'];
        //   if (searchResults.isEmpty) {
        //     MessageModule(context, 'Нічого не знайдено', MessageType.success);
        //   }
        //   isLoading = false;
        // });
      });
    } else {
      print("Ошибка загрузки: ${res.statusCode}");
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    _currentPage++;
    await fetchSearchResults(page: _currentPage, append: true);
  }

  bool isBirthdayToday(DateTime? birthday) {
    if (birthday == null) return false;
    final now = DateTime.now();
    return true;
    return birthday.day == now.day && birthday.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: 10),
        SearchBarWidget(
          controller: _searchController,
          onSearch: fetchSearchResults,
        ),
        SizedBox(height: 10),
        isLoading
            ? const TTLoading()
            :  searchResults.length == 0
                ? Text('')
                : Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          searchResults.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == searchResults.length) {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        final car = searchResults[index];
                        CarSearchDto dto = CarSearchDto.fromJson(car);

                        return CarProfileCard(
                          dto: dto,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(id: dto.user.id),
                            ),
                          ),
                          onButtonTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SendMentionScreen(dto: dto),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
