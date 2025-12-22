import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../TTLoading.dart';

class TileButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final int? newCount;
  final bool isLoading;

  const TileButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
    this.newCount,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<TileButton> createState() => _TileButtonState();
}

class _TileButtonState extends State<TileButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: widget.isLoading ? null : widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TTColors.input,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 32, color: widget.iconColor),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TTTextStyle.title.copyWith(fontSize: 15),
                  ),
                ),
                if (widget.newCount != null && widget.newCount! > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.newCount}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                SizedBox(width: 8),
                widget.isLoading
                    ? const TTLoading(size: 30)
                    : Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
