
import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/config/default.dart';

import '../components/TTLoading.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool _isLoading = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _banners = [
    {
      // 'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_1.webp',
      'image': 'assets/ui/banners/banner_1.webp',
      'title': 'Cпільнота фанатів Audi TT',
      'subtitle': 'Нас об\'єднує стиль, динаміка і любов до легендарної Audi TT'
    },
    {
      // 'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_2.webp',
      'image': 'assets/ui/banners/banner_2.webp',
      'title': 'Зустрічі, автопробіги, фотосесії',
      'subtitle': 'Бери участь у подіях клубу, ділись досвідом, шукай натхнення'
    },
    {
      // 'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_3.webp',
      'image': 'assets/ui/banners/banner_3.webp',
      'title': 'TT — це більше, ніж авто',
      'subtitle': 'Атмосфера, підтримка, спільні поїздки та справжні знайомства'
    },
    {
      'image': 'assets/ui/banners/banner_3.webp',
      // 'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_3.webp',
      'title': '',
      'subtitle': ''
      // 'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_3.webp',
      // 'title': 'TT — це більше, ніж авто',
      // 'subtitle': 'Атмосфера, підтримка, спільні поїздки та справжні знайомства'
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenAndProceed();
    });
  }

  Future<void> _checkTokenAndProceed() async {
    bool isValidToken = await UserStorage.checkAndUpdate();

    if (!isValidToken) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    Navigator.pushReplacementNamed(context, '/nav');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const TTLoading()
          : Scaffold(
              backgroundColor: TTColors.background_second,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Scale fixed dimensions down on small-width viewports
                    // (e.g., iPhone SE-class ~320px) so nothing clips.
                    final scale =
                        (constraints.maxWidth / 400).clamp(0.75, 1.0);

                    final logoTop = 24 * scale;
                    final logoSize = 200 * scale;
                    final logoImageHeight = 133 * scale;
                    final bannerTopGap = 40 * scale;
                    final titleFontSize = (32 * scale).clamp(20.0, 32.0);
                    final subtitleFontSize = (18 * scale).clamp(13.0, 18.0);

                    // Dots live in their own row BELOW the carousel (not as
                    // an absolute overlay on top of it), so banner text can
                    // never visually overlap them regardless of text length
                    // or font metrics on any device.
                    return Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, pageConstraints) {
                              final bannerImageHeight =
                                  (pageConstraints.maxHeight * 0.32)
                                      .clamp(120.0, 280.0);

                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Positioned(
                                    top: logoTop,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 250),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          width: logoSize,
                                          height: logoSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.15),
                                                blurRadius: 150,
                                                spreadRadius: 50,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Image.network(
                                          LOGO_IMAGE_DEFAULT,
                                          fit: BoxFit.contain,
                                          height: logoImageHeight,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PageView.builder(
                                    controller: _pageController,
                                    itemCount: _banners.length,
                                    onPageChanged: (index) {
                                      setState(() => _currentPage = index);

                                      final isLast =
                                          index == _banners.length - 1;
                                      if (isLast) {
                                        Navigator.pushReplacementNamed(
                                            context, '/login');
                                      }
                                    },
                                    itemBuilder: (context, index) {
                                      final banner = _banners[index];
                                      final imgPath = banner['image']!;
                                      final isNetwork =
                                          imgPath.startsWith('http');
                                      return SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight:
                                                pageConstraints.maxHeight,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: logoTop +
                                                    logoSize +
                                                    bannerTopGap,
                                              ),
                                              Opacity(
                                                opacity: index ==
                                                        _banners.length - 1
                                                    ? 0.0
                                                    : 1,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          bannerImageHeight,
                                                      width: double.infinity,
                                                      child: ShaderMask(
                                                        // вертикальное «перетекание» (сверху/снизу)
                                                        shaderCallback:
                                                            (rect) =>
                                                                const LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors
                                                                .transparent,
                                                            // мягкое исчезновение сверху
                                                            Colors.white,
                                                            // видимая центральная область
                                                            Colors.white,
                                                            // видимая центральная область
                                                            Colors
                                                                .transparent,
                                                            // мягкое исчезновение снизу
                                                          ],
                                                          stops: [
                                                            0.0,
                                                            0.2,
                                                            0.80,
                                                            1.0
                                                          ],
                                                        ).createShader(rect),
                                                        blendMode:
                                                            BlendMode.dstIn,
                                                        child: ShaderMask(
                                                          // горизонтальное «перетекание» (слева/справа)
                                                          shaderCallback:
                                                              (rect) =>
                                                                  const LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              // мягкое исчезновение слева
                                                              Colors.white,
                                                              // видимая центральная область
                                                              Colors.white,
                                                              // видимая центральная область
                                                              Colors
                                                                  .transparent,
                                                              // мягкое исчезновение справа
                                                            ],
                                                            stops: [
                                                              0.0,
                                                              0,
                                                              1.0,
                                                              1.0
                                                            ],
                                                          ).createShader(
                                                              rect),
                                                          blendMode:
                                                              BlendMode.dstIn,
                                                          child: isNetwork
                                                              ? Image.network(
                                                                  imgPath,
                                                                  fit: BoxFit
                                                                      .cover)
                                                              : Image.asset(
                                                                  imgPath,
                                                                  fit: BoxFit
                                                                      .cover),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 24 * scale),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(horizontal: 16),
                                                child: Text(
                                                  banner['title']!,
                                                  textAlign: TextAlign.center,
                                                  style: TTTextStyle.title
                                                      .copyWith(
                                                          fontSize:
                                                              titleFontSize),
                                                ),
                                              ),
                                              SizedBox(height: 12 * scale),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(horizontal: 16),
                                                child: Text(
                                                  banner['subtitle']!,
                                                  textAlign: TextAlign.center,
                                                  style: TTTextStyle.subtitle
                                                      .copyWith(
                                                          fontSize:
                                                              subtitleFontSize,
                                                          color:
                                                              Colors.white),
                                                ),
                                              ),
                                              SizedBox(height: 16 * scale),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16 * scale),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _banners.length,
                              (index) {
                                final bool isActive = _currentPage == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  width: isActive ? 18 : 16,
                                  height: isActive ? 18 : 16,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: isActive
                                            ? Colors.white.withOpacity(0.2)
                                            : Colors.black,
                                        width: 1),
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: isActive
                                          ? [
                                              Colors.white.withOpacity(0.95),
                                              Colors.grey.shade600
                                                  .withOpacity(0.3),
                                            ]
                                          : [
                                              Colors.white.withOpacity(0.08),
                                              Colors.black.withOpacity(0.2),
                                            ],
                                      center: Alignment.topLeft,
                                      radius: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.6),
                                        offset: const Offset(0, 2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
