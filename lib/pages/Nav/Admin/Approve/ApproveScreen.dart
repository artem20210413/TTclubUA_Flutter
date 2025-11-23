import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/api/routs/Dto/Registration/RegistrationDto.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/registaion.dart';
import '../../../../components/CustomAppBar.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/card/CarImageBlock.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/InstagramLink.dart';
import '../../../../components/viewers/TelegramLink.dart';
import 'ApproveUserCard.dart';

class ApproveScreen extends StatefulWidget {
  @override
  _ApproveScreenState createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen> {
  List<RegistrationDto> list = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await UserStorage.getToken();
      final res = await REGISTRATION_LIST(token);

      final data = jsonDecode(res.body)['data'] as List<dynamic>?;
      setState(() {
        list = (data ?? [])
            .where((el) => el != null && el is Map<String, dynamic>)
            .map((el) => RegistrationDto.fromJson(el as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('Ошибка загрузки _init: $e');
    }
  }

  Future<void> _rejectRegistration(int id, int index) async {
    final token = await UserStorage.getToken();
    try {
      final res = await REJECT_REGISTRATION(id, token);
      if (res.statusCode == 200) {
        MessageModule(context, 'Запит відхилено. id: $id', MessageType.success);
        setState(() {
          list.removeAt(index);
        });
      } else {
        MessageModule(context, 'Помилка: ${res.statusCode}', MessageType.error);
      }
    } catch (e) {
      MessageModule(context, 'Помилка підтвердження: $e', MessageType.error);
    }
  }

  Future<void> _approveRegistration(int id, int index) async {
    final token = await UserStorage.getToken();
    try {
      final res = await APPROVE_REGISTRATION(id, token);
      if (res.statusCode == 200) {
        MessageModule(
            context, 'Запит підтверджено. id: $id', MessageType.success);
        setState(() {
          list.removeAt(index);
        });
      } else {
        final json = jsonDecode(res.body);
        final message = json['message'] ?? 'Помилка';
        final errors = (json['data']?['errors'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .join('\n') ??
            '';
        MessageModule(context, 'Помилка: ${res.statusCode}. $message. $errors',
            MessageType.error);
      }
    } catch (e) {
      MessageModule(context, 'Помилка підтвердження: $e', MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Затвердити',
      body: list.isEmpty
          ? const Center(
              child: Text(
                'Список порожній',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return ApproveUserCard(
                  item: item,
                  index: index,
                  onApprove: () => _approveRegistration(item.id, index),
                  onReject: () => _rejectRegistration(item.id, index),
                );

                // return Card(
                //   color: TTColors.card,
                //   // margin: EdgeInsets.all(8),
                //   // elevation: 4,
                //   // shape: RoundedRectangleBorder(
                //   //   borderRadius: BorderRadius.circular(12),
                //   // ),
                //   child: TTNeumorphicBox(
                //     padding: EdgeInsets.only(
                //         top: 16, bottom: 24, left: 16, right: 24),
                //     margin: EdgeInsets.only(
                //         top: 16, bottom: 24, left: 16, right: 8),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             CircleAvatar(
                //               backgroundImage: NetworkImage(item.userImage.url),
                //               radius: 30,
                //             ),
                //             SizedBox(width: 12),
                //             Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   "#${item.id} ${item.name}",
                //                   style: TTTextStyle.title18,
                //                 ),
                //                 SizedBox(height: 4),
                //                 Text(
                //                     "${item.phone} / ${item.json['json']['birth_date']}",
                //                     style: TTTextStyle.subtitle
                //                         .copyWith(color: TTColors.text)),
                //                 SizedBox(height: 4),
                //                 Text(
                //                   "Tg: ${item.json['json']['telegram_nickname']}",
                //                   style: TTTextStyle.subtitle
                //                       .copyWith(color: TTColors.text),
                //                 ),
                //                 SizedBox(height: 4),
                //                 Text(
                //                   "Ins: ${item.json['json']['instagram_nickname']}",
                //                   style: TTTextStyle.subtitle
                //                       .copyWith(color: TTColors.text),
                //                 ),
                //                 SizedBox(height: 4),
                //                 SizedBox(height: 4),
                //                 if (item.json['json']['car'] != null) ...[
                //                   Builder(builder: (_) {
                //                     final car = item.json['json']['car'];
                //                     final model =
                //                         car['model']?['name'] ?? 'Не вказано';
                //                     final gene =
                //                         car['gene']?['name'] ?? 'Не вказано';
                //                     final color =
                //                         car['color']?['name'] ?? 'Не вказано';
                //                     final licensePlate =
                //                         car['license_plate'] ?? 'Не вказано';
                //                     final personalizedLicensePlate =
                //                         car['personalized_license_plate'] ?? '';
                //
                //                     return Padding(
                //                       padding: const EdgeInsets.only(top: 6.0),
                //                       child: Text(
                //                         '$model $gene ($color) | $licensePlate  $personalizedLicensePlate',
                //                         style: TTTextStyle.subtitle
                //                             .copyWith(color: TTColors.text),
                //                       ),
                //                     );
                //                   }),
                //                 ] else ...[
                //                   const Text('Машину не знайдено'),
                //                 ],
                //               ],
                //             ),
                //           ],
                //         ),
                //         SizedBox(height: 12),
                //         SingleChildScrollView(
                //           scrollDirection: Axis.horizontal,
                //           child: Row(
                //             children: item.carImages
                //                 .where((carImage) => carImage.url.isNotEmpty)
                //                 .map((carImage) {
                //               return
                //                   // CarImageBlock(
                //                   //   height: 200,
                //                   //   imageUrl: carImage.url,
                //                   // );
                //
                //                   Padding(
                //                 padding: const EdgeInsets.only(right: 8.0),
                //                 child: ClipRRect(
                //                   borderRadius: BorderRadius.circular(8),
                //                   child: Image.network(
                //                     carImage.url,
                //                     width: 200,
                //                     height: 120,
                //                     fit: BoxFit.cover,
                //                   ),
                //                 ),
                //               );
                //             }).toList(),
                //           ),
                //         ),
                //         SizedBox(height: 12),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.end,
                //           children: [
                //             ElevatedButton(
                //               onPressed: () =>
                //                   _approveRegistration(item.id, index),
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: Colors.green,
                //               ),
                //               child: Text('Підтвердити'),
                //             ),
                //             SizedBox(width: 8),
                //             ElevatedButton(
                //               onPressed: () =>
                //                   _rejectRegistration(item.id, index),
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: Colors.red[200],
                //               ),
                //               child: Text('Відхилити'),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              },
            ),
    );
  }
}
