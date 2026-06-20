import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/TTNeumorphicBox.dart';

import '../../../../api/routs/Dto/ExternalCars/ExternalCarFilter.dart';
import '../../../../components/TTCheckbox.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/buttons/GlowingButton.dart';
import 'ExternalCarFilterDataDto.dart';

class BuyingCarsFilter extends StatefulWidget {
  final ExternalCarFilterDto filter;
  final ExternalCarFilterDataDto filterData;
  final Color accentColor;

  final VoidCallback onClear;
  final VoidCallback onApply;

  // final List<GeneDto> genes;
  // final List<ModelDto> models;
  // final List<ColorDto> colors;

  /// ТЕКУЩИЕ ВЫБРАННЫЕ ФИЛЬТРЫ (мультивыбор)
  // final List<GeneDto> selectedGenes;
  // final List<ModelDto> selectedModels;
  // final List<ColorDto> selectedColors;
  // final TextEditingController cityController;

  // final ValueChanged<List<GeneDto>> onGenesChanged;
  // final ValueChanged<List<ModelDto>> onModelsChanged;
  final ValueChanged<ExternalCarFilterDto> onFilterChanged;

  //
  // final VoidCallback onClear;
  // final VoidCallback onApply;

  const BuyingCarsFilter({
    super.key,
    required this.filter,
    required this.accentColor,
    required this.onClear,
    required this.onApply,
    required this.filterData,
    required this.onFilterChanged,
  });

  @override
  State<BuyingCarsFilter> createState() => _BuyingCarsFilterState();
}

class _BuyingCarsFilterState extends State<BuyingCarsFilter> {
  // late List<GeneDto> _genesSelected;
  // late List<ModelDto> _modelsSelected;
  // late List<ColorDto> _colorsSelected;

  @override
  void initState() {
    super.initState();
  }

  bool _containsSubCategories(String g) =>
      widget.filter.subCategoryController.text == g;

  //
  // bool _containsModel(ModelDto m) => _modelsSelected.any((x) => x.id == m.id);

  void _toggleSubCategories(String g) {
    setState(() {
      if (widget.filter.subCategoryController.text == g) {
        widget.filter.subCategoryController.clear();
      } else {
        widget.filter.subCategoryController.text = g;
      }
    });
    widget.onFilterChanged(widget.filter);
  }

  // void _toggleModel(ModelDto m) {
  //   setState(() {
  //     if (_containsModel(m)) {
  //       _modelsSelected.removeWhere((x) => x.id == m.id);
  //     } else {
  //       _modelsSelected.add(m);
  //     }
  //   });
  //   widget.onModelsChanged(_modelsSelected);
  // }

