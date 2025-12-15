import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'package:tt_club_ua/api/routs/goods.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Merch/MerchUploadScreen.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Publication/CreatePostScreen.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Cache/DeviceInsetsCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/CustomAppBar.dart';
import '../../../../components/Selects/TTSelect.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/card/GoodsCard.dart';
import 'GoodsCardForAdmin.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';

class MerchScreen extends StatefulWidget {
  @override
  _MerchScreenState createState() => _MerchScreenState();
}

enum EventActiveFilter {
  all(null),
  active(true),
  inactive(false);

  final bool? value;

  const EventActiveFilter(this.value);
}

class _MerchScreenState extends State<MerchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GoodsDto> goods = [];
  bool isLoading = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  Color accentColor = AccentColorCache.accentColor;
  EventActiveFilter _activeFilter = EventActiveFilter.all;

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
    final res = await GOODS_LIST(token, _searchController.text,
        page: page, onlyActive: _activeFilter.value);

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      final data = jsonDecode(res.body)['data'] as List;
      final newItems = data.map((e) => GoodsDto.fromJson(e)).toList();
      setState(() {
        if (append) {
          goods.addAll(newItems);
        } else {
          goods = newItems;
          if (goods.length == 0) {
            MessageModule(
                context, 'Хмм.. такого ще немає', MessageType.information);
          }
        }

        // _hasMore = newItems.length >= 10;
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
      goods = [];
    });

    fetchSearchResults(page: 1, append: false);
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    _currentPage++;
    await fetchSearchResults(page: _currentPage, append: true);
  }

  // Widget _buildActiveFilter() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         _filterChip("Усі", null),
  //         _filterChip("Активні", true),
  //         _filterChip("Неактивні", false),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildActiveFilter() {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 0),
      child: TTSelect<EventActiveFilter>(
        value: _activeFilter,
        items: EventActiveFilter.values,
        labelBuilder: (v) {
          switch (v) {
            case EventActiveFilter.all:
              return 'Усі';
            case EventActiveFilter.active:
              return 'Активні';
            case EventActiveFilter.inactive:
              return 'Неактивні';
          }
        },
        onChanged: (v) {
          if (v == null) return;
          setState(() => _activeFilter = v);
          _onSearch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border:
                  Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: accentColor, size: 30),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MerchUploadScreen()),
                );
                if (result == true) _onSearch();
              },
            ),
          ),
        ),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActiveFilter(),
          SearchBarWidget(
            controller: _searchController,
            accentColor: accentColor,
            onSearch: _onSearch,
          ),
          isLoading
              ? const TTLoading()
              : goods.length == 0
                  ? Text('')
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: goods.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == goods.length) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          final item = goods[index];

                          return Container(
                            padding: const EdgeInsets.only(
                                left: 16, right: 8, top: 12),
                            child: GoodsCardForAdmin(
                              textButton: 'Редагувати',
                              accentColor: accentColor,
                              item: item,
                              onButton: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MerchUploadScreen(item: item),
                                  ),
                                );

                                if (result == true) {
                                  _onSearch();
                                }
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
