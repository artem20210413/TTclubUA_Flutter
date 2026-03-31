import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/api/routs/Finance.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Cache/DeviceInsetsCache.dart';
import '../../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/Finance/FinanceItemCard.dart';
import '../../../../components/Finance/StatisticsCard.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/BigTextInput.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';

class FinanceScreen extends StatefulWidget {
  final int userId;

  // final UserUpdateDto userOwner;

  const FinanceScreen({super.key, required this.userId});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<FinanceDto> finances = [];
  bool _isAdmin = false; // Значение по умолчанию
  int _page = 1;
  String? _urlJak = null;
  bool _hasMore = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final Color accentColor = AccentColorCache.accentColor;
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadFinances();
    _loadStatistics();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading &&
          _hasMore) {
        _loadFinances();
      }
    });
  }

  Future<void> _loadStatistics() async {
    final token = await UserStorage.getToken();
    final response = await FINANCE_STATISTICS(token, widget.userId);
    if (await CHECK_API(response, context)) {
      final Map<String, dynamic> data = jsonDecode(response.body)['data'];
      setState(() {
        _statistics = data;
      });
    }
  }

  Future<void> _linkJakCopy() async {
    if (_urlJak == null) {
      final response = await FINANCE_LINK_JAK(widget.userId); //FINANCE_LINK_JAK

      if (await CHECK_API(response, context)) {
        final String url = jsonDecode(response.body)['data']['url'];
        setState(() {
          _urlJak = url;
        });
      }
    }

    await Clipboard.setData(ClipboardData(text: _urlJak.toString()));
    MessageModule(context, 'Посилання на банку успішно скопійовано',
        MessageType.information);
  }

  Future<void> _loadFinances() async {
    setState(() => _isLoading = true);
    final token = await UserStorage.getToken();
    final res = await FINANCE_LIST(token, widget.userId, page: _page);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'] as List;
      final newItems = data.map((e) => FinanceDto.fromJson(e)).toList();

      setState(() {
        finances.addAll(newItems);
        _page++;
        _hasMore = newItems.length >= 15;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadUser() async {
    final isAdmin = await UserStorage.isAdmin();

    setState(() {
      _isAdmin = isAdmin ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      body: SafeArea(
        child: _isLoading
            ? const TTLoading()
            : Padding(
                padding: EdgeInsetsGeometry.only(top: 16),
                child: Column(
                  children: [
                    if (_statistics != null) _buildStatsSection(),
                    if (_isAdmin) _buildAdminActions(),
                    Expanded(
                      child: _buildFinanceList(),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
              accentColor: accentColor,
              onPressed: _addFinanceDialog,
            )
          : null,
    );
  }

  Widget _buildStatsSection() {
    // Тут можна використати твій StatisticsCard, але обгорнутий у дизайн
    return TTNeumorphicBox(
      margin: EdgeInsetsGeometry.only(left: 8, right: 0),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Баланс", "${_statistics!['balance'] ?? 0} ₴", accentColor),
          _statItem("Всього", "${_statistics!['total'] ?? 0} ₴", Colors.white),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TTTextStyle.subtitle),
        const SizedBox(height: 4),
        Text(value, style: TTTextStyle.title18.copyWith(color: color)),
      ],
    );
  }

  Widget _buildAdminActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlowingButton(
        text: 'Копіювати посилання на банку',
        colorGrowing: accentColor,
        onPressed: _linkJakCopy,
      ),
    );
  }

  Widget _buildFinanceList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: finances.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= finances.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: TTLoading(),
          );
        }

        final finance = finances[index];
        final card = FinanceItemCard(finance: finance); // Твій компонент

        if (!_isAdmin) return card;

        return Dismissible(
          key: Key(finance.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(finance),
          background: _buildDeleteBackground(),
          child: card,
        );
      },
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 30),
    );
  }

  // Кастомний діалог у стилі TT Club
  void _addFinanceDialog() {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20),
        decoration: BoxDecoration(
          color: TTColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Container(
          // Обмежуємо максимальну висоту шторки (наприклад, 90% екрана)
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Прокручувальна частина
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Додати запис', style: TTTextStyle.title18),
                        const SizedBox(height: 20),
                        CustomInputField(
                          controller: amountController,
                          label: 'Сума (₴)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        BigTextInput(
                          controller: descController,
                          label: 'Опис',
                          minHeight: 50,
                          minLines: 2,
                        ),
                        // CustomInputField(
                        //   controller: descController,
                        //   label: 'Опис',
                        // ),
                      ],
                    ),
                  ),
                ),

                // Кнопка "Показати" завжди зафіксована знизу
                const SizedBox(height: 24),
                GlowingButton(
                  text: 'Зберегти',
                  colorGrowing: accentColor,
                  onPressed: () async {
                    // Твоя логіка FINANCE_SET
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(FinanceDto finance) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20),
        decoration: BoxDecoration(
          color: TTColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Container(
          // Обмежуємо максимальну висоту шторки (наприклад, 90% екрана)
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text('Видалити запис?', style: TTTextStyle.title18),
                const SizedBox(height: 12),
                Text('Ця дія незворотня', style: TTTextStyle.subtitle),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Скасувати',
                            style: TextStyle(color: TTColors.text_secondary)),
                      ),
                    ),
                    Expanded(
                      child: GlowingButton(
                        text: 'Видалити',
                        colorGrowing: Colors.redAccent,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TTNeumorphicBox(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Видалити запис?', style: TTTextStyle.title18),
            const SizedBox(height: 12),
            Text('Ця дія незворотня', style: TTTextStyle.subtitle),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Скасувати',
                        style: TextStyle(color: TTColors.text_secondary)),
                  ),
                ),
                Expanded(
                  child: GlowingButton(
                    text: 'Видалити',
                    colorGrowing: Colors.redAccent,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// void _addFinanceDialog() {
//   final amountController = TextEditingController();
//   final descController = TextEditingController();
//
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Додати фінансовий запис'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: amountController,
//               decoration: const InputDecoration(labelText: 'Сума'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: descController,
//               decoration:
//                   const InputDecoration(labelText: 'Опис (необов’язково)'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             child: const Text('Скасувати'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           ElevatedButton(
//             child: const Text('Додати'),
//             onPressed: () async {
//               final amount = amountController.text;
//               if (amount == '') return;
//
//               final dto = FinanceDto(
//                 id: 0,
//                 amount: amount,
//                 description: descController.text,
//                 createdAt: DateTime.now(),
//               );
//
//               final token = await UserStorage.getToken();
//               final res = await FINANCE_SET(token, dto, widget.userId);
//
//               if (res.statusCode == 200 || res.statusCode == 201) {
//                 setState(() {
//                   finances.clear();
//                   _page = 1;
//                   _hasMore = true;
//                 });
//                 _loadFinances();
//                 _loadStatistics();
//                 Navigator.pop(context);
//               }
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<bool?> _confirmDelete(FinanceDto finance) async {
//   final confirmed = await showDialog<bool>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Видалити запис'),
//       content: const Text('Ви впевнені, що хочете видалити цей запис?'),
//       actions: [
//         TextButton(
//           child: const Text('Скасувати'),
//           onPressed: () => Navigator.pop(context, false),
//         ),
//         ElevatedButton(
//           child: const Text('Видалити'),
//           onPressed: () => Navigator.pop(context, true),
//         ),
//       ],
//     ),
//   );
//
//   if (confirmed == true) {
//     final token = await UserStorage.getToken();
//     final res = await FINANCE_DELETE(token, finance.id);
//     if (res.statusCode == 200) {
//       _loadStatistics();
//
//       setState(() {
//         finances.remove(finance);
//       });
//     }
//   }
//   return confirmed;
// }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Text('Фінанси')),
//         floatingActionButton: _isAdmin
//             ? FloatingActionButton(
//                 onPressed: _addFinanceDialog,
//                 child: const Icon(Icons.add),
//               )
//             : null,
//         body: Column(
//           children: [
//             StatisticsCard(statistics: _statistics),
//             if (_isAdmin)
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.copy),
//                 label: const Text('Копіювати посилання на банку'),
//                 onPressed: () async {
//                   _linkJakCopy();
//                 },
//               ),
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 itemCount: finances.length + (_isLoading ? 1 : 0),
//                 itemBuilder: (context, index) {
//                   if (index >= finances.length) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   final finance = finances[index];
//                   return _isAdmin
//                       ? Dismissible(
//                           key: Key(finance.id.toString()),
//                           direction: DismissDirection.endToStart,
//                           confirmDismiss: (_) => _confirmDelete(finance),
//                           background: Container(
//                             color: Colors.red,
//                             alignment: Alignment.centerRight,
//                             padding: const EdgeInsets.only(right: 20),
//                             child:
//                                 const Icon(Icons.delete, color: Colors.white),
//                           ),
//                           child: FinanceItemCard(finance: finance),
//                         )
//                       : FinanceItemCard(finance: finance);
//                 },
//               ),
//             )
//           ],
//         ));
//   }
// }
