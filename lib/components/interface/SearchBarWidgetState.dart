import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/config/default.dart';

import '../buttons/CircleButton.dart';
import '../buttons/NavCircleButton.dart';
import '../card/PromoCard.dart';
import '../card/TopActionCard.dart';
import '../inputs/CustomInputField.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  SearchBarWidget({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: CustomInputField(
              controller: controller,
              label: 'Пошук',
            ),
          ),
          SizedBox(width: 10), // Отступ между элементами
          // Кнопка поиска
          CircleButton(
            iconAsset: 'assets/svg/search.svg',
            onTap: onSearch,
          )
          // GestureDetector(
          //   onTap: onSearch,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(color: Colors.black, width: 2),
          //     ),
          //     padding: EdgeInsets.all(10),
          //     child: Icon(Icons.search, size: 30),
          //   ),
          // ),
        ],
      ),
    );
  }
}
