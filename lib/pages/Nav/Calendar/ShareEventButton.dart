import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tt_club_ua/config/default.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../Storage/UserStorage.dart';
import '../../../api/routs/events.dart';
import '../../../api/routs/root.dart';
import '../../../components/generalModule.dart';
import '../../../config/LoadingTypeConfig.dart';

class ShareEventButton extends StatelessWidget {
  final dynamic item;
  final Color? color;

  const ShareEventButton({
    super.key,
    required this.item,
    this.color,
  });

  void _onShare(BuildContext context) async {

    if (!LoadingTypeConfig.hasClickingOnLink) return;
    final token = await UserStorage.getToken();

    final res = await CALENDAR_DESCRIPTION(token, item.id);

    final isSuccess = await CHECK_API(res, context);
    if (!isSuccess) {
      MessageModule(
          context, 'Не вдалося... Спробуйте пізніше.', MessageType.error);
      return;
    }

    final String message = jsonDecode(res.body)['data']['message'];
    final String? title = jsonDecode(res.body)['data']['title'] ?? null;

    try {
      if (item.images.isNotEmpty) {
        // Отримуємо тимчасову папку
        final temp = await getTemporaryDirectory();
        final path = "${temp.path}/share_tmp.webp";

        // Завантажуємо фото
        final response = await http
            .get(Uri.parse(item.images.first))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final file = File(path);
          await file.writeAsBytes(response.bodyBytes);

          // Шаримо файл + текст
          await Share.shareXFiles([XFile(path)], text: message, subject: title);
        } else {
          throw Exception("Failed to load image");
        }
      } else {
        await Share.share(message, subject: title);
      }
    } catch (e) {
      debugPrint("Share error: $e");
      await Share.share(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onShare(context),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          'assets/svg/share-fat.svg',
          width: 20,
          colorFilter: ColorFilter.mode(
            color ?? TTColors.text_secondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
