import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../../Storage/UserStorage.dart';
import '../../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../../api/routs/Dto/Partners/PromotionDto.dart';
import '../../../../../api/routs/Partners/promotions.dart';
import '../../../../../api/routs/root.dart';
import '../../../../../components/TTLoading.dart';
import '../../../../../components/layout/TTScaffold.dart';
import '../../../../../config/default.dart';
import 'PromotionCard.dart';

class PromotionsPage extends StatefulWidget {
  final PartnerDto partner;

  const PromotionsPage({super.key, required this.partner});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final ScrollController _scrollController = ScrollController();
  List<PromotionDto> promotions = [];
  bool isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchPromotions({int page = 1, bool append = false}) async {
    if (page == 1 && !append) setState(() => isLoading = true);

    final token = await UserStorage.getToken();

    // Вызываем метод, передавая объект PartnerDto целиком
    final res = await PARTNERS_PROMOTIONS_LIST(
      token,
      widget.partner,
      page: page,
      activeNow: true,
    );

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      final data = jsonDecode(res.body)['data'] as List;
      final newItems = data.map((e) => PromotionDto.fromJson(e)).toList();

      setState(() {
        if (append) {
          promotions.addAll(newItems);
        } else {
          promotions = newItems;
        }
        _hasMore = newItems.isNotEmpty;
        _isLoadingMore = false;
        isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _fetchPromotions(page: _currentPage, append: true);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      // Динамический заголовок из Dto партнера
      title: 'Акції: ${widget.partner.titleController.text}',
      body: isLoading
          ? const TTLoading()
          : promotions.isEmpty
          ? Center(
        child: Text(
          "Акцій поки немає",
          style: TTTextStyle.subtitle,
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          _currentPage = 1;
          await _fetchPromotions();
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: promotions.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == promotions.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return PromotionCard(
              promotion: promotions[index],
              accentColor: accentColor,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}