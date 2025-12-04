import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/TTNeumorphicBox.dart';

import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../api/routs/Dto/Car/ColorDto.dart';
import '../../../api/routs/Dto/Car/GeneDto.dart';
import '../../../api/routs/Dto/Car/ModelDto.dart';

class CarFilterSheet extends StatefulWidget {
  final List<GeneDto> genes;
  final List<ModelDto> models;
  final List<ColorDto> colors;

  /// ТЕКУЩИЕ ВЫБРАННЫЕ ФИЛЬТРЫ (мультивыбор)
  final List<GeneDto> selectedGenes;
  final List<ModelDto> selectedModels;
  final List<ColorDto> selectedColors;
  final TextEditingController cityController;

  final Color accentColor;

  final ValueChanged<List<GeneDto>> onGenesChanged;
  final ValueChanged<List<ModelDto>> onModelsChanged;
  final ValueChanged<List<ColorDto>> onColorsChanged;

  final VoidCallback onClear;
  final VoidCallback onApply;

  const CarFilterSheet({
    super.key,
    required this.genes,
    required this.models,
    required this.colors,
    required this.selectedGenes,
    required this.selectedModels,
    required this.selectedColors,
    required this.cityController,
    required this.accentColor,
    required this.onGenesChanged,
    required this.onModelsChanged,
    required this.onColorsChanged,
    required this.onClear,
    required this.onApply,
  });

  @override
  State<CarFilterSheet> createState() => _CarFilterSheetState();
}

class _CarFilterSheetState extends State<CarFilterSheet> {
  late List<GeneDto> _genesSelected;
  late List<ModelDto> _modelsSelected;
  late List<ColorDto> _colorsSelected;

  @override
  void initState() {
    super.initState();
    _genesSelected = List<GeneDto>.from(widget.selectedGenes);
    _modelsSelected = List<ModelDto>.from(widget.selectedModels);
    _colorsSelected = List<ColorDto>.from(widget.selectedColors);
  }

  bool _containsGene(GeneDto g) => _genesSelected.any((x) => x.id == g.id);

  bool _containsModel(ModelDto m) => _modelsSelected.any((x) => x.id == m.id);

  bool _containsColor(ColorDto c) => _colorsSelected.any((x) => x.id == c.id);

  void _toggleGene(GeneDto g) {
    setState(() {
      if (_containsGene(g)) {
        _genesSelected.removeWhere((x) => x.id == g.id);
      } else {
        _genesSelected.add(g);
      }
    });
    widget.onGenesChanged(_genesSelected);
  }

  void _toggleModel(ModelDto m) {
    setState(() {
      if (_containsModel(m)) {
        _modelsSelected.removeWhere((x) => x.id == m.id);
      } else {
        _modelsSelected.add(m);
      }
    });
    widget.onModelsChanged(_modelsSelected);
  }

  void _toggleColor(ColorDto c) {
    setState(() {
      if (_containsColor(c)) {
        _colorsSelected.removeWhere((x) => x.id == c.id);
      } else {
        _colorsSelected.add(c);
      }
    });
    widget.onColorsChanged(_colorsSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: TTColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.4),
                // color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ─── Хедер ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Фільтри',
                  style: TTTextStyle.title18,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _genesSelected.clear();
                      _modelsSelected.clear();
                      _colorsSelected.clear();
                      widget.cityController.clear();
                    });
                    widget.onClear();
                  },
                  child: Text(
                    'Скинути',
                    style: TTTextStyle.subtitle.copyWith(
                      color: TTColors.text_secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Покоління ────────────────────────────
            if (widget.genes.isNotEmpty) ...[
              _buildLabel('Покоління'),
              const SizedBox(height: 8),
              _buildChipsRow<GeneDto>(
                items: widget.genes,
                isSelected: _containsGene,
                label: (g) => g.name,
                onTap: _toggleGene,
              ),
              const SizedBox(height: 16),
            ],

            // ─── Модель ───────────────────────────────
            if (widget.models.isNotEmpty) ...[
              _buildLabel('Модель'),
              const SizedBox(height: 8),
              _buildChipsRow<ModelDto>(
                items: widget.models,
                isSelected: _containsModel,
                label: (m) => m.name,
                onTap: _toggleModel,
              ),
              const SizedBox(height: 16),
            ],

            // ─── Колір ────────────────────────────────
            if (widget.colors.isNotEmpty) ...[
              _buildLabel('Колір'),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.colors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final colorDto = widget.colors[index];

                    // перетворюємо hex у Color
                    final color = Color(
                      int.parse(colorDto.hex.replaceFirst('#', '0xff')),
                    );

                    final selected = _containsColor(colorDto);

                    return GestureDetector(
                      onTap: () => _toggleColor(colorDto),
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
                                color: widget.accentColor.withOpacity(0.35),
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

            // ─── Місто ────────────────────────────────
            _buildLabel('Місто'),
            const SizedBox(height: 8),
            CustomInputField(
              controller: widget.cityController,
              label: 'Наприклад: Київ',
            ),
            const SizedBox(height: 20),

            // ─── Кнопка Показати ──────────────────────
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
      ),
    );
  }

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
    return SingleChildScrollView(
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
                    color:
                        selected ? widget.accentColor : TTColors.text_secondary,
                  ),
                ),
                child: Text(
                  label(item),
                  style: TTTextStyle.subtitle.copyWith(
                    fontSize: 13,
                    color:
                        selected ? widget.accentColor : TTColors.text_secondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
