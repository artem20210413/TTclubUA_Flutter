import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Dto/Event/EventDto.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Event/EventAdminCard.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/events.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/Selects/TTSelect.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';
import 'EventUploadScreen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

enum EventTypeFilter {
  all(null),
  club(1),
  world(2);

  final int? value;

  const EventTypeFilter(this.value);
}

enum EventActiveFilter {
  all(null),
  active(true),
  inactive(false);

  final bool? value;

  const EventActiveFilter(this.value);
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<EventDto> _events = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  Color accentColor = AccentColorCache.accentColor;
  EventTypeFilter _typeFilter = EventTypeFilter.all;
  EventActiveFilter _activeFilter = EventActiveFilter.all;
  bool _canEditContent = false;
  // Guards against a double tap firing Navigator.push twice before the
  // first pushed route has finished laying out (was causing a
  // "RenderBox was not laid out" paint assertion on rapid double taps).
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _loadPermissions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _openEventForm({EventDto? item}) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventUploadScreen(item: item)),
      );
      if (result == true) _onSearch();
    } finally {
      _isNavigating = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    final canEdit = await UserStorage.canEditContent();
    setState(() {
      _canEditContent = canEdit;
    });
  }

  Future<void> _fetchEvents({int page = 1, bool append = false}) async {
    final token = await UserStorage.getToken();

    final res = await EVENT_LIST(
      token,
      _searchController.text,
      page: page,
      type: _typeFilter.value,
      active: _activeFilter.value,
      // onlyActive: _onlyActiveFilter, // якщо додаси
    );

    final isSuccess = await CHECK_API(res, context);
    if (!isSuccess) return;

    final data = jsonDecode(res.body)['data'] as List;

    final newItems = data.map((e) => EventDto.fromJson(e)).toList();

    setState(() {
      if (append) {
        _events.addAll(newItems);
      } else {
        _events = newItems;
        if (_events.isEmpty) {
          MessageModule(
            context,
            'Подій поки немає',
            MessageType.information,
          );
        }
      }

      _hasMore = newItems.isNotEmpty;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  void _onSearch() {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
      _isLoadingMore = false;
      _events = [];
    });

    _fetchEvents(page: 1, append: false);
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    _currentPage++;
    await _fetchEvents(page: _currentPage, append: true);
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ----- Фільтр за типом -----
          Expanded(
            flex: 1,
            child: TTSelect<EventTypeFilter>(
              value: _typeFilter,
              items: EventTypeFilter.values,
              labelBuilder: (v) {
                switch (v) {
                  case EventTypeFilter.all:
                    return 'Усі';
                  case EventTypeFilter.club:
                    return 'Події TT CLub UA';
                  case EventTypeFilter.world:
                    return 'Світові';
                }
              },
              onChanged: (v) {
                if (v == null) return;
                setState(() => _typeFilter = v);
                _onSearch(); // перезагрузка списка
              },
            ),
          ),

          const SizedBox(width: 8),

          // ----- Фільтр за активністю -----
          Expanded(
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Події',
      floatingActionButton: Visibility(
        visible: _canEditContent,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: GlassFabFloatingButton(
          accentColor: accentColor,
          onPressed: () => _openEventForm(),
        ),
      ),
      body: Column(
        children: [
          _buildFiltersRow(),
          SearchBarWidget(
            controller: _searchController,
            accentColor: accentColor,
            onSearch: _onSearch,
          ),
          _isLoading
              ? const TTLoading()
              : _events.isEmpty
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _events.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _events.length) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final event = _events[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 8,
                              top: 12,
                            ),
                            child: EventAdminCard(
                              accentColor: accentColor,
                              event: event,
                              onEdit: !_canEditContent
                                  ? () {}
                                  : () => _openEventForm(item: event),
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
