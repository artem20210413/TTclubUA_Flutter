import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/card/UserAvatar.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../api/routs/User.dart';
import '../../../components/TTLoading.dart';
import '../../../components/layout/TTScaffold.dart';

class Profile extends StatefulWidget {
  final int? id;

  const Profile({super.key, this.id});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late UserUpdateDto _dto;

  // final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  bool _isLocalProfile = false;

  String userProfileImage = USER_PROFILE_IMAGE_DEFAULT;

  void initState() {
    super.initState();
    _load();
  }

  @override
  Future<void> _load() async {
    await UserStorage.checkAndUpdate();

    String? localProfileImage = await UserStorage.getProfileImagee();
    dynamic json = await UserStorage.getUserInfo();

    if (widget.id != null && widget.id != json['id']) {
      final token = await UserStorage.getToken();
      final resUs = await USER_FIND(token, widget.id ?? 1);
      json = await jsonDecode(resUs.body)['data'];
      localProfileImage = await (json['profile_image'] ?? null);
    }
    setState(() {
      _dto = UserUpdateDto.fromJson(json);
      userProfileImage = localProfileImage ?? userProfileImage;
      _isLoading = false;
    });
  }

  // String _formatDate(String rawDate) {
  //   if (rawDate.isEmpty) return '—';
  //   try {
  //     return DateFormat('dd.MM.yyyy').format(DateTime.parse(rawDate));
  //   } catch (_) {
  //     return rawDate;
  //   }
  // }

  Widget build(BuildContext context) {
    return _isLoading
        ? const TTLoading()
        : TTScaffold(
            title: '',
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    UserAvatar(
                      radius: 90,
                      name: _dto.nameController.text,
                      imageUrl: userProfileImage,
                    ),
//TODO каждую машину отрисовать с полной информацией слайдинг горизонтальный
                    // CarImageBlock(
                    //   imageUrl: _dto.cars,
                    //   isActiveUser: isActiveUser,
                    // ),
                  ],
                )),
          );
  }
}
