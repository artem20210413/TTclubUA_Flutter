import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/Search/CarSearchDto.dart';
import 'package:tt_club_ua/pages/Nav/Mention/SendMention.dart';

import '../../Storage/Search/UserSearchDto.dart';
import '../../Storage/UserStorage.dart';
import '../../api/routs/car/car.dart';
import '../../api/routs/root.dart';
import '../../api/routs/user.dart';
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
            MessageModule(context, 'Нічого не знайдено', MessageType.success);
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
            ? const Center(child: CircularProgressIndicator())
            : searchResults.length == 0
                ? Text('Тут ТТшкі...')
                : Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: searchResults.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {

                        if (index == searchResults.length) {
                          return Center(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        final car = searchResults[index];
                        CarSearchDto dto = CarSearchDto.fromJson(car);

                        final isActiveUser = dto.user.active;
                        // final textDisableUser = 'Учасник покинув нас або не хоче будти з нами';
                        final textDisableUser =
                            'Учасник не бажає бути частиною клубу';

                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: ColorFiltered(
                                  colorFilter: isActiveUser == true
                                      ? ColorFilter.mode(
                                          Colors.transparent, BlendMode.srcOver)
                                      : ColorFilter.mode(
                                          Colors.grey,
                                          BlendMode
                                              .saturation), // Применяем серый фильтр
                                  child: Image(
                                    image: dto.images.isNotEmpty
                                        ? dto.images.first.networkImage
                                        : NetworkImage(CAR_IMAGE_DEFAULT)
                                            as ImageProvider,
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  // чтобы имя было по центру
                                  children: [
                                    Center(
                                      child: Text(
                                        dto.user.name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                        "🚗 ${dto.modelName} ${dto.geneName} - ${dto.getFullLicensePlate()}"),
                                    SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            isActiveUser == false
                                                ? Text("⚠️ ${textDisableUser} ")
                                                : SizedBox.shrink(),
                                            Text(
                                                "📍 ${dto.user.citiesText ?? '-'}"),
                                          ],
                                        ),
                                        isActiveUser == true
                                            ? ElevatedButton(
                                                // style: ElevatedButton.styleFrom(
                                                //   // backgroundColor:  Colors.grey,
                                                // ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SendMentionScreen(
                                                              dto: dto),
                                                    ),
                                                  );
                                                },
                                                child: Text('Привітання'),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
