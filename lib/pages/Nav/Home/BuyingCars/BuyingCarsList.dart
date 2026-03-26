import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/api/routs/Dto/ExternalCars/ExternalCarDto.dart';
import 'package:tt_club_ua/api/routs/Dto/ExternalCars/ExternalCarFilter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Goods/GoodsDto.dart';
import '../../../../api/routs/external_cars.dart';
import '../../../../api/routs/goods.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../Admin/Merch/MerchUploadScreen.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';
import 'ExternalCarCard.dart';
import 'ExternalCarDetailsScreen.dart';

class BuyingCarsList extends StatefulWidget {
  const BuyingCarsList({super.key});

  @override
  State<BuyingCarsList> createState() => _BuyingCarsListState();
}

class _BuyingCarsListState extends State<BuyingCarsList> {
  final ExternalCarFilterDto _filter = ExternalCarFilterDto();
  List<ExternalCarDto> cars = [];
  bool isLoading = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  Color accentColor = AccentColorCache.accentColor;

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

  Future<void> fetchSearchResults({int page = 1, bool append = false}) async {
    final token = await UserStorage.getToken();
    final res = await EXTERNAL_CARS_LIST(token, filter: _filter, page: page);
    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      final data = jsonDecode(res.body)['data'] as List;
      final newItems = data.map((e) => ExternalCarDto.fromJson(e)).toList();
      setState(() {
        if (append) {
          cars.addAll(newItems);
        } else {
          cars = newItems;
          if (cars.length == 0) {
            MessageModule(
                context, 'Хмм... спробуй щось інше', MessageType.information);
          }
        }

        _hasMore = newItems.isNotEmpty;
        _isLoadingMore = false;
        isLoading = false;
      });
    } else {
      print("Ошибка загрузки: ${res.statusCode}");
    }
  }

  void _onSearch() {
    setState(() {
      isLoading = true;
      _currentPage = 1;
      _hasMore = true;
      _isLoadingMore = false;
      cars = [];
    });

    fetchSearchResults(page: 1, append: false);
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    _currentPage++;
    await fetchSearchResults(page: _currentPage, append: true);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Audi TT',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SearchBarWidget(
          //   controller: _filter.searchController,
          //   accentColor: accentColor,
          //   onSearch: _onSearch,
          // ),
          isLoading
              ? const TTLoading()
              : cars.length == 0
                  ? Text('')
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: cars.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == cars.length) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          final item = cars[index];

                          return Container(
                            padding: const EdgeInsets.only(
                                left: 16, right: 8, top: 12),
                            child: ExternalCarCard(
                            accentColor: accentColor,
                            item: item,
                            onButton: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExternalCarDetailsScreen(item: item),
                                ),
                              );
                              // MaterialPageRoute(
                              //   builder: (_) =>
                              //       MerchUploadScreen(item: item),
                              // );
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
