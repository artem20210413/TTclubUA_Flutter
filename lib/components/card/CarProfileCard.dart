import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Storage/Search/CarSearchDto.dart';
import '../../config/default.dart';
import '../TTNeumorphicBox.dart';
import '../buttons/GlowingButton.dart';
import 'CarImageBlock.dart';
import 'UserAvatar.dart';

class CarProfileCard extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback onButtonTap;
  final CarSearchDto dto;

  const CarProfileCard({
    super.key,
    // required this.licensePlate,
    // required this.location,
    // required this.nickname,
    required this.dto,
    this.onTap,
    required this.onButtonTap,
  });

  @override
  State<CarProfileCard> createState() => _CarProfileCardState();
}

class _CarProfileCardState extends State<CarProfileCard> {
  bool isBirthdayToday(DateTime? birthday) {
    if (birthday == null) return false;
    final now = DateTime.now();
    // return true;
    return birthday.day == now.day && birthday.month == now.month;
  }

  late final bool isActiveUser;
  late final bool isBirthday;

  @override
  void initState() {
    super.initState();
    isActiveUser = widget.dto.user.active ?? false;
    isBirthday = isBirthdayToday(widget.dto.user.birthDate);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: TTNeumorphicBox(
        radius: 32,
        // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: EdgeInsets.only(bottom: 12, left: 20, right: 12),
        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 24),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarImageBlock(
                  imageUrl: widget.dto.images.isNotEmpty
                      ? widget.dto.images.first.url
                      : CAR_IMAGE_DEFAULT,
                  isActiveUser: isActiveUser,
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isActiveUser)
                      Column(
                        children: [
                          const SizedBox(height: 9),
                          Center(
                            child: Text(
                              '! Учасник не бажає бути частиною клубу !',
                              style: TTTextStyle.subtitle
                                  .copyWith(color: TTColors.text),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.white38),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.dto.user.citiesText ?? '',
                            style: TTTextStyle.subtitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.directions_car_filled,
                            size: 16, color: TTColors.text_secondary),
                        const SizedBox(width: 4),
                        if (widget.dto.personalizedLicensePlate != null)
                          Text(
                            '${widget.dto.personalizedLicensePlate}   | ',
                            style: TTTextStyle.subtitle,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          widget.dto.licensePlate,
                          style: TTTextStyle.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        UserAvatar(
                          name: widget.dto.user.name,
                          imageUrl: widget.dto.user.profileImageString,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.dto.user.name,
                            style: TTTextStyle.title.copyWith(fontSize: 14),
                            maxLines: 3, // ✅ максимум 2 строки
                            softWrap: true, // ✅ разрешаем перенос
                            overflow:
                                TextOverflow.visible, // ✅ не обрезаем текст
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isActiveUser)
                          Flexible(
                            flex: 0,
                            fit: FlexFit.loose,
                            child: GlowingButton(
                              text: 'ФА-ФА',
                              width: 150,
                              colorGrowing: Colors.white,
                              onPressed: widget.onButtonTap,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isBirthday)
            Positioned(
              top: 2,
              left: 25,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: TTColors.text, width: 1),
                  color: TTColors.card,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                  'assets/svg/cake_outlined.svg',
                  fit: BoxFit.scaleDown,
                  // fit: BoxFit.scaleDown,
                  // height: 15,
                  colorFilter: ColorFilter.mode(
                    TTColors.text,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
