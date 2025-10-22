import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/config/default.dart';

class Onboarding_1 extends StatefulWidget {
  const Onboarding_1({super.key});

  @override
  State<Onboarding_1> createState() => _Onboarding_1State();
}

class _Onboarding_1State extends State<Onboarding_1> {
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
      // appBar: AppBar(
      //   title: Image.network(
      //     LOGO_IMAGE_DEFAULT,
      //     fit: BoxFit.contain,
      //     height: 133,
      //   ),
      // ),
      backgroundColor: TTColors.background_second,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    banner['image']!,
                    fit: BoxFit.contain,
                    height: 280,
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
