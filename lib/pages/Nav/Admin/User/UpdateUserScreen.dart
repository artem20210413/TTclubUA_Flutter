import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/Storage/Search/UserSearchDto.dart';
import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Car/CarDto.dart';
import 'package:tt_club_ua/api/routs/user.dart';
import 'package:tt_club_ua/api/routs/root.dart';

import 'package:tt_club_ua/components/layout/TTScaffold.dart';
import 'package:tt_club_ua/components/inputs/CustomInputField.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';
import 'package:tt_club_ua/components/interface/CarListWidget.dart';
import 'package:tt_club_ua/components/interface/TileButton.dart';
import 'package:tt_club_ua/components/viewers/PickAndCropImage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/Storage/Cache/AccentColorCache.dart';

import '../../../../components/inputs/BigTextInput.dart';
import '../../../../components/inputs/CitiesPicker.dart';
import '../../../../components/inputs/TTFormField.dart';
import 'ChangePasswordScreen.dart';
import 'FinanceScreen.dart';
import 'UpdateCarScreen.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserSearchDto dtoSearch;

  UpdateUserScreen({Key? key, required this.dtoSearch}) : super(key: key);

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late UserUpdateDto dto;
  List<dynamic> _allRoles = []; // Список ролей з API
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;
  late Color accentColor;

  @override
  void initState() {
    super.initState();
    accentColor = AccentColorCache.accentColor;
    dto = UserUpdateDto.fromJson(widget.dtoSearch.json);
    _fetchUser();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final token = await UserStorage.getToken();
      final res = await ROLES(token, dto.id);

      if (res.statusCode == 200) {
        setState(() {
          _allRoles = jsonDecode(res.body)['data'];
        });
      }
    } catch (e) {
      print('Помилка завантаження ролей: $e');
    }
  }

  Future<void> _fetchUser() async {
    try {
      final token = await UserStorage.getToken();
      final resUs = await USER_FIND(token, widget.dtoSearch.json['id']);
      if (mounted) {
        setState(() {
          dto = UserUpdateDto.fromJson(jsonDecode(resUs.body)['data']);
        });
      }
    } catch (e) {
      print('Помилка завантаження користувача: $e');
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isSaving = true);

      final token = await UserStorage.getToken();
      final res = await UPLOAD_USER_BY_ID(token, dto);
      final isSuccess = await CHECK_API(res, context);

      if (isSuccess) {
        MessageModule(
            context, 'Профіль успішно оновлено!', MessageType.success);
        _fetchUser();
      }
      setState(() => isSaving = false);
    }
  }

  Future<void> _changeActiveUser() async {
    final token = await UserStorage.getToken();
    final res = await CHANGE_ACTIVE_USER(token, dto.id);
    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      MessageModule(context, 'Статус змінено!', MessageType.success);
      _fetchUser();
    }
  }

  Future<void> _pickAndUploadImage() async {
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: 1,
    );

    if (croppedFile != null) {
      final token = await UserStorage.getToken();
      final res =
          await UPLOAD_USER_PHOTO_BY_ID(token, dto.id, croppedFile.path);
      if (await CHECK_API(res, context)) {
        var newUrl = jsonDecode(res.body)['data']['profile_image'];
        setState(() => dto.profileImage = newUrl);
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    DateTime? birthDate = null;
    // если уже есть дата в формате YYYY-MM-DD — попробуем распарсить
    final raw = dto.birthDateController.text.trim();
    if (raw.isNotEmpty) {
      try {
        // print(raw);
        // birthDate = DateTime.parse(raw); //05-01-2001
        birthDate = DateFormat('dd-MM-yyyy').parse(raw);
      } catch (_) {}
    }
    DateTime initial = birthDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      dto.birthDateController.text = '${picked.year}-$mm-$dd';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: "Редагування профілю",
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар та ID
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accentColor, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(dto.profileImage),
                              backgroundColor: TTColors.card,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '#${dto.id} ${dto.nameController.text}',
                      style: TTTextStyle.title,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dto.active ? 'Активний профіль' : 'Деактивовано',
                      style: TTTextStyle.caption.copyWith(
                        color: dto.active ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              CarListWidget(
                cars: dto.cars,
                onCarTap: (car) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          UpdateCarScreen(userDto: dto, carDto: car)),
                ).then((_) => _fetchUser()),
                onAddTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UpdateCarScreen(
                          userDto: dto, carDto: CarDto.empty())),
                ).then((_) => _fetchUser()),
              ),

              const SizedBox(height: 32),
              CustomInputField(
                controller: dto.nameController,
                label: 'Ім\'я',
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: dto.emailController,
                label: 'Пошта',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: dto.phoneController,
                label: 'Телефон',
                readOnly: true, // як у твоєму коді isEditable: false
              ),

              const SizedBox(height: 24),
              CustomInputField(
                controller: dto.instagramNicknameController,
                label: 'Instagram Nickname',
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: dto.telegramNicknameController,
                label: 'Telegram Nickname',
              ),

              const SizedBox(height: 24),
              TTFormField(
                label: "Дата народження",
                hint: "YYYY-MM-DD",
                controller: dto.birthDateController,
                readOnly: true,
                onTap: _pickBirthDate,
                suffix:
                    Icon(Icons.calendar_month, color: TTColors.text_secondary),
              ),
              // CustomInputField(
              //   controller: dto.birthDateController,
              //   label: 'Дата народження',
              //   readOnly: true,
              //   onTap: () { /* Твоя логіка вибору дати */ },
              // ),
              const SizedBox(height: 16),
              UserCitiesPicker(
                currentCities: dto.cities,
                onChanged: (newCities) {
                  setState(() {
                    dto.cities = newCities;
                  });
                },
              ),
              const SizedBox(height: 16),
              BigTextInput(
                controller: dto.occupationDescriptionController,
                label: 'Рід діяльності',
                minHeight: 50,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              BigTextInput(
                controller: dto.whyTTController,
                label: 'Чому ТТ',
                minHeight: 30,
                maxLines: 2,
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ролі користувача',
                          style: TTTextStyle.title18
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.info_outline, color: accentColor, size: 22),
                    onPressed: _showRolesHelp,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Мультивибір через Wrap
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _allRoles.map((role) {
                  final String roleSlug = role['alias'] ??
                      role['slug']; // перевір що приходить з API
                  final bool isSelected = dto.roles.contains(roleSlug);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          dto.roles.remove(roleSlug);
                        } else {
                          dto.roles.add(roleSlug);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? accentColor : Colors.white10,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        role['name'],
                        style: TTTextStyle.caption.copyWith(
                          color: isSelected
                              ? Colors.white
                              : TTColors.text_secondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              GlowingButton(
                text: isSaving ? 'Збереження...' : 'Зберегти зміни',
                colorGrowing: accentColor,
                onPressed: isSaving ? () {} : _saveUser,
              ),

              const SizedBox(height: 16),
              // Кнопка активації/деактивації
              GlowingButton(
                text:
                    dto.active ? 'Деактивувати аккаунт' : 'Активувати аккаунт',
                colorGrowing: dto.active ? Colors.redAccent : Colors.green,
                onPressed: _changeActiveUser,
              ),

              const SizedBox(height: 32),
              TileButton(
                icon: Icons.payment_outlined,
                title: 'Фінанси користувача',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FinanceScreen(userId: dto.id))),
              ),
              const SizedBox(height: 12),
              TileButton(
                icon: Icons.lock_reset,
                title: 'Змінити пароль',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChangePasswordScreen(userDto: dto))),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showRolesHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TTColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Довідка по ролях', style: TTTextStyle.title18),
                const Icon(Icons.info, color: Colors.white24),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: _allRoles
                      .map((role) =>
                          _buildRoleInfoItem(role['name'], role['description']))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GlowingButton(
              text: 'Зрозуміло',
              onPressed: () => Navigator.pop(context),
              colorGrowing: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleInfoItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TTTextStyle.subtitle
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc,
                    style: TTTextStyle.caption
                        .copyWith(color: TTColors.text_secondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tt_club_ua/Storage/UserDto.dart';
// import 'package:tt_club_ua/api/routs/Dto/City/CityDto.dart';
// import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';
// import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateCarScreen.dart';
// import '../../../../Storage/Search/UserSearchDto.dart';
// import '../../../../Storage/UserStorage.dart';
// import '../../../../api/routs/Dto/Car/CarDto.dart';
// import '../../../../api/routs/cities/city.dart';
// import '../../../../api/routs/root.dart';
// import '../../../../api/routs/user.dart';
// import '../../../../components/form/CitySelector.dart';
// import '../../../../components/form/FormElements.dart';
// import '../../../../components/generalModule.dart';
// import '../../../../components/interface/CarListWidget.dart';
// import '../../../../components/interface/TileButton.dart';
// import '../../../../components/viewers/PickAndCropImage.dart';
// import 'ChangePasswordScreen.dart';
// import 'FinanceScreen.dart';
//
// class UpdateUserScreen extends StatefulWidget {
//   final UserSearchDto dtoSearch;
//
//   UpdateUserScreen({Key? key, required this.dtoSearch}) : super(key: key);
//
//   @override
//   _UpdateUserScreenState createState() => _UpdateUserScreenState();
// }
//
// class _UpdateUserScreenState extends State<UpdateUserScreen> {
//   late UserUpdateDto dto; // Переменная для хранения данных
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();
//
//   // List<CityDto> cities = [];
//
//   @override
//   void initState() {
//     super.initState();
//     dto = UserUpdateDto.fromJson(widget.dtoSearch.json);
//     _fetchUser();
//   }
//
//   Future<void> _saveUser() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//
//       final token = await UserStorage.getToken();
//       final res = await UPLOAD_USER_BY_ID(token, dto);
//       final isSuccess = await CHECK_API(res, context);
//
//       if (isSuccess) {
//         final data = jsonDecode(res.body)['data'];
//         setState(() {
//           dto = UserUpdateDto.fromJson(data['user']);
//         });
//         MessageModule(
//             context, 'Профіль успішно оновлено!', MessageType.success);
//       }
//     }
//   }
//
//   Future<void> _fetchUser() async {
//     try {
//       final token = await UserStorage.getToken();
//       final resUs = await USER_FIND(token, widget.dtoSearch.json['id']);
//
//       setState(() {
//         dto = new UserUpdateDto.fromJson(jsonDecode(resUs.body)['data']);
//         // customBannerUrl = widget.carDto.imageUrls.length > 0
//         //     ? widget.carDto.imageUrls.first.url
//         //     : CAR_IMAGE_DEFAULT;
//       });
//     } catch (e) {
//       print('Ошибка загрузки _fetchCar: $e');
//     }
//   }
//
//   Future<void> _changeActiveUser() async {
//     final token = await UserStorage.getToken();
//     final res = await CHANGE_ACTIVE_USER(token, dto.id);
//     final isSuccess = await CHECK_API(res, context);
//
//     if (isSuccess) {
//       final data = jsonDecode(res.body)['data'];
//       setState(() {
//         dto = UserUpdateDto.fromJson(data['user']);
//       });
//
//       MessageModule(context, 'Профіль успішно оновлено!', MessageType.success);
//     }
//   }
//
//   Future<void> _pickAndUploadImage() async {
//     final File? croppedFile = await pickAndCropImage(
//       context: context,
//       aspectRatio: 1,
//     );
//
//     // final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//
//     if (croppedFile != null) {
//       File imageFile = File(croppedFile.path);
//
//       final token = await UserStorage.getToken();
//       final res = await UPLOAD_USER_PHOTO_BY_ID(token, dto.id, imageFile.path);
//       bool isSuccess = await CHECK_API(res, context);
//       if (isSuccess) {
//         var newImageUrl = jsonDecode(res.body)['data']['profile_image'];
//         setState(() {
//           dto.profileImage = newImageUrl;
//         });
//       }
//     }
//   }
//
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Оновлення"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         // Добавляем прокрутку
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     _pickAndUploadImage();
//                   },
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 70,
//                         backgroundImage: NetworkImage(dto.profileImage),
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
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: Text(
//                   '#' + dto.id.toString() + ' ' + dto.nameController.text,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               CarListWidget(
//                 cars: dto.cars,
//                 onCarTap: (car) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           UpdateCarScreen(userDto: dto, carDto: car),
//                     ),
//                   );
//                 },
//                 onAddTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           UpdateCarScreen(userDto: dto, carDto: CarDto.empty()),
//                     ),
//                   );
//                 },
//               ),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     customBuildTextField(
//                         'Ім\'я', dto.nameController, customValidatorDefault,
//                         isEditable: true),
//                     customBuildTextField(
//                         'Пошта', dto.emailController, customValidatorDefault,
//                         keyboardType: TextInputType.emailAddress,
//                         isEditable: true),
//                     customBuildPhoneField('Телефон', dto.phoneController,
//                         isEditable: false),
//                     customBuildTextField(
//                         'Інстаграм', dto.instagramNicknameController, null,
//                         isEditable: true),
//                     customBuildTextField(
//                         'Телеграм', dto.telegramNicknameController, null,
//                         isEditable: true),
//                     customBuildDatePickerField(
//                         'Дата народження', dto.birthDateController, context,
//                         isEditable: true),
//                     CitySelector(
//                       selectedCities: dto.cities,
//                       onCityAdd: (CityDto city) {
//                         setState(() {
//                           dto.cities.add(city);
//                         });
//                       },
//                       onCityRemove: (int index) {
//                         setState(() {
//                           dto.cities.removeAt(index);
//                         });
//                       },
//                     ),
//                     customBuildTextField(
//                         'Рід діяльності',
//                         dto.occupationDescriptionController,
//                         customValidatorDefault,
//                         maxLines: 3,
//                         isEditable: true),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Spacer(),
//                   ElevatedButton(
//                     onPressed: _changeActiveUser,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: dto.active
//                           ? Colors.redAccent // Нежный красный
//                           : Colors.lightGreen.shade700, // Нежный зеленый
//                       foregroundColor: Colors.white, // Цвет текста
//                     ),
//                     child:
//                         dto.active ? Text('Деактивувати') : Text('Активувати'),
//                   ),
//                   Spacer(),
//                   ElevatedButton(
//                     onPressed: _saveUser,
//                     child: const Text('Зберегти'),
//                   ),
//                   Spacer(),
//                 ],
//               ),
//
//               TileButton(
//                 icon: Icons.payment_outlined,
//                 title: 'Фінанси',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FinanceScreen(userId: dto.id),
//                     ),
//                   );
//                 },
//               ),
//               TileButton(
//                 icon: Icons.lock_reset,
//                 title: 'Зміна пароля',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChangePasswordScreen(userDto: dto),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
