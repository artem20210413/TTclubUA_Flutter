import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Partners/partners.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/Selects/TTSelect.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';
import '../Event/EventsScreen.dart';
import 'PartnerAdminCard.dart';
import 'PartnerUploadScreen.dart';

class PartnersAdminScreen extends StatefulWidget {
  const PartnersAdminScreen({super.key});

  @override
  State<PartnersAdminScreen> createState() => _PartnersAdminScreenState();
}

enum PartnerActiveFilter {
  all(null, 'Усі'),
  active(true, 'Активні'),
  inactive(false, 'Неактивні');

  final bool? value;
  final String label;

  const PartnerActiveFilter(this.value, this.label);
}

class _PartnersAdminScreenState extends State<PartnersAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<PartnerDto> _partners = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  EventActiveFilter _activeFilter = EventActiveFilter.all;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _fetchPartners();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore &&
          !_isLoading) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }


  void _onSearch() {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });
    _fetchPartners(page: 1, append: false);
  }

  Future<void> _fetchPartners({int page = 1, bool append = false}) async {
    if (page == 1 && !append) setState(() => _isLoading = true);

    final token = await UserStorage.getToken();

    final res = await PARTNERS_LIST(
      token,
      search: _searchController.text,
      page: page,
      onlyActive: _activeFilter.value,
    );

    final isSuccess = await CHECK_API(res, context);
    if (!isSuccess) {
      setState(() => _isLoading = false);
      return;
    }

    final data = jsonDecode(res.body)['data'] as List;
    final newItems = data.map((e) => PartnerDto.fromJson(e)).toList();

    if (mounted) {
      setState(() {
        if (append) {
          _partners.addAll(newItems);
        } else {
          _partners = newItems;
        }
        _hasMore = newItems.length >= 10; // Припустимо, пагінація по 10
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _fetchPartners(page: _currentPage, append: true);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      backgroundColor: TTColors.background,
      title: 'Партнери',
      floatingActionButton: GlassFabFloatingButton(
        accentColor: accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PartnerUploadScreen()),
          );
          if (result == true) _onSearch();
        }, // Передаєте функцію оновлення
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            accentColor: accentColor,
            onSearch: _onSearch,
          ),

          /// Фільтр активності
          Padding(
            padding: const EdgeInsets.all(12),
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
          ),

          Expanded(
            child: _isLoading
                ? const TTLoading()
                : RefreshIndicator(
                    onRefresh: () async => _onSearch(),
                    color: accentColor,
                    child: _partners.isEmpty
                        ? ListView(children: [
                            const SizedBox(height: 100),
                            Center(
                                child: Text("Нічого не знайдено",
                                    style: TTTextStyle.subtitle))
                          ])
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                _partners.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _partners.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: TTLoading()),
                                );
                              }

                              final partner = _partners[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PartnerAdminCard(
                                  partner: partner,
                                  accentColor: accentColor,
                                  onEdit: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PartnerUploadScreen(
                                            partner: partner),
                                      ),
                                    );
                                    if (result == true) _onSearch();
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
}
