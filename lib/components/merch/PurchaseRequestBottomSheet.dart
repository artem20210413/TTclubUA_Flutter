import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../Services/goods/GoodsServices.dart';
import '../../Storage/Cache/AccentColorCache.dart';
import '../../Storage/UserStorage.dart';
import '../../api/routs/Dto/Goods/GoodsDto.dart';
import '../buttons/GlowingButton.dart';
import '../generalModule.dart';
import '../inputs/BigTextInput.dart';
import '../viewers/ImagesCarousel.dart';

const int _kMaxDescriptionLength = 500;

/// Opens the purchase-request bottom sheet for [item] (FR-002-FR-011).
Future<void> showPurchaseRequestBottomSheet(
  BuildContext context,
  GoodsDto item,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: TTColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => PurchaseRequestBottomSheet(item: item),
  );
}

class PurchaseRequestBottomSheet extends StatefulWidget {
  final GoodsDto item;

  const PurchaseRequestBottomSheet({super.key, required this.item});

  @override
  State<PurchaseRequestBottomSheet> createState() =>
      _PurchaseRequestBottomSheetState();
}

class _PurchaseRequestBottomSheetState
    extends State<PurchaseRequestBottomSheet> {
  late final TextEditingController _descriptionController =
      TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final description = _descriptionController.text.trim();
    if (description.length > _kMaxDescriptionLength) {
      MessageModule(
        context,
        'Коментар не може перевищувати $_kMaxDescriptionLength символів',
        MessageType.error,
      );
      return;
    }

    if (widget.item.id == null) return;

    setState(() => _isSubmitting = true);

    final token = await UserStorage.getToken();
    final outcome = await GoodsServices.sendPurchaseRequest(
      goodsId: widget.item.id!,
      description: description,
      token: token,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (outcome.status) {
      case PurchaseRequestStatus.success:
        MessageModule(context, outcome.message, MessageType.success);
        Navigator.of(context).pop();
        break;
      case PurchaseRequestStatus.unauthorized:
        MessageModule(context, outcome.message, MessageType.error);
        break;
      case PurchaseRequestStatus.validationError:
        final errors = outcome.errors;
        final text = errors != null && errors.isNotEmpty
            ? errors.values
                .expand((v) => v is List ? v : [v])
                .map((e) => e.toString())
                .join('\n')
            : outcome.message;
        MessageModule(context, text, MessageType.error);
        break;
      case PurchaseRequestStatus.networkError:
        MessageModule(context, outcome.message, MessageType.error);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TTColors.text_secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.item.titleController.text,
              textAlign: TextAlign.center,
              style: TTTextStyle.title18,
            ),
            const SizedBox(height: 16),
            ImagesCarousel(
              images: widget.item.images,
              height: MediaQuery.of(context).size.width * 0.5,
              borderRadius: 24,
              showDots: false,
            ),
            const SizedBox(height: 16),
            BigTextInput(
              controller: _descriptionController,
              label: 'Коментар',
              hint: 'Коментар до замовлення (необов\'язково)',
              readOnly: _isSubmitting,
              minHeight: 100,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: GlowingButton(
                text: 'Підтвердити замовлення',
                colorGrowing: AccentColorCache.accentColor,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
