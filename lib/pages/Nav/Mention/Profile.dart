import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/card/UserAvatar.dart';
import 'package:tt_club_ua/components/viewers/TelegramLink.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../api/routs/User.dart';
import '../../../components/TTLoading.dart';
import '../../../components/TTNeumorphicBox.dart';
import '../../../components/card/CarImageBlock.dart';
import '../../../components/inputs/CustomInputField.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../components/viewers/InstagramLink.dart';

class Profile extends StatefulWidget {
  final int? id;

  const Profile({super.key, this.id});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late UserUpdateDto _dto;

  bool _isLoading = true;

  String userProfileImage = USER_PROFILE_IMAGE_DEFAULT;
  late final ScrollController _carsScrollController;

  void initState() {
    super.initState();
    _carsScrollController = ScrollController();

    _load();
  }

  @override
  Future<void> _load() async {
    await UserStorage.checkAndUpdate();

    String? localProfileImage = await UserStorage.getProfileImagee();
    dynamic json = await UserStorage.getUserInfo();

    if (widget.id != null && widget.id != json['id']) {
      final token = await UserStorage.getToken();
      final resUs = await USER_FIND(token, widget.id ?? 1);
      json = await jsonDecode(resUs.body)['data'];
      localProfileImage = await (json['profile_image'] ?? null);
    }
    setState(() {
      _dto = UserUpdateDto.fromJson(json);
      userProfileImage = localProfileImage ?? userProfileImage;
      _isLoading = false;
      print(_dto.isBirthdayToday);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _runCarsHintScroll();
    });
  }

  @override
  void dispose() {
    _carsScrollController.dispose();
    super.dispose();
  }

