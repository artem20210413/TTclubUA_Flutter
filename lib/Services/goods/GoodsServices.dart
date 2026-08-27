import 'dart:convert';

import 'package:tt_club_ua/api/routs/goods.dart';

enum PurchaseRequestStatus { success, unauthorized, validationError, networkError }

class PurchaseRequestOutcome {
  final PurchaseRequestStatus status;
  final String message;
  final Map<String, dynamic>? errors;

  const PurchaseRequestOutcome._(this.status, this.message, {this.errors});

  factory PurchaseRequestOutcome.success(String message) =>
      PurchaseRequestOutcome._(PurchaseRequestStatus.success, message);

  factory PurchaseRequestOutcome.unauthorized(String message) =>
      PurchaseRequestOutcome._(PurchaseRequestStatus.unauthorized, message);

  factory PurchaseRequestOutcome.validationError(String message,
          {Map<String, dynamic>? errors}) =>
      PurchaseRequestOutcome._(PurchaseRequestStatus.validationError, message,
          errors: errors);

  factory PurchaseRequestOutcome.networkError(String message) =>
      PurchaseRequestOutcome._(PurchaseRequestStatus.networkError, message);
}

class GoodsServices {
  static Future<PurchaseRequestOutcome> sendPurchaseRequest({
    required int goodsId,
    String? description,
    required String? token,
  }) async {
    try {
      final res = await GOODS_PURCHASE_REQUEST(token, goodsId, description);
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      switch (res.statusCode) {
        case 200:
          return PurchaseRequestOutcome.success(
            body['message'] ??
                'Заявку на покупку успішно відправлено! З вами зв\'яжеться менеджер.',
          );
        case 401:
          return PurchaseRequestOutcome.unauthorized(
            body['message'] ?? 'Потрібна повторна автентифікація',
          );
        case 422:
          return PurchaseRequestOutcome.validationError(
            body['message'] ?? 'Перевірте правильність введених даних',
            errors: body['errors'],
          );
        default:
          return PurchaseRequestOutcome.networkError(
            'Помилка: ${res.statusCode}. Спробуйте ще раз.',
          );
      }
    } catch (e) {
      return PurchaseRequestOutcome.networkError(
        'Не вдалося відправити заявку. Перевірте з\'єднання з інтернетом.',
      );
    }
  }
}
