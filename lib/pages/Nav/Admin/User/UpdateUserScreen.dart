import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/api/routs/Dto/City/CityDto.dart';
import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';
import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateCarScreen.dart';
import '../../../../Storage/Search/UserSearchDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Car/CarDto.dart';
import '../../../../api/routs/cities/city.dart';
import '../../../../api/routs/root.dart';
import '../../../../api/routs/user.dart';
import '../../../../components/form/CitySelector.dart';
import '../../../../components/form/FormElements.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/CarListWidget.dart';
import '../../../../components/interface/TileButton.dart';
import '../../../../components/viewers/PickAndCropImage.dart';
import 'ChangePasswordScreen.dart';
import 'FinanceScreen.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserSearchDto dtoSearch;

  UpdateUserScreen({Key? key, required this.dtoSearch}) : super(key: key);

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late UserUpdateDto dto; // Переменная для хранения данных
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // List<CityDto> cities = [];

  @override
  void initState() {
    super.initState();
    dto = UserUpdateDto.fromJson(widget.dtoSearch.json);
    _fetchUser();
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final token = await UserStorage.getToken();
      final res = await UPLOAD_USER_BY_ID(token, dto);
      final isSuccess = await CHECK_API(res, context);

      if (isSuccess) {
        final data = jsonDecode(res.body)['data'];
        setState(() {
          dto = UserUpdateDto.fromJson(data['user']);
        });
        MessageModule(
            context, 'Профіль успішно оновлено!', MessageType.success);
      }
    }
  }

  Future<void> _fetchUser() async {
    try {
      final token = await UserStorage.getToken();
      final resUs = await USER_FIND(token, widget.dtoSearch.json['id']);

      setState(() {
        dto = new UserUpdateDto.fromJson(jsonDecode(resUs.body)['data']);
        // customBannerUrl = widget.carDto.imageUrls.length > 0
        //     ? widget.carDto.imageUrls.first.url
        //     : CAR_IMAGE_DEFAULT;
      });
    } catch (e) {
      print('Ошибка загрузки _fetchCar: $e');
    }
  }

  Future<void> _changeActiveUser() async {
    final token = await UserStorage.getToken();
    final res = await CHANGE_ACTIVE_USER(token, dto.id);
    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      final data = jsonDecode(res.body)['data'];
      setState(() {
        dto = UserUpdateDto.fromJson(data['user']);
      });

      MessageModule(context, 'Профіль успішно оновлено!', MessageType.success);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: 1,
    );

    // final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);

      final token = await UserStorage.getToken();
      final res = await UPLOAD_USER_PHOTO_BY_ID(token, dto.id, imageFile.path);
      bool isSuccess = await CHECK_API(res, context);
      if (isSuccess) {
        var newImageUrl = jsonDecode(res.body)['data']['profile_image'];
        setState(() {
          dto.profileImage = newImageUrl;
        });
      }
    }
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Оновлення"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Добавляем прокрутку
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    _pickAndUploadImage();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(dto.profileImage),
                        backgroundColor: Colors.grey[200],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.black87,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '#' + dto.id.toString() + ' ' + dto.nameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CarListWidget(
                cars: dto.cars,
                onCarTap: (car) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateCarScreen(userDto: dto, carDto: car),
                    ),
                  );
                },
                onAddTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateCarScreen(userDto: dto, carDto: CarDto.empty()),
                    ),
                  );
                },
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    customBuildTextField(
                        'Ім\'я', dto.nameController, customValidatorDefault,
                        isEditable: true),
                    customBuildTextField(
                        'Пошта', dto.emailController, customValidatorDefault,
                        keyboardType: TextInputType.emailAddress,
                        isEditable: true),
                    customBuildPhoneField('Телефон', dto.phoneController,
                        isEditable: false),
                    customBuildTextField(
                        'Інстаграм', dto.instagramNicknameController, null,
                        isEditable: true),
                    customBuildTextField(
                        'Телеграм', dto.telegramNicknameController, null,
                        isEditable: true),
                    customBuildDatePickerField(
                        'Дата народження', dto.birthDateController, context,
                        isEditable: true),
                    CitySelector(
                      selectedCities: dto.cities,
                      onCityAdd: (CityDto city) {
                        setState(() {
                          dto.cities.add(city);
                        });
                      },
                      onCityRemove: (int index) {
                        setState(() {
                          dto.cities.removeAt(index);
                        });
                      },
                    ),
                    customBuildTextField(
                        'Рід діяльності',
                        dto.occupationDescriptionController,
                        customValidatorDefault,
                        maxLines: 3,
                        isEditable: true),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  ElevatedButton(
                    onPressed: _changeActiveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dto.active
                          ? Colors.redAccent // Нежный красный
                          : Colors.lightGreen.shade700, // Нежный зеленый
                      foregroundColor: Colors.white, // Цвет текста
                    ),
                    child:
                        dto.active ? Text('Деактивувати') : Text('Активувати'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _saveUser,
                    child: const Text('Зберегти'),
                  ),
                  Spacer(),
                ],
              ),

              TileButton(
                icon: Icons.payment_outlined,
                title: 'Фінанси',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinanceScreen(userDto: dto),
                    ),
                  );
                },
              ),
              TileButton(
                icon: Icons.lock_reset,
                title: 'Зміна пароля',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(userDto: dto),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
