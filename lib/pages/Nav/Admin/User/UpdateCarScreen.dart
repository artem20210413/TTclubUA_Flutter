import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tt_club_ua/api/routs/Dto/Car/ColorDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Car/ModelDto.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Car/CarDto.dart';
import '../../../../api/routs/Dto/Car/GeneDto.dart';
import '../../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../api/routs/car/car.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/form/FormElements.dart';
import '../../../../components/generalModule.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchGenes();
    _fetchModels();
    _fetchColors();
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
      print('Ошибка загрузки genes: $e');
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
      print('Ошибка загрузки genes: $e');
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
      print('Ошибка загрузки models: $e');
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await UserStorage.getToken();

    dynamic res;

    widget.carDto.userId = widget.userDto.id;
    if (widget.carDto.id == 0) {
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
                                ? Color(int.parse(color.hex!.replaceFirst('#', '0xFF')))
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
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Зберегти"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
