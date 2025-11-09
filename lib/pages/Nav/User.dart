import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/api/routs/user.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Admin.dart';

import '../../api/routs/Dto/Car/CarDto.dart';
import '../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../api/routs/car/car.dart';
import '../../components/TTLoading.dart';
import '../../components/TTNeumorphicBox.dart';
import '../../components/buttons/CircleButton.dart';
import '../../components/buttons/GlowingButton.dart';
import '../../components/card/CarImageBlock.dart';
import '../../components/card/UserAvatar.dart';
import '../../components/inputs/BigTextInput.dart';
import '../../components/viewers/ChangePasswordSection.dart';
import '../../components/viewers/InstagramLink.dart';
import '../../components/viewers/PickAndCropImage.dart';
import '../../components/viewers/TelegramLink.dart';
import 'Admin/User/FinanceScreen.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  late UserUpdateDto _dto;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  bool _isAdmin = false;

  String userProfileImage = USER_PROFILE_IMAGE_DEFAULT;

  late final ScrollController _carsScrollController;

  void initState() {
    super.initState();

    _carsScrollController = ScrollController();
    _load();
  }

  @override
  void dispose() {
    _carsScrollController.dispose();
    super.dispose();
  }

  @override
  Future<void> _load() async {
    await UserStorage.checkAndUpdate();
    final profileImage = await UserStorage.getProfileImagee();
    final dynamic json = await UserStorage.getUserInfo();
    final isAdmin = await UserStorage.isAdmin();
    // final isAdmin = await UserStorage.whereInRole([UserRole.admin]);

    setState(() {
      _dto = UserUpdateDto.fromJson(json);

      userProfileImage = profileImage ?? userProfileImage;
      _isAdmin = isAdmin;
    });

    setState(() {
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _runCarsHintScroll();
    });
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

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final token = await UserStorage.getToken();
      final res = await UPLOAD_USER(token, _dto);
      final isSuccess = await CHECK_API(res, context);

      if (isSuccess) {
        UserStorage.saveUserInfo(json.decode(res.body)['data']['user']);
        MessageModule(
            context, 'Профіль успішно оновлено!', MessageType.success);
      }
    }
  }

  Future<void> _logout() async {
    await UserStorage.clearUserInfo();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _pickAndUploadImage() async {
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: 1,
    );

    if (croppedFile == null) return;

    final token = await UserStorage.getToken();
    final res = await UPLOAD_USER_PHOTO(token, croppedFile.path);
    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      final newImageUrl = jsonDecode(res.body)['data']['profile_image'];
      setState(() {
        userProfileImage = newImageUrl;
      });
    }
  }

  Future<String?> _pickAndUploadImageCar(CarDto car) async {
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: 1,
    );

    if (croppedFile == null) return null;

    final token = await UserStorage.getToken();
    final res = await UPLOAD_CAR_BY_ID(token, car);
    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      return jsonDecode(res.body)['data']['imageUrls'][0] ?? null;
    }
    return null;
  }

  // String _formatDate(String rawDate) {
  //   if (rawDate.isEmpty) return '—';
  //   try {
  //     return DateFormat('dd.MM.yyyy').format(DateTime.parse(rawDate));
  //   } catch (_) {
  //     return rawDate;
  //   }
  // }

  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return _isLoading
        ? const TTLoading()
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20, right: 20, bottom: 110, left: 20),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, bottom: 20),
                                      child: UserAvatar(
                                        radius: 65,
                                        name: _dto.nameController.text,
                                        imageUrl: userProfileImage,
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: CircleButton(
                                        iconAsset: 'assets/svg/image_add.svg',
                                        onTap: _pickAndUploadImage,
                                      ),
                                    )
                                  ],
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
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Row(
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
                                Text(
                                  _dto.citiesText ?? '',
                                  style: TTTextStyle.subtitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          InstagramLink(
                            username: _dto.instagramNicknameController.text,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/phone.svg',
                                  height: 15,
                                  colorFilter: ColorFilter.mode(
                                    TTColors.text_secondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _dto.phoneController.text ?? '',
                                  style: TTTextStyle.subtitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TelegramLink(
                            username: _dto.telegramNicknameController.text,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/cake_outlined.svg',
                                  height: 15,
                                  colorFilter: ColorFilter.mode(
                                    TTColors.text_secondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _dto.birthDateController.text ?? '',
                                  style: TTTextStyle.subtitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: BigTextInput(
                                  controller:
                                      _dto.occupationDescriptionController,
                                  hint: 'Яка твоя сфера діяльності?',
                                  minHeight: 50,
                                  minLines: 1,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CircleButton(
                                  size: 65,
                                  iconAsset: 'assets/svg/check_mark.svg',
                                  onTap: _saveUser,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Text('ggg', style: TTTextStyle.title),
                  SizedBox(height: 12),
                  // if (_dto.cars.isEmpty) const SizedBox.shrink(),
                  if (!_dto.cars.isEmpty)
                    SizedBox(
                      height:
                          screenSize.width * 0.78, // высота блока с машинами
                      child: ListView.separated(
                        controller: _carsScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _dto.cars.length,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final car = _dto.cars[index];
                          // пытаемся вытащить фото
                          String imageUrl = (car.imageUrls != null &&
                                  car.imageUrls!.isNotEmpty &&
                                  car.imageUrls!.first.url != null)
                              ? car.imageUrls!.first.url!
                              : CAR_IMAGE_DEFAULT;

                          return TTNeumorphicBox(
                            padding: EdgeInsets.only(
                                top: 16, bottom: 24, left: 16, right: 24),
                            width: screenSize.width * 0.9,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CarImageBlock(
                                      height: screenSize.width * 0.45,
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
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleButton(
                                    iconAsset: 'assets/svg/image_add.svg',
                                    onTap: () async {
                                      // final newImageUrl =
                                      //     await _pickAndUploadImageCar(car);
                                      // if (newImageUrl != null) {
                                      //   setState(() {
                                      //     imageUrl = newImageUrl;
                                      //   });
                                      // }
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: ChangePasswordSection(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GlowingButton(
                          text: 'Вихід',
                          colorGrowing: Colors.white,
                          onPressed: () {
                            _logout();
                          },
                          // isLoading: _isLoadingSubmit,
                        ),
                      ),
                      if (_isAdmin)
                        Expanded(
                          flex: 3,
                          child: GlowingButton(
                            margin: EdgeInsets.only(left: 15),
                            text: 'Для адміна',
                            colorGrowing: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Admin(),
                                ), // Переход на экран публикаций
                              );
                            },
                            // isLoading: _isLoadingSubmit,
                          ),
                        ),
                    ],
                  ),

                  // TileButton(
                  //   icon: Icons.payment_outlined,
                  //   title: 'Фінанси',
                  //   onTap: () {
                  //
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => FinanceScreen(userDto: _dto),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          );
  }
}
