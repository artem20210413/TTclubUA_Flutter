import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/api/routs/Dto/City/CityDto.dart';
import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';
import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateCarScreen.dart';
import '../../../../Storage/Search/UserSearchDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/cities/city.dart';
import '../../../../api/routs/root.dart';
import '../../../../api/routs/user.dart';
import '../../../../components/form/CitySelector.dart';
import '../../../../components/form/FormElements.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/CarListWidget.dart';
import '../../../../config/default.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserSearchDto dtoSearch;

  UpdateUserScreen({Key? key, required this.dtoSearch}) : super(key: key);

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late UserUpdateDto dto; // Переменная для хранения данных
  final _formKey = GlobalKey<FormState>();

  // List<CityDto> cities = [];

  @override
  void initState() {
    super.initState();
    dto = UserUpdateDto.fromJson(widget.dtoSearch.json);
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print(dto.toJson());
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
                  onTap: () {},
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
                  dto.nameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),


              // CarListWidget(
              //   cars: dto.cars,
              //   isInteractive: true, // или false
              // ),

              CarListWidget(
                cars: dto.cars,
                onCarTap: (car) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateCarScreen(carDto: car),
                    ),
                  );
                },
                onAddTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateCarScreen(),
                    ),
                  );
                },
              ),


              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 15),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       SizedBox(
              //         height: 180, // Высота карточки машины
              //         child: ListView.builder(
              //           scrollDirection: Axis.horizontal,
              //           itemCount: dto.cars.length + 1,
              //           itemBuilder: (context, index) {
              //             if (index == dto.cars.length) {
              //               return Padding(
              //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //                 child: GestureDetector(
              //                   onTap: () {
              //                     // Открыть экран добавления авто
              //                     Navigator.push(
              //                       context,
              //                       MaterialPageRoute(builder: (context) => UpdateCarScreen()),
              //                     );
              //                   },
              //                   child: Container(
              //                     width: 150,
              //                     decoration: BoxDecoration(
              //                       borderRadius: BorderRadius.circular(12),
              //                       color: Colors.white,
              //                       boxShadow: [
              //                         BoxShadow(color: Colors.black12, blurRadius: 5),
              //                       ],
              //                     ),
              //                     child: Column(
              //                       mainAxisAlignment: MainAxisAlignment.center,
              //                       children: [
              //                         Icon(Icons.add, size: 50, color: Colors.black),
              //                         SizedBox(height: 10),
              //                         Text(
              //                           "Додати авто",
              //                           textAlign: TextAlign.center,
              //                           style: TextStyle(fontWeight: FontWeight.bold),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //               );
              //             }
              //
              //             final car = dto.cars[index];
              //             return Padding(
              //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //               child: GestureDetector(
              //                 onTap: () {
              //                   MessageModule(
              //                       context, 'Скоро буде створеня авто ..', MessageType.success);
              //                   // Действие при клике (например, переход на экран с деталями авто)
              //                   // Navigator.push(
              //                   //   context,
              //                   //   MaterialPageRoute(builder: (context) => CarDetailScreen(car: car)),
              //                   // );
              //                 },
              //                 child: Container(
              //                   width: 150,
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.circular(12),
              //                     color: Colors.white,
              //                     boxShadow: [
              //                       BoxShadow(color: Colors.black12, blurRadius: 5),
              //                     ],
              //                   ),
              //                   child: Column(
              //                     children: [
              //                       ClipRRect(
              //                         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              //                         child: Image.network(
              //                           car.imageUrls.isNotEmpty && car.imageUrls.first?.url != null
              //                               ? car.imageUrls.first!.url
              //                               : CAR_IMAGE_DEFAULT,
              //                           width: 150,
              //                           height: 120,
              //                           fit: BoxFit.cover,
              //                         ),
              //                       ),
              //                       Padding(
              //                         padding: const EdgeInsets.all(8.0),
              //                         child: Text(
              //                           "${car.model.name} ${car.gene.name} ${car.generalLicensePlate}",
              //                           textAlign: TextAlign.center,
              //                           style: TextStyle(fontWeight: FontWeight.bold),
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             );
              //
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

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
            ],
          ),
        ),
      ),
    );
  }
}
