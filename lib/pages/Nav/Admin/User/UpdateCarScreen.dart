import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/api/routs/Dto/Car/ColorDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Car/ModelDto.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Car/CarDto.dart';
import '../../../../api/routs/Dto/Car/GeneDto.dart';
import '../../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../api/routs/car/car.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/form/FormElements.dart';
import '../../../../components/generalModule.dart';

import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class UpdateCarScreen extends StatefulWidget {
  CarDto carDto;
  UserUpdateDto userDto;

  UpdateCarScreen({Key? key, required this.carDto, required this.userDto})
      : super(key: key);

  @override
  _UpdateCarScreenState createState() => _UpdateCarScreenState();
}

class _UpdateCarScreenState extends State<UpdateCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _licensePlateController = TextEditingController();
  List<GeneDto> _genes = [];
  List<ModelDto> _models = [];
  List<ColorDto> _colors = [];
  String customBannerUrl = CAR_IMAGE_DEFAULT;
  final ImagePicker _picker = ImagePicker();
  final _cropController = CropController();
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _fetchCar();
    _fetchGenes();
    _fetchModels();
    _fetchColors();
    // setState(() {
    //   customBannerUrl = widget.carDto.imageUrls.length > 0
    //       ? widget.carDto.imageUrls.first.url
    //       : CAR_IMAGE_DEFAULT;
    // });
  }

  GeneDto? get selectedGene {
    try {
      return _genes.firstWhere(
        (g) => g.id == widget.carDto.gene.id,
      );
    } catch (e) {
      return null;
    }
  }

  ModelDto? get selectedModel {
    try {
      return _models.firstWhere(
        (g) => g.id == widget.carDto.model.id,
      );
    } catch (e) {
      return null;
    }
  }

  ColorDto? get selectedColor {
    try {
      return _colors.firstWhere(
        (c) => c.id == widget.carDto.color.id,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchCar() async {
    if (widget.carDto.id == 0) return;

    try {
      final token = await UserStorage.getToken();
      final resCar = await CAR_FIND(token, widget.carDto.id ?? 0);

      setState(() {
        widget.carDto = new CarDto.fromJson(jsonDecode(resCar.body)['data']);
        customBannerUrl = widget.carDto.imageUrls.length > 0
            ? widget.carDto.imageUrls.first.url
            : CAR_IMAGE_DEFAULT;
      });
    } catch (e) {
      print('Ошибка загрузки _fetchCar: $e');
    }
  }

  Future<void> _fetchGenes() async {
    try {
      final token = await UserStorage.getToken();
      final resGenes = await GET_GENES(token);

      setState(() {
        _genes = (resGenes.data['data'] as List)
            .map((item) => GeneDto.fromJson(item))
            .toList();
      });
    } catch (e) {
      print('Ошибка загрузки _fetchGenes: $e');
    }
  }

  Future<void> _fetchColors() async {
    try {
      final token = await UserStorage.getToken();
      final resColors = await GET_COLORS(token);

      setState(() {
        _colors = (resColors.data['data'] as List)
            .map((item) => ColorDto.fromJson(item ?? {}))
            .toList();
      });
    } catch (e) {
      print('Ошибка загрузки _fetchColors: $e');
    }
  }

  Future<void> _fetchModels() async {
    try {
      final token = await UserStorage.getToken();
      final resModels = await GET_MODELS(token);

      setState(() {
        _models = (resModels.data['data'] as List)
            .map((item) => ModelDto.fromJson(item))
            .toList();
      });
    } catch (e) {
      print('Ошибка загрузки _fetchModels: $e');
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await UserStorage.getToken();

    dynamic res;

    if (widget.carDto.id == 0) {
      widget.carDto.userId = widget.userDto.id;
      res = await CREATE_CAR(token, widget.carDto);
    } else {
      res = await UPLOAD_CAR_BY_ID(token, widget.carDto);
    }
    bool isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      MessageModule(context, 'Успішно надіслано', MessageType.success);
      Navigator.pop(context);
    }
  }

  void _deleteCar() async {
    final token = await UserStorage.getToken();
    final res = await CAR_DELETE(token, widget.carDto.id ?? 0);

    bool isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      MessageModule(context, 'Успішно видалено', MessageType.success);
      Navigator.pop(context);
    }
  }

  void _confirmDeleteCar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Підтвердження'),
          content: Text('Ви впевнені, що хочете видалити авто?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Отмена
              child: Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
                _deleteCar(); // Продолжить удаление
              },
              child: Text(
                'Видалити',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }


  void _submitImg() async {
    if (widget.carDto.id == 0 || widget.carDto.id == null) {
      MessageModule(
          context, 'Спочатку збережіть авто', MessageType.information);
      return;
    }
    // UPLOAD_CAR_PHOTO(token, widget.carDto.id

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    // if (pickedFile != null) {
    //   File imageFile = File(pickedFile.path);
    //
    //   final token = await UserStorage.getToken();
    //   final res = await CAR_ADD_COLLECTION(
    //       token, widget.carDto.id ?? 0, imageFile.path);
    //   bool isSuccess = await CHECK_API(res, context);
    //   if (isSuccess) {
    //     var newImageUrl =
    //         jsonDecode(res.body)['data']['imageUrls'].first['url'];
    //     setState(() {
    //       customBannerUrl = newImageUrl;
    //     });
    //   }
    // }



    // crop_your_image: ^0.7.5
    // path_provider: ^2.1.2
    if (pickedFile != null) {
      _imageData = await pickedFile.readAsBytes();
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Crop(
                  image: _imageData!,
                  controller: _cropController,
                  aspectRatio: 2, // можно убрать, если не нужно
                  onCropped: (croppedData) async {
                    Navigator.of(context).pop(); // Закрываем диалог

                    // Сохраняем кадрированное изображение во временный файл
                    final tempDir = await getTemporaryDirectory();
                    final croppedFile = File('${tempDir.path}/cropped_image.jpg');
                    await croppedFile.writeAsBytes(croppedData);

                    final token = await UserStorage.getToken();
                    final res = await CAR_ADD_COLLECTION(
                        token, widget.carDto.id ?? 0, croppedFile.path);
                    bool isSuccess = await CHECK_API(res, context);
                    if (isSuccess) {
                      var newImageUrl =
                      jsonDecode(res.body)['data']['imageUrls'].first['url'];
                      setState(() {
                        customBannerUrl = newImageUrl;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _cropController.crop(); // 🔥 Запускает обрезку
                },
                child: const Text('Обрізати та зберегти'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TT - ${widget.userDto.nameController.text}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _submitImg();
                  // Здесь будет логика замены баннера
                  print("Нажали на баннер");
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    image: NetworkImage(customBannerUrl ?? CAR_IMAGE_DEFAULT),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // SizedBox(height: 16),
              DropdownButtonFormField<GeneDto>(
                value: selectedGene,
                hint: Text("Виберіть покоління"),
                items: _genes.map((gene) {
                  return DropdownMenuItem<GeneDto>(
                    value: gene,
                    child: Text(gene.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      widget.carDto.gene = value;
                    }
                  });
                },
                validator: (value) =>
                    value == null ? "Виберіть покоління" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<ModelDto>(
                value: selectedModel,
                hint: Text("Виберіть модель"),
                items: _models.map((model) {
                  return DropdownMenuItem<ModelDto>(
                    value: model,
                    child: Text(model.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      widget.carDto.model = value;
                    }
                  });
                },
                validator: (value) => value == null ? "Виберіть модель" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<ColorDto>(
                value: selectedColor,
                hint: Text("Виберіть Колір"),
                items: _colors.map((color) {
                  return DropdownMenuItem<ColorDto>(
                    value: color,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 8),
                          // отступ справа от кружочка
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.hex != null
                                ? Color(int.parse(
                                    color.hex!.replaceFirst('#', '0xFF')))
                                : Colors.transparent,
                          ),
                        ),
                        Text(color.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      widget.carDto.color = value;
                    }
                  });
                },
                validator: (value) => value == null ? "Виберіть модель" : null,
              ),
              SizedBox(height: 16),
              customBuildTextField('Держ. номер',
                  widget.carDto.licensePlateController, customValidatorDefault,
                  isEditable: true),
              SizedBox(height: 16),
              customBuildTextField('Індивідуальний номер',
                  widget.carDto.personalizedLicensePlateController, null,
                  isEditable: true),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _confirmDeleteCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade200,
                    ),
                    child: Text("Видалити"),
                  ),
                  SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text("Зберегти"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
