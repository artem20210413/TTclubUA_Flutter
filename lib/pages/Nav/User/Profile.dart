import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/card/UserAvatar.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../api/routs/User.dart';
import '../../../components/TTLoading.dart';
import '../../../components/TTNeumorphicBox.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../components/viewers/InstagramLink.dart';

class Profile extends StatefulWidget {
  final int? id;

  const Profile({super.key, this.id});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late UserUpdateDto _dto;

  // final _formKey = GlobalKey<FormState>();
  // final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  // bool _isLocalProfile = false;

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
      // print(json);
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
    // _isLoading
    //     ? const TTLoading()
    //     :
    return TTScaffold(
      title: '',
      body: _isLoading
          ? const TTLoading()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TTNeumorphicBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UserAvatar(
                              radius: 33,
                              name: _dto.nameController.text,
                              imageUrl: userProfileImage,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 150,
                              child: Text(
                                _dto.nameController.text,
                                style: TTTextStyle.title.copyWith(fontSize: 16),
                                maxLines: 3, // ✅ максимум 2 строки
                                softWrap: true, // ✅ разрешаем перенос
                                overflow:
                                    TextOverflow.visible, // ✅ не обрезаем текст
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Expanded(
                            //   child: Text(
                            //     _dto.nameController.text,
                            //     style: TTTextStyle.title.copyWith(fontSize: 14),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 16, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text(
                              _dto.citiesText ?? '',
                              style: TTTextStyle.subtitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 10),
                            InstagramLink(
                              username: _dto.instagramNicknameController.text,
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  )
                  // Text('ggg', style: TTTextStyle.title),

// TODO каждую машину отрисовать с полной информацией слайдинг горизонтальный
//                   CarImageBlock(
//                     imageUrl: _dto.cars,
//                     isActiveUser: isActiveUser,
//                   ),
                ],
              ),
            ),
    );
  }
}
