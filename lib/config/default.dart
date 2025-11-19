import 'dart:ui';

import 'package:flutter/material.dart';

// const String USER_PROFILE_IMAGE_DEFAULT =
//     'https://tt.tishchenko.kiev.ua/storage/default/profile_picture.webp';
const String USER_PROFILE_IMAGE_DEFAULT =
    'https://ttclub.com.ua/storage/default/profile_picture.webp';
const String CAR_IMAGE_DEFAULT =
    'https://ttclub.com.ua/storage/default/car.webp';
const String LOGO_IMAGE_DEFAULT =
    'https://ttclub.com.ua/media/images/logo_2.webp';

const String TG_FORGOT_URI = 'https://t.me/TTclubUaBot';
const String SIGNUP_URI = 'https://ttclub.com.ua';

const String DATE_FORMAT_DEFAULT = 'dd-MM-yyyy';
const String DATE_FORMAT_DEFAULT_SEND = 'dd-MM-yyyy'; //'d-M-y'

// const Color BACKGROUND_SECOND = Colors.black;
// const Color BACKGROUND_FIRST = Color(0xFF8B0000);

class TTColors {
  // static const Color background = Color(0xFF282A2F);//#242528B2
  static const Color background = Color(0xFF1F2021); //0xFF242528
  static const Color background_gradient_1 = Color(0xFF1F2021); //0xFF242528
  static const Color background_gradient_2 = Color(0xFF282B2F); //0xFF242528
  static const Color background_second = Color(0xFF2000000);
  static const Color button_background = Color(0xFF1F2021);

  // static const Color logo_background = Color(0xFF242528B2);

  // static const Color card = Color(0xFF303234);
  static const Color card = Color(0xFF202122);
  static const Color input = Color(0xFF242528);
  static const Color input_focused = Color(0xFF444549);

  static const Color text = Color(0xFFFFFFFF);

  static const Color text_secondary = Color(0xFF848484);

  static const Color danger = Color(0xFFFF0000);
  static const Color success = Color(0xFF00FF99);
}

class TTTextStyle {
  static const String fontFamily = "SF Pro Display";

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    fontSize: 23,
    color: TTColors.text,
  );
  static const TextStyle title18 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    fontSize: 18,
    color: TTColors.text,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.normal,
    fontSize: 14,
    color: TTColors.text_secondary,
  );
}
