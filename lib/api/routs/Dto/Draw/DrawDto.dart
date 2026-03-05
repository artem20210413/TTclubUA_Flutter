import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Draw/DrawStatus.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';
import 'PrizeDto.dart';

class DrawDto {
  final int? id;

  // Controllers
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController statusController;

  // Flags & Notifiers
  final ValueNotifier<bool> allowMultipleWinsNotifier;
  final ValueNotifier<bool> isPublicNotifier;
  final ValueNotifier<bool> isParticipatingNotifier;
  List<ImageUrlDto> images;

  // Dates
  DateTime? registrationUntil;

  // Relations
  List<PrizeDto> prizes;

  // Можна додати учасників, якщо потрібно відображати їх в адмінці
  // List<ParticipantDto> participants;

  DrawDto({
    required this.id,
    String? title,
    String? description,
    String? status,
    required bool allowMultipleWins,
    required bool isPublic,
    required bool isParticipating,
    required this.registrationUntil,
    required this.images,
    required this.prizes,
  })  : titleController = TextEditingController(text: title ?? ''),
        descriptionController = TextEditingController(text: description ?? ''),
        statusController = TextEditingController(text: status ?? null),
        allowMultipleWinsNotifier = ValueNotifier<bool>(allowMultipleWins),
        isPublicNotifier = ValueNotifier<bool>(isPublic),
        isParticipatingNotifier = ValueNotifier<bool>(isParticipating);

  factory DrawDto.fromJson(Map<String, dynamic> json) {
    return DrawDto(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      allowMultipleWins: json['allow_multiple_wins'] == true ||
          json['allow_multiple_wins'] == 1,
      isPublic: json['is_public'] == true || json['is_public'] == 1,
      isParticipating: json['is_participating'] ?? false,
      registrationUntil: json['registration_until'] != null
          ? DateTime.tryParse(json['registration_until'])
          : null,
      prizes: (json['prizes'] as List? ?? [])
          .map((p) => PrizeDto.fromJson(p))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((img) => ImageUrlDto.fromJson(img))
          .toList(),
    );
  }

  factory DrawDto.empty() {
    return DrawDto(
      id: null,
      title: '',
      description: '',
      status: null,
      allowMultipleWins: true,
      isPublic: true,
      isParticipating: false,
      registrationUntil: null,
      prizes: [],
      images: [],
    );
  }

  DrawStatus getStatus(){
    return DrawStatus.fromString(statusController.text);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titleController.text,
      'description': descriptionController.text,
      // 'status': statusController.text == '' ? null : statusController.text,
      'allow_multiple_wins': allowMultipleWinsNotifier.value ? 1 : 0,
      'is_public': isPublicNotifier.value ? 1 : 0,
      'registration_until': registrationUntil?.toIso8601String(),
    };
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    statusController.dispose();
    allowMultipleWinsNotifier.dispose();
    isPublicNotifier.dispose();
    isParticipatingNotifier.dispose();
    for (var prize in prizes) {
      prize.dispose();
    }
  }


}
