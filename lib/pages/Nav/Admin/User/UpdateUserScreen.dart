import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/Storage/Search/CarSearchDto.dart';
import 'package:tt_club_ua/components/CustomAppBar.dart';

import '../../../../Storage/Search/UserSearchDto.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserSearchDto dto;

  UpdateUserScreen({required this.dto});

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _pickedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("Оновлення"),
      body: Column(
        children: [Text('fff')],
      ),
    );
  }
}
