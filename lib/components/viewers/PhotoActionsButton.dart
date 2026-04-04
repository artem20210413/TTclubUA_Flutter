import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/config/default.dart';

import '../buttons/CircleButton.dart';

class PhotoActionsButton extends StatelessWidget {
  final VoidCallback? onChange;
  final VoidCallback? onDelete;
  final Widget? additionally;
  final Color accentColor;
  final String title;

  const PhotoActionsButton({
    super.key,
    required this.accentColor,
    required this.title,
    this.additionally,
    this.onChange,
    this.onDelete,
  });

  bool get _hasAnyAction => onChange != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    // Если нет ни одного действия — вообще не показываем кнопку
    if (!_hasAnyAction) return const SizedBox.shrink();

    return CircleButton(
      accentColor: accentColor,
      iconAsset: 'assets/svg/gear-six.svg',
      onTap: () {
        _showActionsSheet(context);
      },
    );
  }

  void _showActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TTColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.4),
                    // color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  title,
                  style: TTTextStyle.title18,
                ),
                const SizedBox(height: 12),
                if (onChange != null)
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 3),
                    leading: SvgPicture.asset(
                      width: 24,
                      height: 24,
                      'assets/svg/image_add.svg',
                      // 'assets/svg/trash.svg',
                      colorFilter: ColorFilter.mode(
                        accentColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: Text(
                      'Змінити фото',
                      style: TTTextStyle.subtitle,
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onChange?.call();
                    },
                  ),
                if (onDelete != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SvgPicture.asset(
                      width: 30,
                      height: 30,
                      'assets/svg/trash.svg',
                      colorFilter: ColorFilter.mode(
                        accentColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: Text(
                      'Видалити фото',
                      style: TTTextStyle.subtitle,
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onDelete?.call();
                    },
                  ),
                if (additionally != null) additionally!,
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
