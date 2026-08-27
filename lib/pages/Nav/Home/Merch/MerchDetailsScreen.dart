import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../Admin/Merch/MerchUploadScreen.dart';
import '../../../../components/merch/PurchaseRequestBottomSheet.dart';

class MerchDetailsScreen extends StatefulWidget {
  final GoodsDto item;

  const MerchDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<MerchDetailsScreen> createState() => _MerchDetailsScreenState();
}

class _MerchDetailsScreenState extends State<MerchDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAdmin = false;
  String? _token;
  late GoodsDto currentItem = new GoodsDto.empty();

  @override
  void initState() {
    super.initState();
    currentItem = widget.item;
    fetchUser();
  }

  Color accentColor = AccentColorCache.accentColor;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchUser() async {
    final canEdit = await UserStorage.canEditContent();
    final token = await UserStorage.getToken();
    setState(() {
      _isAdmin = canEdit;
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: currentItem.titleController.text,
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
              accentColor: accentColor,
              iconPath: 'assets/svg/pencil.svg',
              onPressed: () async {
                // Чекаємо на результат
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MerchUploadScreen(item: currentItem)),
                );

                // Перевіряємо, чи повернувся об'єкт (користувач міг просто натиснути "назад")
                if (result != null && result is GoodsDto) {
                  setState(() => currentItem = result);
                }
              },
              // onPressed: _onSearch,       // Передаєте функцію оновлення
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 8),
          child: Column(
            children: [
              // Text(
              //   item.titleController.text,
              //   textAlign: TextAlign.center,
              //   style: TTTextStyle.title,
              // ),
              // const SizedBox(height: 18),
              TTNeumorphicBox(
                padding:
                    EdgeInsets.only(top: 12, bottom: 24, left: 8, right: 14),
                // radius: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ImagesCarousel(
                            images: currentItem.images,
                            height: MediaQuery.of(context).size.width * 0.6,
                            borderRadius: 32,
                          ),

                          const SizedBox(height: 18),
                          // описание
                          Text(
                            currentItem.descriptionController.text,
                            textAlign: TextAlign.start,
                            style: TTTextStyle
                                .subtitle, //.copyWith(color: TTColors.text),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text(
                                '${currentItem.priceController.text} грн',
                                style: TTTextStyle.title.copyWith(fontSize: 22),
                              ),
                              const SizedBox(width: 24),
                              if (_token != null)
                                Expanded(
                                  flex: 2,
                                  child: GlowingButton(
                                    text: 'Замовити',
                                    colorGrowing: accentColor,
                                    onPressed: () => showPurchaseRequestBottomSheet(
                                        context, currentItem),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesBlock(GoodsDto item) {
    final hasImages = item.images.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: TTColors.card,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 220,
              child: hasImages
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: item.images.length,
                      onPageChanged: (i) {
                        setState(() => _currentPage = i);
                      },
                      itemBuilder: (_, index) {
                        final img = item.images[index];
                        return Image(
                          image: img.networkImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    )
                  : Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                        size: 40,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // точки-пейджинатор
          if (hasImages && item.images.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                item.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index ? Colors.white : Colors.white24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
