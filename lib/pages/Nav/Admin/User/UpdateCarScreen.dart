import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tt_club_ua/api/routs/Dto/Car/ModelDto.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Car/CarDto.dart';
import '../../../../api/routs/Dto/Car/GeneDto.dart';
import '../../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../api/routs/car/car.dart';
import '../../../../components/form/FormElements.dart';

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

  // GeneDto? _selectedGene;
  List<GeneDto> _genes = [];
  // ModelDto? _selectedModel;
  List<ModelDto> _models = [];

  @override
  void initState() {
    super.initState();
    _fetchGenes();
    _fetchModels();
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

  Future<void> _fetchGenes() async {
    try {
      final token = await UserStorage.getToken();
      final resGenes = await GET_GENES(token);

      setState(() {
        _genes = (resGenes.data['data'] as List)
            .map((item) => GeneDto.fromJson(item))
            .toList();

        // widget.carDto.gene = _genes.firstWhere(
        //       (g) => g.id == widget.carDto.gene.id,
        //   orElse: () => _genes.first,
        // );
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "id": widget.carDto.id ?? 0,
        "user_id": widget.userDto.id,
        "gene_id": widget.carDto.gene.id,
        "model_id": widget.carDto.model.id,
        "name": widget.carDto.nameController.text,
        "vin_code":  widget.carDto.vinCodeController.text,
        "license_plate":  widget.carDto.licensePlateController.text,
        "personalized_license_plate":  widget.carDto.personalizedLicensePlateController.text
      };
      print("Отправка данных: $data");
    } else {
      print("Заполните все поля");
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
              customBuildTextField(
                  'Держ. номер', widget.carDto.licensePlateController, customValidatorDefault,
                  isEditable: true),
              SizedBox(height: 16),
              customBuildTextField(
                  'Індивідуальний номер', widget.carDto.personalizedLicensePlateController, null,
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
