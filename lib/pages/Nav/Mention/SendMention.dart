import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/Storage/Search/CarSearchDto.dart';

import '../../../Storage/UserStorage.dart';
import '../../../api/routs/car/car.dart';
import '../../../api/routs/root.dart';
import '../../../components/generalModule.dart';
import '../../../config/default.dart';

class SendMentionScreen extends StatefulWidget {
  final CarSearchDto dto;

  SendMentionScreen({required this.dto});

  @override
  _SendMentionScreenState createState() => _SendMentionScreenState();
}

class _SendMentionScreenState extends State<SendMentionScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _pickedImage;

  // @override
  // void initState() {
  // }
  void _sendMention() async {
    // if (_pickedImage == null || _descriptionController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Будь ласка, додайте фото та опис')),
    //   );
    //   return;
    // }

    final token = await UserStorage.getToken();
    final res = await SEND_MENTION(
        token, _pickedImage, _descriptionController.text.trim(), widget.dto.id);

    bool isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      MessageModule(context, 'Успішно надіслано', MessageType.success);
      Navigator.pop(context);
    }
    // Формируем multipart-запрос
    // var request =
    //     http.MultipartRequest('POST', Uri.parse('${API_ROOT}/mention/send'));
    // request.fields['description'] = _descriptionController.text;
    // request.fields['car_id'] =
    //     widget.dto.json['id'].toString(); // или другой ID машины
    //
    // request.files
    //     .add(await http.MultipartFile.fromPath('photo', _pickedImage!.path));
    //
    // var response = await request.send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Привітання"),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image(
              image: widget.dto.images.isNotEmpty
                  ? widget.dto.images.first.networkImage
                  : NetworkImage(CAR_IMAGE_DEFAULT) as ImageProvider,
              // image: widget.dto.images.isNotEmpty
              //     ? widget.dto.images.first
              //     : NetworkImage(CAR_IMAGE_DEFAULT) as ImageProvider,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // чтобы имя было по центру
              children: [
                Center(
                  child: Text(
                    widget.dto.user.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                    "🚗 ${widget.dto.modelName} ${widget.dto.geneName} - ${widget.dto.getFullLicensePlate()}"),
                SizedBox(height: 2),
                Text("📍 ${widget.dto.user.citiesText ?? '-'}"),
              ],
            ),
          ),
          SizedBox(height: 12),

// Форма загрузки фото и текста
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Кнопка для выбора изображения
                OutlinedButton(
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = pickedFile;
                      });
                    }
                  },
                  child: Text(_pickedImage == null
                      ? 'Завантажити фото'
                      : 'Фото вибрано'),
                ),
                SizedBox(height: 12),
                // Текстовое поле
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Опис привітання',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 12),
                // Кнопка отправки
                ElevatedButton(
                  onPressed: _sendMention,
                  child: Text('Надіслати'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
