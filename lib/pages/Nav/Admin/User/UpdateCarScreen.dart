// import 'package:flutter/material.dart';
//
// import '../../../components/CustomAppBar.dart';
//
// class CreateCarScreen extends StatelessWidget {
//   const CreateCarScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         'Створення авто',
//         automaticallyImplyLeading: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Створення авто',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Закрыть'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Car/CarDto.dart';
import '../../../../api/routs/car/car.dart';

class UpdateCarScreen extends StatefulWidget {

  final CarDto? carDto;

  UpdateCarScreen({Key? key, this.carDto}) : super(key: key);

  @override
  _UpdateCarScreenState createState() => _UpdateCarScreenState();
}

class _UpdateCarScreenState extends State<UpdateCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _licensePlateController = TextEditingController();

  int? _selectedGene;
  int? _selectedModel;
  List<G> _genes = [];
  List<Map<String, dynamic>> _models = [];

  @override
  void initState() {
    super.initState();
    _fetchGenes();
    _fetchModels();
  }

  Future<void> _fetchGenes() async {
    try {
      final token = await UserStorage.getToken();
      final resGenes = await GET_GENES(token);
      setState(() {
        _genes = List<Map<String, dynamic>>.from(resGenes.data['data']['genes']);
      });
    } catch (e) {
      print('Ошибка загрузки genes: $e');
    }
  }

  Future<void> _fetchModels() async {
    try {
      final response = await Dio().get(
        'https://tt.tishchenko.kiev.ua/api/models',
        options: Options(
          headers: {
            'Authorization':
                'Bearer 57|ttClub_JmWgBF9omP69V3yfwJF3zOUaEWhRMw7WiJenNVFK80462dd6',
            // Заменить на реальный токен
          },
        ),
      );
      setState(() {
        _models = List<Map<String, dynamic>>.from(response.data['data']['genes']);
        _selectedModel = null;
      });
    } catch (e) {
      print('Ошибка загрузки models: $e');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedGene != null &&
        _selectedModel != null) {
      final data = {
        "user_id": null,
        "gene_id": _selectedGene,
        "model_id": _selectedModel,
        "name": null,
        "vin_code": null,
        "license_plate": _licensePlateController.text,
        "personalized_license_plate": null
      };
      print("Отправка данных: $data");
    } else {
      print("Заполните все поля");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Создать авто")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedGene,
                hint: Text("Виберіть покоління"),
                items: _genes.map((gene) {
                  return DropdownMenuItem<int>(
                    value: gene['id'],
                    child: Text(gene['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGene = value;
                  });
                },
                validator: (value) => value == null ? "Виберіть покоління" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedModel,
                hint: Text("Выберите модель"),
                items: _models.map((model) {
                  return DropdownMenuItem<int>(
                    value: model['id'],
                    child: Text(model['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedModel = value;
                  });
                },
                validator: (value) => value == null ? "Выберите модель" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _licensePlateController,
                decoration: InputDecoration(labelText: "Гос. номер"),
                validator: (value) => value!.isEmpty ? "Введите номер" : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Сохранить"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