  void _toggleColor(String c) {
    setState(() {
      // Перевіряємо, чи є колір УЖЕ ВИБРАНИМ у нашому фільтрі
      if (widget.filter.selectedColors.contains(c)) {
        widget.filter.selectedColors.remove(c);
      } else {
        widget.filter.selectedColors.add(c);
      }
    });
    widget.onFilterChanged(widget.filter);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        // Обмежуємо максимальну висоту шторки (наприклад, 90% екрана)
        constraints: BoxConstraints(
          maxHeight: MediaQuery
              .of(context)
              .size
              .height * 0.8,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: TTColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Важливо для BottomSheet
            children: [
            // Фіксована "ручка" зверху
            Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Прокручувальна частина
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Твій Хедер ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Фільтри', style: TTTextStyle.title18),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.onClear();
                          });
                        },
                        child: Text('Скинути',
                            style: TTTextStyle.subtitle
                                .copyWith(color: TTColors.text_secondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Тільки свої (TT Club) ---

                  TTCheckbox(
                    label: 'Тільки свої (TT Club ua)',
                    activeNotifier: widget.filter.onlyOursNotifier,
                    accentColor: widget.accentColor,
                    style: TTTextStyle.subtitle,
                  ),
                  const SizedBox(height: 16),
                  // --- Рік випуску ---
                  _buildLabel('Рік випуску'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomInputField(
                          controller: widget.filter.yearFromController,
                          label: 'Від ${widget.filterData.minYear}',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInputField(
                          controller: widget.filter.yearToController,
                          label: 'До ${widget.filterData.maxYear}',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Ціна ($) ---
                  _buildLabel('Ціна (USD)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomInputField(
                          controller: widget.filter.priceFromController,
                          label: 'Ціна від ${widget.filterData.minPrice}',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInputField(
                          controller: widget.filter.priceToController,
                          label: 'Ціна до ${widget.filterData.maxPrice}',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Номерний знак ---
                  _buildLabel('Держ. номер'),
                  const SizedBox(height: 8),
                  CustomInputField(
                    controller: widget.filter.plateNumberController,
                    label: 'AA0000AA',
                    // textCapitalization: TextCapitalization.characters, // Авто-капс для номерів
                  ),
                  const SizedBox(height: 16),
                  // ─── Місто ────────────────────────────────
                  _buildLabel('Місто'),
                  const SizedBox(height: 8),
                  CustomInputField(
                    controller: widget.filter.cityController,
                    label: 'Наприклад: Київ',
                  ),
                  const SizedBox(height: 16),
                  // ─── Покоління ────────────────────────────
                  if (widget.filterData.subCategories.isNotEmpty) ...[
                    _buildLabel('Тип'),
                    const SizedBox(height: 8),
                    _buildChipsRow<String>(
                      items: widget.filterData.subCategories,
                      isSelected: _containsSubCategories,
                      label: (g) => g,
                      onTap: _toggleSubCategories,
                    ),
                    const SizedBox(height: 16),
                  ],
                  // ─── Колір ────────────────────────────────
                  if (widget.filterData.colors.isNotEmpty) ...[
                    _buildLabel('Колір'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.filterData.colors.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          final colorHEX = widget.filterData.colors[index];

                          // перетворюємо hex у Color
                          final color = Color(
                            int.parse(
                                "0xFF${colorHEX.replaceFirst('#', '')}"),
                          ); // У itemBuilder:
                          final selected = widget.filter.selectedColors
                              .contains(colorHEX);

                          return GestureDetector(
                            onTap: () => _toggleColor(colorHEX),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black.withOpacity(0.35),
                                  width: selected ? 2 : 1.2,
                                ),
                                boxShadow: [
                                  if (selected)
                                    BoxShadow(
                                      color: widget.accentColor
                                          .withOpacity(0.35),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        // Кнопка "Показати" завжди зафіксована знизу
        const SizedBox(height: 16),
        GlowingButton(
          text: 'Показати',
          colorGrowing: widget.accentColor,
          onPressed: () {
            widget.onApply();
            Navigator.pop(context);
          },
        ),
        ],
      ),
    ),)
    ,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
  //     decoration: BoxDecoration(
  //       color: TTColors.background,
  //       borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  //     ),
  //     child: SafeArea(
  //       top: false,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 40,
  //             height: 4,
  //             margin: const EdgeInsets.only(bottom: 12),
  //             decoration: BoxDecoration(
  //               color: widget.accentColor.withOpacity(0.4),
  //               // color: Colors.white24,
  //               borderRadius: BorderRadius.circular(2),
  //             ),
  //           ),
  //           // ─── Хедер ────────────────────────────────
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Фільтри',
  //                 style: TTTextStyle.title18,
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   // setState(() {
  //                   //   _genesSelected.clear();
  //                   //   _modelsSelected.clear();
  //                   //   _colorsSelected.clear();
  //                   //   widget.cityController.clear();
  //                   // });
  //                   widget.onClear();
  //                 },
  //                 child: Text(
  //                   'Скинути',
  //                   style: TTTextStyle.subtitle.copyWith(
  //                     color: TTColors.text_secondary,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //
  //           // ─── Покоління ────────────────────────────
  //           // if (widget.genes.isNotEmpty) ...[
  //           //   _buildLabel('Покоління'),
  //           //   const SizedBox(height: 8),
  //           //   _buildChipsRow<GeneDto>(
  //           //     items: widget.genes,
  //           //     isSelected: _containsGene,
  //           //     label: (g) => g.name,
  //           //     onTap: _toggleGene,
  //           //   ),
  //           //   const SizedBox(height: 16),
  //           // ],
  //
  //           // ─── Модель ───────────────────────────────
  //           // if (widget.models.isNotEmpty) ...[
  //           //   _buildLabel('Модель'),
  //           //   const SizedBox(height: 8),
  //           //   _buildChipsRow<ModelDto>(
  //           //     items: widget.models,
  //           //     isSelected: _containsModel,
  //           //     label: (m) => m.name,
  //           //     onTap: _toggleModel,
  //           //   ),
  //           //   const SizedBox(height: 16),
  //           // ],
  //
  //           // ─── Колір ────────────────────────────────
  //           // if (widget.colors.isNotEmpty) ...[
  //           //   _buildLabel('Колір'),
  //           //   const SizedBox(height: 8),
  //           //   SizedBox(
  //           //     height: 44,
  //           //     child: ListView.separated(
  //           //       scrollDirection: Axis.horizontal,
  //           //       itemCount: widget.colors.length,
  //           //       separatorBuilder: (_, __) => const SizedBox(width: 8),
  //           //       itemBuilder: (_, index) {
  //           //         final colorDto = widget.colors[index];
  //           //
  //           //         // перетворюємо hex у Color
  //           //         final color = Color(
  //           //           int.parse(colorDto.hex.replaceFirst('#', '0xff')),
  //           //         );
  //           //
  //           //         final selected = _containsColor(colorDto);
  //           //
  //           //         return GestureDetector(
  //           //           onTap: () => _toggleColor(colorDto),
  //           //           child: AnimatedContainer(
  //           //             duration: const Duration(milliseconds: 100),
  //           //             width: 32,
  //           //             height: 32,
  //           //             decoration: BoxDecoration(
  //           //               color: const Color(0xFF1E1E1E),
  //           //               shape: BoxShape.circle,
  //           //               border: Border.all(
  //           //                 color: selected
  //           //                     ? Colors.white
  //           //                     : Colors.black.withOpacity(0.35),
  //           //                 width: selected ? 2 : 1.2,
  //           //               ),
  //           //               boxShadow: [
  //           //                 if (selected)
  //           //                   BoxShadow(
  //           //                     color: widget.accentColor.withOpacity(0.35),
  //           //                     blurRadius: 5,
  //           //                     spreadRadius: 1,
  //           //                   ),
  //           //                 BoxShadow(
  //           //                   color: Colors.black.withOpacity(0.45),
  //           //                   blurRadius: 10,
  //           //                   offset: const Offset(0, 2),
  //           //                 ),
  //           //               ],
  //           //             ),
  //           //             alignment: Alignment.center,
  //           //             child: Container(
  //           //               width: 20,
  //           //               height: 20,
  //           //               decoration: BoxDecoration(
  //           //                 color: color,
  //           //                 shape: BoxShape.circle,
  //           //               ),
  //           //             ),
  //           //           ),
  //           //         );
  //           //       },
  //           //     ),
  //           //   ),
  //           //   const SizedBox(height: 16),
  //           // ],
  //           // --- Тільки свої (TT Club) ---
  //           ValueListenableBuilder<bool>(
  //             valueListenable: widget.filter.onlyOursNotifier,
  //             builder: (context, value, child) {
  //               return SwitchListTile(
  //                 contentPadding: EdgeInsets.zero,
  //                 title: Text('Тільки від учасників клубу',
  //                     style: TTTextStyle.subtitle),
  //                 activeColor: widget.accentColor,
  //                 value: value,
  //                 onChanged: (bool newValue) {
  //                   widget.filter.onlyOursNotifier.value = newValue;
  //                 },
  //               );
  //             },
  //           ),
  //           const SizedBox(height: 16),
  //           // --- Рік випуску ---
  //           _buildLabel('Рік випуску'),
  //           const SizedBox(height: 8),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: CustomInputField(
  //                   controller: widget.filter.yearFromController,
  //                   label: 'Від ${widget.filterData.minYear}',
  //                   keyboardType: TextInputType.number,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: CustomInputField(
  //                   controller: widget.filter.yearToController,
  //                   label: 'До ${widget.filterData.maxYear}',
  //                   keyboardType: TextInputType.number,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           // --- Ціна ($) ---
  //           _buildLabel('Ціна (USD)'),
  //           const SizedBox(height: 8),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: CustomInputField(
  //                   controller: widget.filter.priceFromController,
  //                   label: 'Ціна від ${widget.filterData.minPrice}',
  //                   keyboardType: TextInputType.number,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: CustomInputField(
  //                   controller: widget.filter.priceToController,
  //                   label: 'Ціна до ${widget.filterData.maxPrice}',
  //                   keyboardType: TextInputType.number,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           // --- Номерний знак ---
  //           _buildLabel('Держ. номер'),
  //           const SizedBox(height: 8),
  //           CustomInputField(
  //             controller: widget.filter.plateNumberController,
  //             label: 'AA0000AA',
  //             // textCapitalization: TextCapitalization.characters, // Авто-капс для номерів
  //           ),
  //           const SizedBox(height: 16),
  //           // ─── Місто ────────────────────────────────
  //           _buildLabel('Місто'),
  //           const SizedBox(height: 8),
  //           CustomInputField(
  //             controller: widget.filter.cityController,
  //             label: 'Наприклад: Київ',
  //           ),
  //           const SizedBox(height: 20),
  //
  //           // ─── Кнопка Показати ──────────────────────
  //           GlowingButton(
  //             text: 'Показати',
  //             colorGrowing: widget.accentColor,
  //             onPressed: () {
  //               widget.onApply();
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TTTextStyle.subtitle.copyWith(
          color: TTColors.text_secondary,
        ),
      ),
    );
  }

  Widget _buildChipsRow<T>({
    required List<T> items,
    required bool Function(T) isSelected,
    required String Function(T) label,
    required ValueChanged<T> onTap,
  }) {
    return Align(
      alignment: Alignment.centerLeft, // Гарантуємо притискання до лівого краю
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            final selected = isSelected(item);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onTap(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected ? TTColors.card : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? widget.accentColor
                          : TTColors.text_secondary,
                    ),
                  ),
                  child: Text(
                    label(item),
                    style: TTTextStyle.subtitle.copyWith(
                      fontSize: 13,
                      color: selected
                          ? widget.accentColor
                          : TTColors.text_secondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
