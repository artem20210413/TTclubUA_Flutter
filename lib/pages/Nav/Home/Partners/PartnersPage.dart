import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Partners/partners.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/CircleButton.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';
import '../../Admin/Partners/PartnerUploadScreen.dart';
import 'PartnerCard.dart';

class PartnersPage extends StatefulWidget {
  const PartnersPage({super.key});

  @override
  State<PartnersPage> createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PartnerDto> partners = [];
  bool isLoading = true;
  bool _isAdmin = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
    _fetchUser();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchUser() async {
    final canEdit = await UserStorage.canEditContent();
    setState(() {
      _isAdmin = canEdit;
    });
  }

  Future<void> _fetchPartners({int page = 1, bool append = false}) async {
    if (page == 1 && !append) setState(() => isLoading = true);

    final token = await UserStorage.getToken();
    final res = await PARTNERS_LIST(
      token,
      search: _searchController.text,
      page: page,
      onlyActive: true,
      activeNow: true,
    );

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      final data = jsonDecode(res.body)['data'] as List;
      final newItems = data.map((e) => PartnerDto.fromJson(e)).toList();

      setState(() {
        if (append) {
          partners.addAll(newItems);
        } else {
          partners = newItems;
          if (partners.isEmpty) {
            MessageModule(
                context, 'Партнерів не знайдено', MessageType.information);
          }
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
    _fetchPartners(page: 1, append: false);
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _fetchPartners(page: _currentPage, append: true);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Партнери',
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
              accentColor: accentColor,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PartnerUploadScreen()),
                );
                if (result == true) _onSearch();
              },
              // onPressed: _onSearch,       // Передаєте функцію оновлення
            )
          : null,
      body: Column(
        children: [
          // Поиск (используем твой CustomInputField)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    controller: _searchController,
                    label: 'Пошук партнерів',
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
                    onRefresh: () => _fetchPartners(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: partners.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == partners.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 8, bottom: 12),
                          child: PartnerCard(
                            partner: partners[index],
                            accentColor: accentColor,
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
}
