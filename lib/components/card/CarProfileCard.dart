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
  final Color accentColor;

  const CarProfileCard({
    super.key,
    required this.dto,
    this.onTap,
    this.accentColor = Colors.white,
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBirthday = widget.dto.user.isBirthdayToday;
    final bool isActiveUser = widget.dto.user.active ?? false;

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
                  uniqueKey: widget.dto.id,
                  imageUrl: widget.dto.images.isNotEmpty
                      ? widget.dto.images.first.url
                      : CAR_IMAGE_DEFAULT,
                  isActiveUser: isActiveUser,
                  height: MediaQuery.of(context).size.width * 0.5,
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
                        SvgPicture.asset(
                          'assets/svg/location.svg',
                          width: 15,
                          colorFilter: ColorFilter.mode(
                            TTColors.text_secondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.dto.user.citiesText ?? '',
                            style: TTTextStyle.subtitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SvgPicture.asset(
                          'assets/svg/car.svg',
                          width: 18,
                          colorFilter: ColorFilter.mode(
                            TTColors.text_secondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.dto.personalizedLicensePlate != null
                              ? '${widget.dto.personalizedLicensePlate}   |   ${widget.dto.licensePlate}'
                              : widget.dto.licensePlate,
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
                              colorGrowing: widget.accentColor,
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
