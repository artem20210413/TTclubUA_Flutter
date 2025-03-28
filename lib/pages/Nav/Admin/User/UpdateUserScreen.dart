import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/api/routs/Dto/City/CityDto.dart';
import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../Storage/Search/UserSearchDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/cities/city.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/form/CitySelector.dart';
import '../../../../components/form/FormElements.dart';
import '../../../../components/generalModule.dart';

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
    // _getCities();
  }

  // Future<void> _getCities() async {
  //   final token = await UserStorage.getToken();
  //   final resCities = await GET_CITIES(token);
  //
  //   final isSuccessCities = await CHECK_API(resCities, context);
  //   if (!isSuccessCities) return;
  //
  //   final decodedBody = jsonDecode(resCities.body);
  //
  //   setState(() {
  //     cities = ((decodedBody['data']['cities'] ?? []) as List)
  //         .map((json) => CityDto.fromJson(json))
  //         .toList();
  //   });
  // }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print(dto.toJson());
      // final token = await UserStorage.getToken();
      // final res = await UPLOAD_USER(token, _userDTO);
      // final isSuccess = await CHECK_API(res, context);

      // if (isSuccess) {
      //   MessageModule(
      //       context, 'Профіль успішно оновлено!', MessageType.success);
      // }
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
                        maxLines: 5,
                        isEditable: true),
                    // const Text(
                    //   "Міста",
                    //   style:
                    //       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // Column(
                    //   children: List.generate(dto.cities.length, (index) {
                    //     return ListTile(
                    //       trailing: IconButton(
                    //         icon: const Icon(Icons.close, color: Colors.red),
                    //         onPressed: () {
                    //           setState(() {
                    //             dto.cities.removeAt(index);
                    //           });
                    //         },
                    //       ),
                    //       title: Text(dto.cities[index].name),
                    //     );
                    //   }),
                    // ),
                    // const SizedBox(height: 10),
                    // DropdownButtonFormField<String>(
                    //   hint: const Text("Оберіть місто"),
                    //   value: null,
                    //   items: cities
                    //       .map((city) => DropdownMenuItem<String>(
                    //             value: city.name,
                    //             child: Text(city.name),
                    //           ))
                    //       .toList(),
                    //   onChanged: (selectedCityName) {
                    //     if (selectedCityName != null) {
                    //       final selectedCity = cities.firstWhere(
                    //           (city) => city.name == selectedCityName);
                    //       if (!dto.cities.contains(selectedCity)) {
                    //         setState(() {
                    //           dto.cities.add(selectedCity);
                    //         });
                    //       }
                    //     }
                    //   },
                    // ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _saveUser,
                          child: const Text('Зберегти'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
