import 'package:flutter/material.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';

class PrizeDto {
  final int? id;
  final int? drawId;

  // Controllers
  final TextEditingController titleController;
  final TextEditingController quantityController;
  final TextEditingController sortOrderController;

  final int? winnerParticipantId;
  List<ImageUrlDto> images;

  PrizeDto({
    required this.id,
    this.drawId,
    String? title,
    String? quantity,
    String? sortOrder,
    this.winnerParticipantId,
    required this.images,
  })  : titleController = TextEditingController(text: title ?? ''),
        quantityController = TextEditingController(text: quantity ?? '1'),
        sortOrderController = TextEditingController(text: sortOrder ?? '0');

  factory PrizeDto.fromJson(Map<String, dynamic> json) {
    return PrizeDto(
      id: json['id'],
      drawId: json['draw_id'],
      title: json['title'],
      quantity: json['quantity']?.toString(),
      sortOrder: json['sort_order']?.toString(),
      winnerParticipantId: json['winner_participant_id'],
      images: (json['images'] as List? ?? [])
          .map((img) => ImageUrlDto.fromJson(img))
          .toList(),
    );
  }

  factory PrizeDto.empty({int? drawId}) {
    return PrizeDto(
      id: null,
      drawId: drawId,
      title: '',
      quantity: '1',
      sortOrder: '0',
      images: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'draw_id': drawId,
      'title': titleController.text,
      'quantity': int.tryParse(quantityController.text) ?? 1,
      'sort_order': int.tryParse(sortOrderController.text) ?? 0,
    };
  }

  void dispose() {
    titleController.dispose();
    quantityController.dispose();
    sortOrderController.dispose();
  }
}