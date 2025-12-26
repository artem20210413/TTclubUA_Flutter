import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/TTNeumorphicBox.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';

import '../Storage/Cache/AccentColorCache.dart';
import '../api/routs/app_config.dart';

class AppUpdateService {
  static Future<void> check(BuildContext context) async {
    try {
      // Получаем инфо о текущей версии
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      final token = await UserStorage.getToken();
      final response = await CHECK_APP_CONFIG(token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final String status = data['update_status'];

        if (status == 'UP_TO_DATE') return;

        if (context.mounted) {
          _showUpdateDialog(
            context,
            isForce: status == 'FORCE_UPDATE',
            latestVersion: data['latest_version'] ?? '',
            currentVersion: currentVersion,
            // Передаем сюда
            storeUrl: data['store_url'] ?? '',
            releaseNotes: data['release_notes'],
          );
        }
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  Widget _buildReleaseNotes(String notes, Color accentColor) {
    // Разделяем текст на строки
    final lines =
    notes.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Красивая точка или иконка
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.circle, size: 6, color: accentColor),
              ),
              const SizedBox(width: 12),
              // Сам текст строки
              Expanded(
                child: Text(
                  line.replaceFirst(RegExp(r'^[\s•*-]+'), '').trim(),
                  // Убираем лишние символы в начале, если они есть
                  style: TTTextStyle.subtitle.copyWith(
                    height: 1.3,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static void _showUpdateDialog(
    BuildContext context, {
    required bool isForce,
    required String latestVersion,
    required String currentVersion,
    required String storeUrl,
    String? releaseNotes,
  }) {
    final accentColor = AccentColorCache.accentColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: TTColors.background,
      // Твой цвет фона из PhotoActionsButton
      isScrollControlled: true,
      isDismissible: !isForce,
      // Нельзя закрыть кликом мимо, если Force
      enableDrag: !isForce,
      // Нельзя смахнуть вниз, если Force
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return PopScope(
          canPop: !isForce,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Полоска сверху (handle)
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: (isForce ? Colors.redAccent : accentColor)
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Иконка
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (isForce ? Colors.redAccent : accentColor)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      isForce
                          ? 'assets/svg/siren.svg'
                          : 'assets/svg/clock-clockwise.svg',
                      height: 45,
                      colorFilter: ColorFilter.mode(
                        isForce ? Colors.redAccent : accentColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    isForce ? 'КРИТИЧНЕ ОНОВЛЕННЯ' : 'НОВА ВЕРСІЯ',
                    style: TTTextStyle.title.copyWith(
                      color: isForce ? Colors.redAccent : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Блок с версиями
                  Column(
                    children: [
                      Text(
                        "Версія $latestVersion вже доступна",
                        style:
                            TTTextStyle.subtitle.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isForce
                            ? "Ваша поточна версія: $currentVersion недоступна"
                            : "Ваша поточна версія: $currentVersion",
                        style: TTTextStyle.subtitle
                            .copyWith(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),

                  if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      releaseNotes,
                      style: TTTextStyle.subtitle.copyWith(height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Кнопка обновления
                  GlowingButton(
                    text: 'ОНОВИТИ ЗАРАЗ',
                    colorGrowing: isForce ? Colors.redAccent : accentColor,
                    onPressed: () async {
                      final uri = Uri.parse(storeUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),

                  if (!isForce)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Text(
                          'Нагадати пізніше',
                          style: TTTextStyle.subtitle.copyWith(
                            color: Colors.white38,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// static void _showUpdateDialog(
//     BuildContext context, {
//       required bool isForce,
//       required String latestVersion,
//       required String currentVersion, // Добавили новый параметр
//       required String storeUrl,
//       String? releaseNotes,
//     }) {
//   final accentColor = AccentColorCache.accentColor;
//
//   showGeneralDialog(
//     context: context,
//     barrierDismissible: !isForce,
//     barrierLabel: '',
//     barrierColor: Colors.black.withOpacity(0.6),
//     transitionDuration: const Duration(milliseconds: 500),
//     pageBuilder: (context, anim1, anim2) => const SizedBox(),
//     transitionBuilder: (context, anim1, anim2, child) {
//       final curveValue = Curves.easeOutExpo.transform(anim1.value);
//
//       return BackdropFilter(
//         filter: ImageFilter.blur(
//           // sigmaX: 5.0 * anim1.value,
//           // sigmaY: 5.0 * anim1.value,
//         ),
//         child: Opacity(
//           opacity: anim1.value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - curveValue) * 200),
//             child: PopScope(
//               canPop: !isForce,
//               child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   margin: const EdgeInsets.all(20),
//                   padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1A1A1A),
//                     borderRadius: BorderRadius.circular(35),
//                     border: Border.all(
//                       color: isForce ? Colors.redAccent : accentColor.withOpacity(0.6),
//                       width: 2,
//                     ),
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: Colors.white24,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: (isForce ? Colors.redAccent : accentColor).withOpacity(0.1),
//                             shape: BoxShape.circle,
//                           ),
//                           child: SvgPicture.asset(
//                             isForce ? 'assets/svg/siren.svg' :  'assets/svg/clock-clockwise.svg',
//                             fit: BoxFit.scaleDown,
//                             height: 45,
//                             colorFilter: ColorFilter.mode(
//                               isForce ? Colors.redAccent : accentColor,
//                               BlendMode.srcIn,
//                             ),
//                           ),
//                           // child: Icon(
//                           //   isForce ? Icons.warning_amber : Icons.update_rounded,
//                           //   size: 45,
//                           //   color: isForce ? Colors.redAccent : accentColor,
//                           // ),
//                         ),
//                         const SizedBox(height: 24),
//
//                         Text(
//                           isForce ? 'КРИТИЧНЕ ОНОВЛЕННЯ' : 'НОВА ВЕРСІЯ',
//                           style: TTTextStyle.title.copyWith(
//                             color: isForce ? Colors.redAccent : Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//
//                         // Блок с версиями
//                         Column(
//                           children: [
//                             Text(
//                               "Версія $latestVersion вже доступна",
//                               style: TTTextStyle.subtitle.copyWith(color: Colors.white),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               isForce ?  "Ваша поточна версія: $currentVersion недоступна" :  "Ваша поточна версія: $currentVersion",
//                               style: TTTextStyle.subtitle.copyWith(
//                                   color: Colors.white38,
//                                   fontSize: 12
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
//                           const SizedBox(height: 20),
//                           Text(
//                             releaseNotes,
//                             style: TTTextStyle.subtitle.copyWith(height: 1.4),
//                             textAlign: TextAlign.center,
//                             maxLines: 4,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//
//                         const SizedBox(height: 32),
//
//                         GlowingButton(
//                           text: 'ОНОВИТИ ЗАРАЗ',
//                           colorGrowing: isForce ? Colors.redAccent : accentColor,
//                           onPressed: () async {
//                             final uri = Uri.parse(storeUrl);
//                             if (await canLaunchUrl(uri)) {
//                               await launchUrl(uri, mode: LaunchMode.externalApplication);
//                             }
//                           },
//                         ),
//
//                         if (!isForce)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15),
//                             child: GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: Text(
//                                 'Нагадати пізніше',
//                                 style: TTTextStyle.subtitle.copyWith(
//                                   color: Colors.white38,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
}
