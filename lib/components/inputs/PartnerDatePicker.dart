import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/default.dart';

class PartnerDatePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final Function(DateTime?) onChanged;
  final Color accentColor;

  const PartnerDatePicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.accentColor = const Color(0xFFE5B80B),
  });

  Future<void> _selectDateTime(BuildContext context) async {
    // 1. Вибір дати
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(1901),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(primary: accentColor),
        ),
        child: child!,
      ),
    );

    if (date == null) return;

    // 2. Вибір часу (24-годинний формат)
    if (!context.mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
      builder: (context, child) {
        return MediaQuery(
          // Встановлюємо alwaysUse24HourFormat: true для 24-годинного вводу
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(primary: accentColor),
            ),
            child: child!,
          ),
        );
      },
    );

    if (time == null) return;

    // 3. Повертаємо об'єднаний результат
    onChanged(DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TTTextStyle.subtitle),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => _selectDateTime(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TTColors.background,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: accentColor.withOpacity(0.7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                    // Форматуємо вивід: додаємо "0" якщо хвилини < 10
                        ? "${value!.day.toString().padLeft(2, '0')}.${value!.month.toString().padLeft(2, '0')}.${value!.year.toString().padLeft(4, '0')} ${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}"
                        : "Обрати",
                    style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child:
                    SvgPicture.asset(
                      'assets/svg/trash.svg',
                      width: 18,
                      colorFilter: ColorFilter.mode(
                        TTColors.danger,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                else
                  SvgPicture.asset(
                    'assets/svg/calendar.svg',
                    width: 18,
                    colorFilter: ColorFilter.mode(
                      TTColors.text_secondary,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}