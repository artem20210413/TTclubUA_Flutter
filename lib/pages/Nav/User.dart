import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/components/form/FormElements.dart';
import 'package:tt_club_ua/api/routs/user.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../Storage/CityDto.dart';
import '../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../api/routs/cities/CityServices.dart';
import '../../components/TTLoading.dart';
import '../../components/TTNeumorphicBox.dart';
import '../../components/buttons/CircleButton.dart';
import '../../components/card/CarImageBlock.dart';
import '../../components/card/UserAvatar.dart';
import '../../components/inputs/BigTextInput.dart';
import '../../components/interface/TileButton.dart';
import '../../components/viewers/InstagramLink.dart';
import 'Admin/User/FinanceScreen.dart';
import 'User/ChangePasswordPage.dart';

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
  UserDTO _userDTO = UserDTO();
  bool isOne = true;

  String userProfileImage = USER_PROFILE_IMAGE_DEFAULT;

  void initState() {
    super.initState();
    _load();
  }

  @override
  Future<void> _load() async {
    await UserStorage.checkAndUpdate();
    final profileImage = await UserStorage.getProfileImagee();
    final dynamic json = await UserStorage.getUserInfo();

    setState(() {
      _dto = UserUpdateDto.fromJson(json);
      _userDTO = UserDTO.fromJson(json);
      isOne = _dto.cars.length == 1;

      userProfileImage = profileImage ?? userProfileImage;
    });

    // await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final token = await UserStorage.getToken();
      final res = await UPLOAD_USER_PHOTO(token, imageFile.path);
      bool isSuccess = await CHECK_API(res, context);
      if (isSuccess) {
        var newImageUrl = jsonDecode(res.body)['data']['profile_image'];
        setState(() {
          userProfileImage = newImageUrl;
        });
      }
    }
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '—';
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return _isLoading
        ? const TTLoading()
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TTNeumorphicBox(
                    padding: EdgeInsets.only(
                        top: 12, bottom: 4, left: 16, right: 24),
                    child: Column(
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
                                      UserAvatar(
                                        radius: 65,
                                        name: _dto.nameController.text,
                                        imageUrl: userProfileImage,
                                      ),
                                      Positioned(
                                          left: 0,
                                          bottom: 0,
                                          child: CircleButton(
                                            size: 65,
                                            iconAsset:
                                                'assets/svg/image_add.svg',
                                            onTap: () => {},
                                          ))
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
                        SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: BigTextInput(
                              // controller: _dto.occupationDescriptionController,
                              controller: _dto.occupationDescriptionController,
                              hint: 'Яка твоя сфера діяльності?',
                              minHeight: 50,
                              minLines: 1,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [],
                              ),
                            ),
                            CircleButton(
                              size: 65,
                              iconAsset: 'assets/svg/check_mark.svg',
                              onTap: _saveUser,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Text('ggg', style: TTTextStyle.title),
                  SizedBox(height: 12),
                  // если у юзера нет машин
                  if (_dto.cars.isEmpty) const SizedBox.shrink(),

                  SizedBox(
                    height: screenSize.width * 0.72, // высота блока с машинами
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dto.cars.length,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                          width: screenSize.width * (isOne ? 0.9 : 0.8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CarImageBlock(
                                height: screenSize.width * (isOne ? 0.45 : 0.4),
                                imageUrl: imageUrl,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        car.personalizedLicensePlateController
                                                    .text !=
                                                ''
                                            ? '${car.personalizedLicensePlateController.text}   |   ${car.licensePlateController.text}'
                                            : car.licensePlateController.text,
                                        style: TTTextStyle.subtitle
                                            .copyWith(color: TTColors.text),
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
                                                    color:
                                                        TTColors.text_secondary,
                                                    width: 1),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Назва кольору
                                            Flexible(
                                              child: Text(
                                                car.color.name,
                                                style: TTTextStyle.subtitle,
                                                overflow: TextOverflow.ellipsis,
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
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordPage()),
                      );
                    },
                    child: const Text('Змінити пароль'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B0000),
                    ),
                    child: const Text(
                      'Вихід',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
    // return Padding(
    //   padding: const EdgeInsets.all(16.0),
    //   child: _isLoading
    //       ? Column(
    //           children: [
    //             Row(
    //               children: [
    //                 ElevatedButton(
    //                   onPressed: () {
    //                     _logout();
    //                   },
    //                   style: ElevatedButton.styleFrom(
    //                     backgroundColor: Colors.grey,
    //                   ),
    //                   child: const Text(
    //                     'Вихід',
    //                     style: TextStyle(color: Colors.white),
    //                   ),
    //                 ),
    //                 Spacer(),
    //               ],
    //             ),
    //             Spacer(),
    //             CenterLoadingModule,
    //             Spacer(),
    //           ],
    //         )
    //       : Form(
    //           key: _formKey,
    //           child: SingleChildScrollView(
    //             child: Column(
    //               children: [
    //                 GestureDetector(
    //                   onTap: _pickAndUploadImage,
    //                   child: Stack(
    //                     alignment: Alignment.center,
    //                     children: [
    //                       CircleAvatar(
    //                         radius: 70,
    //                         backgroundImage: NetworkImage(userProfileImage),
    //                         backgroundColor: Colors.grey[200],
    //                       ),
    //                       Positioned(
    //                         bottom: 0,
    //                         right: 0,
    //                         child: CircleAvatar(
    //                           radius: 15,
    //                           backgroundColor: Colors.black87,
    //                           child: const Icon(
    //                             Icons.edit,
    //                             color: Colors.white,
    //                             size: 18,
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(height: 16),
    //                 Text(
    //                   _nameController.text,
    //                   style: const TextStyle(
    //                     fontSize: 24,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 8),
    //                 TileButton(
    //                   icon: Icons.payment_outlined,
    //                   title: 'Фінанси',
    //                   onTap: () {
    //
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (context) => FinanceScreen(userDto: _dto),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //                 const SizedBox(height: 8),
    //                 Card(
    //                   margin: const EdgeInsets.all(12),
    //                   elevation: 4,
    //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //                   child: Padding(
    //                     padding: const EdgeInsets.all(16),
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         _buildRow('👤 Імʼя', _dto.nameController.text),
    //                         _buildRow('📞 Телефон', _dto.phoneController.text),
    //                         // _buildRow('📧 Email', _dto.emailController.text),
    //                         _buildRow('🎂 Дата народження', _formatDate(_dto.birthDateController.text)),
    //                         _buildRow('💼 Професія', _dto.occupationDescriptionController.text),
    //                         _buildRow('Instagram', _dto.instagramNicknameController.text),
    //                         _buildRow('Telegram', _dto.telegramNicknameController.text),
    //                         _buildRow('Міста', _dto.cities.map((c) => c.name).join(', ')),
    //                         const SizedBox(height: 10),
    //                         Row(
    //                           children: [
    //                             const Text('Статус:'),
    //                             const SizedBox(width: 8),
    //                             Chip(
    //                               label: Text(_dto.active ? 'Активний' : 'Неактивний'),
    //                               backgroundColor: _dto.active ? Colors.green.shade100 : Colors.red.shade100,
    //                               labelStyle: TextStyle(
    //                                 color: _dto.active ? Colors.green : Colors.red,
    //                                 fontWeight: FontWeight.bold,
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 20),
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   // Выравнивание по горизонтали
    //                   // crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по вертикали
    //                   children: [
    //                     // ElevatedButton(
    //                     //   onPressed: _saveUser,
    //                     //   child: const Text('Зберегти'),
    //                     // ),
    //                     Spacer(),
    //                     ElevatedButton(
    //                       onPressed: () {
    //                         Navigator.push(
    //                           context,
    //                           MaterialPageRoute(
    //                               builder: (context) => ChangePasswordPage()),
    //                         );
    //                       },
    //                       child: const Text('Змінити пароль'),
    //                     ),
    //                     Spacer(),
    //                     ElevatedButton(
    //                       onPressed: () {
    //                         _logout();
    //                       },
    //                       style: ElevatedButton.styleFrom(
    //                         backgroundColor: Color(0xFF8B0000),
    //                       ),
    //                       child: const Text(
    //                         'Вихід',
    //                         style: TextStyle(color: Colors.white),
    //                       ),
    //                     ),
    //                     Spacer(),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    // );
  }
}
