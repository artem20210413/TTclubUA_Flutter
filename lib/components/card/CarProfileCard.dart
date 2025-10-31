import 'package:flutter/material.dart';

import '../../Storage/Search/CarSearchDto.dart';
import '../../config/default.dart';
import '../buttons/GlowingButton.dart';

class CarProfileCard extends StatefulWidget {
  final String modelName;

  // final String licensePlate;
  // final String location;

  // final String nickname;
  final String ownerName;
  final String? ownerAvatarUrl;
  final VoidCallback? onTap;
  final VoidCallback? onButtonTap;
  final CarSearchDto dto;

  const CarProfileCard({
    super.key,
    required this.modelName,
    // required this.licensePlate,
    // required this.location,
    // required this.nickname,
    required this.ownerName,
    required this.dto,
    this.ownerAvatarUrl,
    this.onTap,
    this.onButtonTap,
  });

  @override
  State<CarProfileCard> createState() => _CarProfileCardState();
}

class _CarProfileCardState extends State<CarProfileCard> {
  bool isBirthdayToday(DateTime? birthday) {
    if (birthday == null) return false;
    final now = DateTime.now();
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF202328),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото + бейдж "День народження"
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      isActiveUser ? Colors.transparent : Colors.grey,
                      isActiveUser ? BlendMode.srcOver : BlendMode.saturation,
                    ),
                    child: Image.network(
                      widget.dto.images.isNotEmpty
                          ? widget.dto.images.first.url
                          : CAR_IMAGE_DEFAULT,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isBirthday)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.cake_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Ряд с локацией, никнеймом и номером
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.white38),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.dto.user.citiesText ?? '',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.directions_car_filled,
                      size: 16, color: Colors.white38),
                  const SizedBox(width: 4),
                  if (widget.dto.personalizedLicensePlate != null)
                    Text(
                      '${widget.dto.personalizedLicensePlate}   | ',
                      style: TTTextStyle.subtitle,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    widget.dto.licensePlate,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Нижняя часть: аватар, имя, кнопка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.dto.user.profileImageString !=
                            USER_PROFILE_IMAGE_DEFAULT
                        ? NetworkImage(widget.dto.user.profileImageString!)
                        : null,
                    backgroundColor: Colors.grey.shade700,
                    child: widget.dto.user.profileImageString ==
                            USER_PROFILE_IMAGE_DEFAULT
                        ? Text(
                            widget.dto.user.name.characters.first,
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.dto.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isActiveUser)
                    Flexible(
                      flex: 0,
                      fit: FlexFit.loose,
                      child: GlowingButton(
                        text: 'ФА-ФА',
                        width: 180,
                        colorGrowing: Colors.white,
                        onPressed: () =>
                            widget.onButtonTap, // исправил, убери =>
                      ),
                    ),

                  // GestureDetector(
                  //   onTap: widget.onButtonTap,
                  //   child: Container(
                  //     height: 44,
                  //     padding: const EdgeInsets.symmetric(horizontal: 24),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(999),
                  //       border: Border.all(color: Colors.white, width: 1.6),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.white.withOpacity(0.45),
                  //           blurRadius: 20,
                  //         ),
                  //       ],
                  //       color: Colors.black.withOpacity(0.15),
                  //     ),
                  //     alignment: Alignment.center,
                  //     child: const Text(
                  //       'Fa-Fa',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
