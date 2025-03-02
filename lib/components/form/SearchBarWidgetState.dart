import 'package:flutter/material.dart';

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
          // Поле ввода
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Поиск...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                // suffixIcon: Icon(Icons.tune), // Иконка фильтров
              ),
              onSubmitted: (_) => onSearch(), // Поиск при нажатии Enter
            ),
          ),
          SizedBox(width: 10), // Отступ между элементами
          // Кнопка поиска
          GestureDetector(
            onTap: onSearch,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}