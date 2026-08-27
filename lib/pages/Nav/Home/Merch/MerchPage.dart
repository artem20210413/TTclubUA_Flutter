import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Goods/GoodsDto.dart';
import '../../../../api/routs/goods.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../Admin/Merch/MerchUploadScreen.dart';
import 'GoodsCard.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';
import 'MerchDetailsScreen.dart';

class MerchPage extends StatefulWidget {
  const MerchPage({super.key});

  @override
  State<MerchPage> createState() => _MerchPageState();
}

class _MerchPageState extends State<MerchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<GoodsDto> goods = [];
  bool isLoading = false;
  bool _isAdmin = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    fetchSearchResults();
    fetchUser();
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
        page: page, onlyActive: true);

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

  Future<void> fetchUser() async {
    final canEdit = await UserStorage.canEditContent();
    setState(() {
      _isAdmin = canEdit;
    });
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

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Мерч',
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
              accentColor: accentColor,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MerchUploadScreen()),
                );
                if (result == true) _onSearch();
              },
              // onPressed: _onSearch,       // Передаєте функцію оновлення
            )
          : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
                            child: GoodsCard(
                              textButton: 'Детальніше',
                              accentColor: accentColor,
                              item: item,
                              onButton: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MerchDetailsScreen(item: item),
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
