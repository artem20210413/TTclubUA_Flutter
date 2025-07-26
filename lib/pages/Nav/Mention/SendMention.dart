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
  bool _isSending = false;

  void _sendMention() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    final token = await UserStorage.getToken();
    final res = await SEND_MENTION(
        token, _pickedImage, _descriptionController.text.trim(), widget.dto.id);

    bool isSuccess = await CHECK_API(res, context);
    setState(() => _isSending = false);

    if (isSuccess) {
      MessageModule(context, 'Успішно надіслано', MessageType.success);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Привітання"),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        // важно! чтобы сработал тап и по "пустому" месту
        child: SingleChildScrollView(
          // если нужно, чтобы при открытии клавиатуры всё поднималось
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image(
                  image: widget.dto.images.isNotEmpty
                      ? widget.dto.images.first.networkImage
                      : NetworkImage(CAR_IMAGE_DEFAULT) as ImageProvider,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        widget.dto.user.name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery);
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
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Опис привітання',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _sendMention, child: _isSending
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text('ФА-ФА'),
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
