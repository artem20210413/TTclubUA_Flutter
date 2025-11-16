import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/Storage/Search/CarSearchDto.dart';

import '../../../Storage/UserStorage.dart';
import '../../../api/routs/car/car.dart';
import '../../../api/routs/root.dart';
import '../../../components/TTNeumorphicBox.dart';
import '../../../components/buttons/GlowingButton.dart';
import '../../../components/card/CarImageBlock.dart';
import '../../../components/card/UserAvatar.dart';
import '../../../components/generalModule.dart';
import '../../../components/inputs/BigTextInput.dart';
import '../../../components/inputs/CustomInputField.dart';
import '../../../components/inputs/PhotoPickerInput.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../config/default.dart';

class SendMentionScreen extends StatefulWidget {
  final CarSearchDto dto;

  SendMentionScreen({required this.dto});

  @override
  _SendMentionScreenState createState() => _SendMentionScreenState();
}

class _SendMentionScreenState extends State<SendMentionScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _pickedImage;
  bool _isSending = false;

  void _sendMention() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    final token = await UserStorage.getToken();
    final res = await SEND_MENTION(
        token, _pickedImage, _descriptionController.text.trim(), widget.dto.id);

    bool isSuccess = await CHECK_API(res, context);
    setState(() => _isSending = false);

    if (isSuccess) {
      MessageModule(context, 'Вітання передано', MessageType.success);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: '',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: TTNeumorphicBox(
          margin: EdgeInsets.only(top: 24, right: 16, bottom: 16, left: 24),
          padding: EdgeInsets.only(top: 16, right: 24, bottom: 16, left: 18),
          child: Column(
            children: [
              CarImageBlock(
                imageUrl: widget.dto.images.isNotEmpty
                    ? widget.dto.images.first.url
                    : CAR_IMAGE_DEFAULT,
                // isActiveUser: isActiveUser,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const SizedBox(width: 2),
                      SvgPicture.asset(
                        'assets/svg/user.svg',
                        width: 14,
                        colorFilter: ColorFilter.mode(
                          TTColors.text,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.dto.user.name,
                          style: TTTextStyle.subtitle
                              .copyWith(color: TTColors.text),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        'assets/svg/location.svg',
                        width: 15,
                        colorFilter: ColorFilter.mode(
                          TTColors.text_secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.dto.user.citiesText ?? '',
                        style: TTTextStyle.subtitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/car.svg',
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          TTColors.text_secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Audi ${widget.dto.modelName} ${widget.dto.geneName}',
                          maxLines: 1,
                          style: TTTextStyle.subtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.dto.personalizedLicensePlate != null
                            ? '${widget.dto.personalizedLicensePlate}   |   ${widget.dto.licensePlate}'
                            : '${widget.dto.licensePlate}',
                        style: TTTextStyle.subtitle,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 18),
              Container(
                margin: EdgeInsets.only(left: 8, right: 0),
                child: Column(
                  children: [
                    BigTextInput(
                      controller: _descriptionController,
                      hint: 'Текст привітання...',
                      minHeight: 50,
                      minLines: 2,
                    ),
                    SizedBox(height: 12),
                    PhotoPickerInput(
                      initialImage: _pickedImage,
                      onImageSelected: (file) {
                        setState(() => _pickedImage = file);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              GlowingButton(
                text: 'ФА-ФА',
                onPressed: _sendMention,
                isLoading: _isSending,
              ),
              // ElevatedButton(
              //   onPressed: _sendMention,
              //   child: _isSending
              //       ? SizedBox(
              //           height: 20,
              //           width: 20,
              //           child: CircularProgressIndicator(
              //             strokeWidth: 2,
              //             color: Colors.white,
              //           ),
              //         )
              //       : Text('ФА-ФА'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
