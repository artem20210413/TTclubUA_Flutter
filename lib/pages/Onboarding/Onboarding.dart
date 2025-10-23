import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/config/default.dart';

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
      'title': 'Cпільнота фанатів Audi TT',
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
      'image': 'https://tt.tishchenko.kiev.ua/media/images/banner_3.webp',
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
    return Scaffold(
      backgroundColor: TTColors.background_second,
      body: Stack(
        alignment: Alignment.center,
        // alignment: Alignment.center,
        children: [
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 75),
              Stack(
                alignment: Alignment.center,
                children: [
                  // ClipOval(
                  //   child: ImageFiltered(
                  //     imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  //     child: Container(
                  //       width: 274,
                  //       height: 204,
                  //       decoration: BoxDecoration(
                  //         gradient: LinearGradient(
                  //           colors: [
                  //             Colors.white.withOpacity(0.05),
                  //             Colors.white.withOpacity(0.25),
                  //             Colors.white.withOpacity(0.05),
                  //           ],
                  //           begin: Alignment.topLeft,
                  //           end: Alignment.bottomRight,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Image.network(
                    LOGO_IMAGE_DEFAULT,
                    fit: BoxFit.contain,
                    height: 133,
                  ),
                ],
              ),
            ],
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
                  Opacity(
                    opacity: index == _banners.length - 1 ? 0.0 : 1,
                    // от 0.0 до 1.0
                    child: Image.network(
                      banner['image']!,
                      fit: BoxFit.contain,
                      height: 280,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(banner['title']!,
                      textAlign: TextAlign.center, style: TTTextStyle.title),
                  const SizedBox(height: 16),
                  Text(
                    banner['subtitle']!,
                    textAlign: TextAlign.center,
                    style: TTTextStyle.subtitle,
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 14 : 10,
                  height: _currentPage == index ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white.withOpacity(0.85)
                        : Colors.white.withOpacity(0.15),
                    boxShadow: _currentPage == index
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
