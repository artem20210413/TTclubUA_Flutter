import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/Storage/Search/CarSearchDto.dart';
import 'package:tt_club_ua/pages/Nav/Mention/SendMention.dart';
import 'package:tt_club_ua/pages/Nav/Mention/Profile.dart';

import '../../Storage/Cache/AccentColorCache.dart';
import '../../Storage/Cache/DeviceInsetsCache.dart';
import '../../Storage/UserStorage.dart';
import '../../api/routs/Dto/Car/ColorDto.dart';
import '../../api/routs/Dto/Car/GeneDto.dart';
import '../../api/routs/Dto/Car/ModelDto.dart';
import '../../api/routs/car/car.dart';
import '../../api/routs/root.dart';
import '../../components/TTLoading.dart';
import '../../components/buttons/CircleButton.dart';
import '../../components/card/CarProfileCard.dart';
import '../../components/inputs/CustomInputField.dart';
import '../../components/interface/SearchBarWidgetState.dart';
import '../../components/generalModule.dart';
import '../../config/default.dart';
import 'Mention/CarFilterSheet.dart';

class Mention extends StatefulWidget {
  const Mention({super.key});

  @override
  State<Mention> createState() => _MentionState();
}

class _MentionState extends State<Mention> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  Color accentColor = AccentColorCache.accentColor;

  List<GeneDto> _genes = [];
  List<ModelDto> _models = [];
  List<ColorDto> _colors = [];
  List<GeneDto> _selectedGenes = [];
  List<ModelDto> _selectedModels = [];
  List<ColorDto> _selectedColors = [];
  TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFilter();
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

  bool get isAnyFilterApplied {
    return _selectedGenes.isNotEmpty ||
        _selectedModels.isNotEmpty ||
        _selectedColors.isNotEmpty ||
        _cityController.text.trim().isNotEmpty;
  }

  Future<void> fetchSearchResults({int page = 1, bool append = false}) async {
    final geneIds = _selectedGenes.map((e) => e.id).toList();
    final modelIds = _selectedModels.map((e) => e.id).toList();
    final colorIds = _selectedColors.map((e) => e.id).toList();

    final token = await UserStorage.getToken();
    final res = await SEARCH_CAR(
      token,
      _searchController.text.trim(),
      page: page,
      geneIds: geneIds,
      modelIds: modelIds,
      colorIds: colorIds,
      city: _cityController.text.trim(),
    );

    bool isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      List<dynamic> newData = jsonDecode(res.body)['data'];
      setState(() {
        if (append) {
          searchResults.addAll(newData);
        } else {
          searchResults = newData;
          if (newData.length == 0) {
            MessageModule(
                context, 'Ця ТТ ще не в гаражі...', MessageType.information);
          }
        }
        _hasMore = newData.length >= 15;
        _isLoadingMore = false;
        isLoading = false;
      });
    } else {
      print("Ошибка загрузки: ${res.statusCode}");
    }
  }

  Future<void> _loadFilter() async {
    await _fetchGenes();
    await _fetchColors();
    await _fetchModels();
  }

  Future<void> _fetchGenes() async {
    try {
      final token = await UserStorage.getToken();
      final resGenes = await GET_GENES(token);
      setState(() {
        _genes = (resGenes.data['data'] as List)
            .map((item) => GeneDto.fromJson(item))
            .toList();
      });
    } catch (e) {
      print('Ошибка загрузки _fetchGenes: $e');
    }
  }

  Future<void> _fetchColors() async {
    try {
      final token = await UserStorage.getToken();
      final resColors = await GET_COLORS(token);
      setState(() {
        _colors = (resColors.data['data'] as List)
            .map((item) => ColorDto.fromJson(item ?? {}))
            .toList();
      });
    } catch (e) {
      print('Ошибка загрузки _fetchColors: $e');
    }
  }

  Future<void> _fetchModels() async {
    try {
      final token = await UserStorage.getToken();
      final resModels = await GET_MODELS(token);
      setState(() {
        _models = (resModels.data['data'] as List)
            .map((item) => ModelDto.fromJson(item))
            .toList();
      });
    } catch (e) {
      print('Ошибка загрузки _fetchModels: $e');
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    _currentPage++;
    await fetchSearchResults(page: _currentPage, append: true);
  }

  bool isBirthdayToday(DateTime? birthday) {
    if (birthday == null) return false;
    final now = DateTime.now();
    return true;
    return birthday.day == now.day && birthday.month == now.month;
  }

  Future<void> _openFilterModal() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CarFilterSheet(
          genes: _genes,
          models: _models,
          colors: _colors,
          selectedGenes: _selectedGenes,
          selectedModels: _selectedModels,
          selectedColors: _selectedColors,
          cityController: _cityController,
          accentColor: accentColor,
          onGenesChanged: (list) {
            setState(() => _selectedGenes = List.from(list));
          },
          onModelsChanged: (list) {
            setState(() => _selectedModels = List.from(list));
          },
          onColorsChanged: (list) {
            setState(() => _selectedColors = List.from(list));
          },
          onClear: () {
            setState(() {
              _selectedGenes.clear();
              _selectedModels.clear();
              _selectedColors.clear();
              _cityController.clear();
            });
            fetchSearchResults(); // твой метод
          },
          onApply: fetchSearchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: DeviceInsetsCache.viewPaddingTop),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: CustomInputField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => fetchSearchResults(),
                  controller: _searchController,
                  label: 'Пошук',
                  prefixIcon: GestureDetector(
                    onTap: _openFilterModal,
                    child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: isAnyFilterApplied
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
                            isAnyFilterApplied
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
                onTap: fetchSearchResults,
              )
            ],
          ),
        ),
        isLoading
            ? const TTLoading()
            : searchResults.length == 0
                ? Text('')
                : Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          searchResults.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == searchResults.length) {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        final car = searchResults[index];
                        CarSearchDto dto = CarSearchDto.fromJson(car);

                        return CarProfileCard(
                          dto: dto,
                          accentColor: accentColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(id: dto.user.id),
                            ),
                          ),
                          onButtonTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SendMentionScreen(dto: dto),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