  void _runCarsHintScroll() {
    if (!mounted) return;
    if (_dto.cars.length <= 1) return;
    if (!_carsScrollController.hasClients) return;

    final width = MediaQuery.of(context).size.width;
    final double offset = width * 0.1;

    _carsScrollController
        .animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    )
        .then((_) async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!_carsScrollController.hasClients) return;
      _carsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return TTScaffold(
      // title: '',
      body: Column(
        children: [
          TTNeumorphicBox(
            margin: EdgeInsets.only(top: 0, bottom: 16, left: 20, right: 12),
            padding: EdgeInsets.only(top: 0, bottom: 4, left: 0, right: 8),
            child: _isLoading
                ? const TTLoading()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(clipBehavior: Clip.none, children: [
                              Row(
                                children: [
                                  UserAvatar(
                                    radius: 65,
                                    uniqueKey: _dto.id.toString(),
                                    name: _dto.nameController.text,
                                    imageUrl: userProfileImage,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    // чтобы имя тоже переносилось
                                    child: Text(
                                      _dto.nameController.text,
                                      style: TTTextStyle.title,
                                      // .copyWith(fontSize: 15),
                                      maxLines: 3,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                              if (_dto.isBirthdayToday)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: TTColors.text, width: 1),
                                          color: TTColors.card,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/svg/cake_outlined.svg',
                                          fit: BoxFit.scaleDown,
                                          colorFilter: ColorFilter.mode(
                                            TTColors.text,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(width: 12),
                                      // // тут был баг: Expanded внутри Row, который сам в Row без ограничений
                                      // Flexible(
                                      //   child: Text(
                                      //     'Сьогодні святкує день народження!',
                                      //     style: TTTextStyle.subtitle
                                      //         .copyWith(fontSize: 10),
                                      //     softWrap: true,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                )
                            ]),
                            SizedBox(height: 18),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     Container(
                            //       child: Row(
                            //         children: [
                            //           SvgPicture.asset(
                            //             'assets/svg/location.svg',
                            //             width: 15,
                            //             colorFilter: ColorFilter.mode(
                            //               TTColors.text_secondary,
                            //               BlendMode.srcIn,
                            //             ),
                            //           ),
                            //           const SizedBox(width: 4),
                            //
                            //           Text(
                            //             _dto.citiesText ?? '',
                            //             style: TTTextStyle.subtitle,
                            //             overflow: TextOverflow.ellipsis,
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //     InstagramLink(
                            //       username:
                            //           _dto.instagramNicknameController.text,
                            //     ),
                            //   ],
                            // ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/location.svg',
                                  width: 15,
                                  colorFilter: ColorFilter.mode(
                                    TTColors.text_secondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),

                                // 👇 ВАЖНО: именно этот Expanded ограничивает ширину текста городов
                                Expanded(
                                  child: Text(
                                    _dto.citiesText ?? '',
                                    style: TTTextStyle.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                InstagramLink(
                                  context: context,
                                  username:
                                      _dto.instagramNicknameController.text,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 4),

                                // 👇 ВАЖНО: именно этот Expanded ограничивает ширину текста городов
                                Expanded(
                                  child: Text(''),
                                ),

                                const SizedBox(width: 8),
                                TelegramLink(
                                    context: context,
                                    username:
                                        _dto.telegramNicknameController.text),
                              ],
                            ),
                            SizedBox(height: 18),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/user.svg',
                                  width: 14,
                                  colorFilter: ColorFilter.mode(
                                    TTColors.text,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _dto.occupationDescriptionController.text ==
                                            ''
                                        ? 'Не вказано'
                                        : _dto.occupationDescriptionController
                                            .text,
                                    style: TTTextStyle.subtitle
                                        .copyWith(color: TTColors.text),
                                    softWrap: true, // ✅ разрешаем перенос
                                    overflow: TextOverflow
                                        .visible, // ✅ не обрезаем текст
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Text('ggg', style: TTTextStyle.title),
                        SizedBox(height: 12),
                        // если у юзера нет машин
                        if (_dto.cars.isEmpty) const SizedBox.shrink(),

                        SizedBox(
                          height: screenSize.width *
                              0.72, // высота блока с машинами
                          child: ListView.separated(
                            controller: _carsScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: _dto.cars.length,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final car = _dto.cars[index];
                              // пытаемся вытащить фото
                              final String imageUrl = (car.imageUrls != null &&
                                      car.imageUrls!.isNotEmpty &&
                                      car.imageUrls!.first.url != null)
                                  ? car.imageUrls!.first.url!
                                  : CAR_IMAGE_DEFAULT;

                              return TTNeumorphicBox(
                                padding: EdgeInsets.only(
                                    top: 16, bottom: 24, left: 16, right: 24),
                                width: screenSize.width * 0.83,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CarImageBlock(
                                      height: screenSize.width * 0.43,
                                      imageUrl: imageUrl,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              car.personalizedLicensePlateController
                                                          .text !=
                                                      ''
                                                  ? '${car.personalizedLicensePlateController.text}   |   ${car.licensePlateController.text}'
                                                  : car.licensePlateController
                                                      .text,
                                              style: TTTextStyle.subtitle
                                                  .copyWith(
                                                      color: TTColors.text),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Audi ${car.model.name} ${car.gene.name}',
                                                maxLines: 2,
                                                style: TTTextStyle.subtitle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  // Кольорове коло
                                                  Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        int.parse(car.color.hex
                                                            .replaceFirst(
                                                                '#', '0xff')),
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: TTColors
                                                              .text_secondary,
                                                          width: 1),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  // Назва кольору
                                                  Flexible(
                                                    child: Text(
                                                      car.color.name,
                                                      style:
                                                          TTTextStyle.subtitle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
// TODO каждую машину отрисовать с полной информацией слайдинг горизонтальный
//                   CarImageBlock(
//                     imageUrl: _dto.cars,
//                     isActiveUser: isActiveUser,
//                   ),
                      ],
                    ),
                  ),
          ),
          Expanded(
            flex: 2,
            child: Column(),
          ),
        ],
      ),
    );
  }
}
