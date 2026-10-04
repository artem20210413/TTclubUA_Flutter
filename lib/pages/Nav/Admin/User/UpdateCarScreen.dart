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
import '../../../../components/Selects/TTSelect.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/card/CarImageBlock.dart';
import '../../../../components/form/FormElements.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/layout/TTScaffold.dart';

import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../../../../components/viewers/PickAndCropImage.dart';

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

  Widget _validatedSelect<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
    required String errorText,
    Widget? Function(T)? leadingBuilder,
  }) {
    return FormField<T>(
      initialValue: value,
      validator: (v) => v == null ? errorText : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 12),
                child: Text(
                  state.errorText!,
                  style: TTTextStyle.subtitle
                      .copyWith(color: TTColors.danger, fontSize: 13),
                ),
              ),
            TTSelect<T>(
              value: value,
              items: items,
              labelBuilder: labelBuilder,
              leadingBuilder: leadingBuilder,
              onChanged: (v) {
                state.didChange(v);
                onChanged(v);
              },
            ),
          ],
        );
      },
    );
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
        context,
        'Спочатку збережіть авто',
        MessageType.information,
      );
      return;
    }

    // 1. выбираем и режем
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: 4 / 3, // 👈 для фото авто
    );

    if (croppedFile == null) return;

    // 2. отправляем на сервер
    final token = await UserStorage.getToken();
    final res = await CAR_ADD_COLLECTION(
      token,
      widget.carDto.id ?? 0,
      croppedFile.path,
    );

    final isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      final newImageUrl =
          jsonDecode(res.body)['data']['imageUrls'].first['url'];
      setState(() {
        customBannerUrl = newImageUrl;
      });
    }
  }

  // void _submitImg() async {
  //   if (widget.carDto.id == 0 || widget.carDto.id == null) {
  //     MessageModule(
  //         context, 'Спочатку збережіть авто', MessageType.information);
  //     return;
  //   }
  //
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //
  //
  //   if (pickedFile != null) {
  //     _imageData = await pickedFile.readAsBytes();
  //     showDialog(
  //       context: context,
  //       builder: (_) => Dialog(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(
  //               width: 300,
  //               height: 300,
  //               child: Crop(
  //                 image: _imageData!,
  //                 controller: _cropController,
  //                 aspectRatio: 4/3, // можно убрать, если не нужно
  //                 onCropped: (croppedData) async {
  //                   Navigator.of(context).pop(); // Закрываем диалог
  //
  //                   // Сохраняем кадрированное изображение во временный файл
  //                   final tempDir = await getTemporaryDirectory();
  //                   final croppedFile = File('${tempDir.path}/cropped_image.jpg');
  //                   await croppedFile.writeAsBytes(croppedData);
  //
  //                   final token = await UserStorage.getToken();
  //                   final res = await CAR_ADD_COLLECTION(
  //                       token, widget.carDto.id ?? 0, croppedFile.path);
  //                   bool isSuccess = await CHECK_API(res, context);
  //                   if (isSuccess) {
  //                     var newImageUrl =
  //                     jsonDecode(res.body)['data']['imageUrls'].first['url'];
  //                     setState(() {
  //                       customBannerUrl = newImageUrl;
  //                     });
  //                   }
  //                 },
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             ElevatedButton(
  //               onPressed: () {
  //                 _cropController.crop(); // 🔥 Запускает обрезку
  //               },
  //               child: const Text('Обрізати та зберегти'),
  //             ),
  //             const SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    final bool isNewCar = widget.carDto.id == null || widget.carDto.id == 0;

    return TTScaffold(
      title: "TT - ${widget.userDto.nameController.text}",
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _submitImg();
                },
                child: CarImageBlock(
                  imageUrl: customBannerUrl,
                  height: 220,
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Авто ${isNewCar ? 'новий запис' : '#${widget.carDto.id}'} · Власник #${widget.userDto.id}",
                  style: TTTextStyle.caption,
                ),
              ),
              SizedBox(height: 24),
              _validatedSelect<GeneDto?>(
                value: selectedGene,
                items: _genes,
                labelBuilder: (gene) => gene?.name ?? "Виберіть покоління",
                errorText: "Виберіть покоління",
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      widget.carDto.gene = value;
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              _validatedSelect<ModelDto?>(
                value: selectedModel,
                items: _models,
                labelBuilder: (model) => model?.name ?? "Виберіть модель",
                errorText: "Виберіть модель",
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      widget.carDto.model = value;
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              _validatedSelect<ColorDto?>(
                value: selectedColor,
                items: _colors,
                labelBuilder: (color) => color?.name ?? "Виберіть колір",
                errorText: "Виберіть модель",
                leadingBuilder: (color) {
                  if (color == null) return null;
                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.hex != null
                          ? Color(
                              int.parse(color.hex!.replaceFirst('#', '0xFF')))
                          : Colors.transparent,
                    ),
                  );
                },
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      widget.carDto.color = value;
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              CustomInputField(
                controller: widget.carDto.licensePlateController,
                label: 'Держ. номер',
                validator: customValidatorDefault,
              ),
              SizedBox(height: 16),
              CustomInputField(
                controller: widget.carDto.personalizedLicensePlateController,
                label: 'Індивідуальний номер',
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GlowingButton(
                      text: "Видалити",
                      colorGrowing: Colors.redAccent,
                      onPressed: _confirmDeleteCar,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GlowingButton(
                      text: "Зберегти",
                      onPressed: _submitForm,
                    ),
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
