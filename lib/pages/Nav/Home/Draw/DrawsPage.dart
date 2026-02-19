import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/draws.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/CircleButton.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';
import 'DrawCard.dart';
import '../../Admin/Draw/DrawUploadScreen.dart';
import 'DrawDetailsScreen.dart';

class DrawsPage extends StatefulWidget {
  const DrawsPage({super.key});

  @override
  State<DrawsPage> createState() => _DrawsPageState();
}

class _DrawsPageState extends State<DrawsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<DrawDto> draws = [];
  bool isLoading = true;
  bool _isAdmin = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _fetchDraws();
    _checkAdminStatus();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await UserStorage.isAdmin();
    setState(() => _isAdmin = isAdmin);
  }

  Future<void> _fetchDraws({int page = 1, bool append = false}) async {
    if (page == 1 && !append) setState(() => isLoading = true);

    final token = await UserStorage.getToken();
    // Припустимо, у тебе є метод DRAWS_LIST
    final res = await DRAW_LIST(
      token,
      page: page,
    );

    if (await CHECK_API(res, context)) {
      final data = jsonDecode(res.body)['data'] as List;
      final newItems = data.map((e) => DrawDto.fromJson(e)).toList();

      setState(() {
        if (append) {
          draws.addAll(newItems);
        } else {
          draws = newItems;
        }
        _hasMore = newItems.isNotEmpty;
        _isLoadingMore = false;
        isLoading = false;
      });
    }
  }

  void _onSearch() {
    _currentPage = 1;
    _hasMore = true;
    _fetchDraws(page: 1);
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _fetchDraws(page: _currentPage, append: true);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Розіграші',
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
        accentColor: accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DrawUploadScreen()),
          );
          if (result != null) _onSearch();
        },
      )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    controller: _searchController,
                    label: 'Пошук розіграшів',
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleButton(
                  accentColor: accentColor,
                  iconAsset: 'assets/svg/search.svg',
                  onTap: _onSearch,
                )
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const TTLoading()
                : RefreshIndicator(
              onRefresh: () => _fetchDraws(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: draws.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == draws.length) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  return Container(
                    margin: const EdgeInsets.only( bottom: 12),
                    child:  DrawCard(
                      draw: draws[index],
                      accentColor: accentColor,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DrawDetailsScreen(
                              drawDto: draws[index], // Передаємо існуючий об'єкт
                            ),
                          ),
                        );

                        // Якщо повернулися після успішного збереження — оновлюємо дані
                        if (result != null) {
                          _fetchDraws();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}