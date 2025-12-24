import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../utils/url_launcher.dart'; // Путь к твоему UrlHelper

enum IconPosition { left, right }

class PlaceLink extends StatelessWidget {
  final String? text; // Текст ссылки
  final String? iconPath; // Путь к SVG (опционально)
  final String? url; // Ссылка
  final IconPosition iconPosition;
  final TextStyle? style;
  final Color color;

  // Параметры для UrlHelper
  final String dialogTitle;
  final String dialogMessage;

  const PlaceLink({
    super.key,
    this.text,
    this.iconPath,
    this.url,
    this.iconPosition = IconPosition.right,
    this.style,
    this.color = TTColors.text_secondary,
    this.dialogTitle = 'Перехід за посиланням',
    this.dialogMessage = 'Ви збираєтесь відкрити зовнішній ресурс. Продовжити?',
  });

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  bool get _hasText => text != null && text!.trim().isNotEmpty;

  bool get _hasIcon => iconPath != null && iconPath!.trim().isNotEmpty;

  Future<void> _handleTap(BuildContext context) async {
    if (!_hasUrl) return;

    final Uri uri = Uri.parse(url!);

    // Используем твой хелпер для открытия с подтверждением
    await UrlHelper.openExternal(
      context,
      uri,
      title: dialogTitle,
      message: dialogMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasText && !_hasIcon) return const SizedBox.shrink();

    final baseStyle = style ?? TTTextStyle.subtitle.copyWith(color: TTColors.text);

    // Контент (текст + иконка)
    List<Widget> children = [
      if (_hasText)
        Flexible(
          child: Text(
            text!,
            style: baseStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (_hasText && _hasIcon) const SizedBox(width: 6),
      if (_hasIcon)
        SvgPicture.asset(
          iconPath!,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
    ];

    // Если позиция слева — переворачиваем список
    if (iconPosition == IconPosition.left) {
      children = children.reversed.toList();
    }

    return Expanded(
      child: InkWell(
        onTap: _hasUrl ? () => _handleTap(context) : null,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: iconPosition == IconPosition.left
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: children,
          ),
        ),
      ),
    );
  }
}
