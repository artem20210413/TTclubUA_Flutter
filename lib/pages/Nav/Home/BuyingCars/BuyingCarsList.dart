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
import '../../../../components/buttons/CircleButton.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../Admin/Merch/MerchUploadScreen.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';
import 'BuyingCarsFilter.dart';
import 'ExternalCarCard.dart';
import 'ExternalCarDetailsScreen.dart';
import 'ExternalCarFilterDataDto.dart';

class BuyingCarsList extends StatefulWidget {
  const BuyingCarsList({super.key});

  @override
  State<BuyingCarsList> createState() => _BuyingCarsListState();
}

class _BuyingCarsListState extends State<BuyingCarsList> {
  ExternalCarFilterDto _filter = ExternalCarFilterDto();
  ExternalCarFilterDataDto filterData = ExternalCarFilterDataDto.empty();
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
    _loadFilters();
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

  Future<void> _loadFilters() async {
    final token = await UserStorage.getToken();
    final res = await EXTERNAL_CARS_FILTER(token);

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body)['data'];
      setState(() {
        filterData = ExternalCarFilterDataDto.fromJson(jsonData);
      });
    }
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

  Future<void> _openFilterModal() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BuyingCarsFilter(
          accentColor: accentColor,
          filter: _filter,
          filterData: filterData,
          // onGenesChanged: (list) {
          //   setState(() => _selectedGenes = List.from(list));
          // },
          // onModelsChanged: (list) {
          //   setState(() => _selectedModels = List.from(list));
          // },
          onFilterChanged: (filter) {
            setState(() => _filter = filter);
          },
          onClear: () {
            setState(() {
              _filter.clear();
            });
            _onSearch(); // твой метод
          },
          onApply: _onSearch,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Базар',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SearchBarWidget(
          //   controller: _filter.searchController,
          //   accentColor: accentColor,
          //   onSearch: _onSearch,
          // ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => fetchSearchResults(),
                    controller: _filter.searchController,
                    label: 'Пошук',
                    prefixIcon: GestureDetector(
                      onTap: _openFilterModal,
                      child: ClipOval(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: _filter.isFiltered
                              ? BoxDecoration(
                                  color: Colors.transparent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.1),
                                      blurRadius: 30,
                                      // spreadRadius: 1,
                                    ),
                                  ],
                                )
                              : null,
                          child: SvgPicture.asset(
                            'assets/svg/sliders-horizontal.svg',
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              _filter.isFiltered
                                  ? accentColor.withOpacity(0.9)
                                  : TTColors.text_secondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Отступ между элементами
                // Кнопка поиска
                CircleButton(
                  accentColor: accentColor,
                  iconAsset: 'assets/svg/search.svg',
                  onTap: _onSearch,
                )
              ],
            ),
          ),
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
                                    builder: (context) =>
                                        ExternalCarDetailsScreen(item: item),
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
