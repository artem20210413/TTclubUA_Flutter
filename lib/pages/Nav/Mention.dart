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
import 'Admin/CreateCarScreen.dart';
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

  void _performSearch() {
    String searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      fetchSearchResults();
    }
  }

  Future<void> fetchSearchResults() async {
    final token = await UserStorage.getToken();
    final res = await SEARCH_CAR(token, _searchController.text.trim());

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      print(jsonDecode(res.body)['data']);
      setState(() {
        searchResults = jsonDecode(res.body)['data'];
        if (searchResults.isEmpty) {
          MessageModule(context, 'Нічого не знайдено', MessageType.success);
        }
        isLoading = false;
      });
    } else {
      print("Ошибка загрузки: ${res.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: 10),
        SearchBarWidget(
          controller: _searchController,
          onSearch: _performSearch,
        ),
        SizedBox(height: 10),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : searchResults.length == 0
                ? Text('Тут ТТшкі...')
                : Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
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
                                                "🚗 ${dto.modelName} ${dto.geneName} - ${dto.getFullLicensePlate()}"),
                                            SizedBox(height: 2),
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
