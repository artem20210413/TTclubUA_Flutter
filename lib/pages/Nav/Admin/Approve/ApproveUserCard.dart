import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/components/viewers/InstagramLink.dart';
import 'package:tt_club_ua/components/viewers/TelegramLink.dart';
import 'package:tt_club_ua/components/TTNeumorphicBox.dart';
import 'package:tt_club_ua/components/viewers/FullImageViewer.dart';

import '../../../../Storage/Search/ImageUrlDto.dart';
import '../../../../api/routs/Dto/Registration/RegistrationDto.dart';
import '../../../../components/card/CarImageBlock.dart';

class ApproveUserCard extends StatelessWidget {
  final RegistrationDto item;
  final int index;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApproveUserCard({
    super.key,
    required this.item,
    required this.index,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final car = item.json['json']['car'];
    final hasCar = car != null;

    String cities = item.json['json']['cities_model'][0]['name'];
    // + ' - ' +        item.json['json']['cities_model'][0]['country'];
    return TTNeumorphicBox(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- USER HEADER ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(item.userImage.url),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#${item.id}  ${item.name}",
                      style: TTTextStyle.title18.copyWith(
                        color: TTColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/location.svg',
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                TTColors.text_secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(cities, style: TTTextStyle.subtitle),
                          ],
                        ),
                        InstagramLink(
                          context: context,
                          username: item.json['json']['instagram_nickname'],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/phone.svg',
                              height: 15,
                              colorFilter: ColorFilter.mode(
                                TTColors.text_secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(item.phone ?? '',
                                style: TTTextStyle.subtitle.copyWith(
                                  color: TTColors.text,
                                )),
                          ],
                        ),
                        TelegramLink(
                          context: context,
                          username:
                              item.json['json']['telegram_nickname'] ?? null,
                        )
                      ],
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/cake_outlined.svg',
                          height: 15,
                          colorFilter: ColorFilter.mode(
                            TTColors.text_secondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.json['json']['birth_date'] ?? '---',
                          style: TTTextStyle.subtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    SizedBox(height: 6),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/user.svg',
                          width: 14,
                          colorFilter: ColorFilter.mode(
                            TTColors.text,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.json['json']['occupation_description'],
                            style: TTTextStyle.subtitle
                                .copyWith(color: TTColors.text),
                            softWrap: true, // ✅ разрешаем перенос
                            overflow:
                                TextOverflow.visible, // ✅ не обрезаем текст
                          ),
                        ),
                      ],
                    ),
                    // Text(
                    //   "День народження: ${item.json['json']['birth_date']}",
                    //   style: TTTextStyle.subtitle.copyWith(
                    //     color: TTColors.text,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ---------- CAR INFO ----------
          if (hasCar) _buildCarInfo(item, car),

          const SizedBox(height: 16),

          // ---------- ACTION BUTTONS ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _approveButton(),
              const SizedBox(width: 10),
              _rejectButton(),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------- SUBWIDGETS -------------------------------

  Widget _buildCarInfo(RegistrationDto item, dynamic car) {
    String imageUrl = item.carImages.isNotEmpty
        ? (item.carImages.first.url ?? CAR_IMAGE_DEFAULT)
        : CAR_IMAGE_DEFAULT;
    return TTNeumorphicBox(
      padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
      // width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CarImageBlock(
            height: 200,
            imageUrl: imageUrl,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    car['personalized_license_plate'] != null
                        ? '${car['personalized_license_plate']}   |   ${car['license_plate']}'
                        : car['license_plate'],
                    style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Audi ${car['model']?['name'] ?? ''} ${car['gene']?['name'] ?? ''}',
                      maxLines: 2,
                      style: TTTextStyle.subtitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Кольорове коло
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(car['color']['hex']
                                  .replaceFirst('#', '0xff')),
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: TTColors.text_secondary, width: 1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Назва кольору
                        Flexible(
                          child: Text(
                            car['color']['name'],
                            style: TTTextStyle.subtitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    // return Container(
    //   padding: const EdgeInsets.all(12),
    //   decoration: BoxDecoration(
    //     color: TTColors.background_second,
    //     borderRadius: BorderRadius.circular(14),
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         "${car['model']?['name'] ?? ''}  ${car['gene']?['name'] ?? ''}",
    //         style: TTTextStyle.title18,
    //       ),
    //       const SizedBox(height: 4),
    //       Text(
    //         "Колір: ${car['color']?['name'] ?? 'Не вказано'}",
    //         style: TTTextStyle.subtitle,
    //       ),
    //       const SizedBox(height: 4),
    //       Text(
    //         "Номер: ${car['license_plate'] ?? ''}   ${car['personalized_license_plate'] ?? ''}",
    //         style: TTTextStyle.subtitle,
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget _buildCarMissing() {
    return Text(
      "Машину не знайдено",
      style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
    );
  }

  Widget _buildCarGallery(BuildContext context) {
    if (item.carImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: item.carImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final img = item.carImages[i];
          return GestureDetector(
            onTap: () => FullImageViewer.show(context, img.url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                img.url,
                width: 220,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _approveButton() {
    return ElevatedButton(
      onPressed: onApprove,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text("Підтвердити", style: TextStyle(color: Colors.black)),
    );
  }

  Widget _rejectButton() {
    return ElevatedButton(
      onPressed: onReject,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[300],
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text("Відхилити", style: TextStyle(color: Colors.black)),
    );
  }
}
