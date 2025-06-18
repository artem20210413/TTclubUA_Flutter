import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/api/routs/Finance.dart';
import '../../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/Finance/FinanceItemCard.dart';
import '../../../../components/Finance/StatisticsCard.dart';
import '../../../../components/generalModule.dart';

class FinanceScreen extends StatefulWidget {
  final UserUpdateDto userDto;

  const FinanceScreen({super.key, required this.userDto});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<FinanceDto> finances = [];
  int _page = 1;
  String? _urlJak = null;
  bool _hasMore = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
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
    final response = await FINANCE_STATISTICS(token, widget.userDto.id);
    if (await CHECK_API(response, context)) {
      final Map<String, dynamic> data = jsonDecode(response.body)['data'];
      setState(() {
        _statistics = data;
      });
    }
  }

  Future<void> _linkJakCopy() async {
    if(_urlJak == null){
      final response = await FINANCE_LINK_JAK(widget.userDto.id); //FINANCE_LINK_JAK

      if (await CHECK_API(response, context)) {
        final String url = jsonDecode(response.body)['data']['url'];
        setState(() {
          _urlJak = url;
        });
      }
    }

    print(_urlJak);
    await Clipboard.setData(ClipboardData(text: _urlJak.toString()));
    MessageModule(context, 'Посилання на банку успішно скопійовано', MessageType.information);



    // final userID = await UserStorage.getUserId();
    // final link = 'https://send.monobank.ua/jar/YOUR_JAR_ID?t=User%20ID:%20$userID';
    // await Clipboard.setData(ClipboardData(text: link));
    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Посилання скопійовано')),
    //   );
    // }

  }

  Future<void> _loadFinances() async {
    setState(() => _isLoading = true);
    final token = await UserStorage.getToken();
    final res = await FINANCE_LIST(token, widget.userDto.id, page: _page);

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

  void _addFinanceDialog() {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Додати фінансовий запис'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Сума'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descController,
                decoration:
                    const InputDecoration(labelText: 'Опис (необов’язково)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Скасувати'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Додати'),
              onPressed: () async {
                final amount = amountController.text;
                if (amount == '') return;

                final dto = FinanceDto(
                  id: 0,
                  amount: amount,
                  description: descController.text,
                  createdAt: DateTime.now(),
                );

                final token = await UserStorage.getToken();
                final res = await FINANCE_SET(token, dto, widget.userDto.id);

                if (res.statusCode == 200 || res.statusCode == 201) {
                  setState(() {
                    finances.clear();
                    _page = 1;
                    _hasMore = true;
                  });
                  _loadFinances();
                  _loadStatistics();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDelete(FinanceDto finance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити запис'),
        content: const Text('Ви впевнені, що хочете видалити цей запис?'),
        actions: [
          TextButton(
            child: const Text('Скасувати'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Видалити'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final token = await UserStorage.getToken();
      final res = await FINANCE_DELETE(token, finance.id);
      if (res.statusCode == 200) {
        _loadStatistics();

        setState(() {
          finances.remove(finance);
        });
      }
    }
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Фінанси')),
        floatingActionButton: FloatingActionButton(
          onPressed: _addFinanceDialog,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            StatisticsCard(statistics: _statistics),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Копіювати посилання на банку'),
              onPressed: () async {
                _linkJakCopy();
              },
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: finances.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= finances.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final finance = finances[index];
                  return Dismissible(
                    key: Key(finance.id.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(finance),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: FinanceItemCard(finance: finance),
                  );
                },
              ),
            )
          ],
        ));
  }
}
