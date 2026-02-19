import 'package:flutter/material.dart';

class ParticipantDto {
  final int? id;
  final int? drawId;
  final int? userId;

  // Редагуємі поля через контролери
  final TextEditingController weightController;
  final TextEditingController userNameController;
  final TextEditingController contactManualController;

  // Поля тільки для читання (з API)
  final bool isWinner;
  final String? profileImage;

  ParticipantDto({
    required this.id,
    this.drawId,
    this.userId,
    String? weight,
    String? userName,
    String? contactManual,
    this.isWinner = false,
    this.profileImage,
  })  : weightController = TextEditingController(text: weight ?? '1'),
        userNameController = TextEditingController(text: userName ?? ''),
        contactManualController = TextEditingController(text: contactManual ?? '');

  /// ---------- FROM JSON ----------
  factory ParticipantDto.fromJson(Map<String, dynamic> json) {
    return ParticipantDto(
      id: json['id'],
      drawId: json['draw_id'],
      userId: json['user_id'],
      // Переконуємось, що вага приходить як рядок для контролера
      weight: json['weight']?.toString(),
      // Беремо ім'я користувача (якщо є зв'язок на бекенді) або ручне введення
      userName: json['user_name'],
      contactManual: json['contact_manual'],
      isWinner: json['is_winner'] == true || json['is_winner'] == 1,
      profileImage: json['profile_image'],
    );
  }

  /// ---------- EMPTY (для ручного додавання учасника в адмінці) ----------
  factory ParticipantDto.empty({int? drawId}) {
    return ParticipantDto(
      id: null,
      drawId: drawId,
      weight: '1',
      userName: '',
      contactManual: '',
    );
  }

  /// ---------- TO JSON (для відправки на сервер) ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'draw_id': drawId,
      // Конвертуємо назад у ціле число (int)
      'weight': int.tryParse(weightController.text) ?? 1,
      'user_name': userNameController.text,
      'contact_manual': contactManualController.text,
    };
  }

  /// ---------- DISPOSE ----------
  /// Викликай цей метод, коли закриваєш екран редагування
  void dispose() {
    weightController.dispose();
    userNameController.dispose();
    contactManualController.dispose();
  }
}