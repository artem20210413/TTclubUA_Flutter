import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../components/TTLoading.dart';
import '../../components/buttons/GlowingButton.dart';

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
      'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_1.webp',
      'title': 'Cпільнота фанатів Audi TT',
      'subtitle': 'Нас об\'єднує стиль, динаміка і любов до легендарної Audi TT'
    },
    {
      'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_2.webp',
      'title': 'Зустрічі, автопробіги, фотосесії',
      'subtitle': 'Бери участь у подіях клубу, ділись досвідом, шукай натхнення'
    },
    {
      'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_3.webp',
      'title': 'TT — це більше, ніж авто',
      'subtitle': 'Атмосфера, підтримка, спільні поїздки та справжні знайомства'
    },
    {
      'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_3.webp',
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

    setState(() {
      _isLoading = false;
    });

    if (!isValidToken) return;

    Navigator.pushReplacementNamed(context, '/nav');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _isLoading
            ? const TTLoading()
            : Scaffold(
                backgroundColor: TTColors.background_second,
                body: Stack(
                  alignment: Alignment.topCenter,
                  // alignment: Alignment.center,
                  children: [
                    // const SizedBox(height: 30),
                    Positioned(
                      top: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 150,
                                  spreadRadius: 50,
                                ),
                              ],
                            ),
                          ),
                          Image.network(
                            LOGO_IMAGE_DEFAULT,
                            fit: BoxFit.contain,
                            height: 133,
                          ),
                        ],
                      ),
                    ),
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _banners.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);

                        final isLast = index == _banners.length - 1;
                        if (isLast) {
                          // Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.pushReplacementNamed(context, '/login');
                          // });
                        }
                      },
                      itemBuilder: (context, index) {
                        final banner = _banners[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 70),
                            Opacity(
                              opacity: index == _banners.length - 1 ? 0.0 : 1,
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                SizedBox(
                                  height: 280,
                                  width: double.infinity,
                                  child: ShaderMask(
                                    // вертикальное «перетекание» (сверху/снизу)
                                    shaderCallback: (rect) =>
                                        const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        // мягкое исчезновение сверху
                                        Colors.white,
                                        // видимая центральная область
                                        Colors.white,
                                        // видимая центральная область
                                        Colors.transparent,
                                        // мягкое исчезновение снизу
                                      ],
                                      stops: [0.0, 0.2, 0.80, 1.0],
                                    ).createShader(rect),
                                    blendMode: BlendMode.dstIn,
                                    child: ShaderMask(
                                      // горизонтальное «перетекание» (слева/справа)
                                      shaderCallback: (rect) =>
                                          const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.transparent,
                                          // мягкое исчезновение слева
                                          Colors.white,
                                          // видимая центральная область
                                          Colors.white,
                                          // видимая центральная область
                                          Colors.transparent,
                                          // мягкое исчезновение справа
                                        ],
                                        stops: [0.0, 0, 1.0, 1.0],
                                      ).createShader(rect),
                                      blendMode: BlendMode.dstIn,
                                      child: Image.network(
                                        banner['image']!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 40),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                banner['title']!,
                                textAlign: TextAlign.center,
                                style: TTTextStyle.title,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                banner['subtitle']!,
                                textAlign: TextAlign.center,
                                style: TTTextStyle.subtitle
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      bottom: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _banners.length,
                          (index) {
                            final bool isActive = _currentPage == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                                          Colors.grey.shade600.withOpacity(0.3),
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
                ),
              ));
  }
}
