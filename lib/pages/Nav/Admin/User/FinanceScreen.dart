import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/api/routs/Finance.dart';
import '../../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../api/routs/root.dart';

class FinanceScreen extends StatefulWidget {
  final UserUpdateDto userDto;

  const FinanceScreen({super.key, required this.userDto});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<FinanceDto> finances = [];
  int _page = 1;
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
        setState(() {
          finances.remove(finance);
        });
      }
    }
    return confirmed;
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) return SizedBox();

    String formatDouble(String? value) =>
        value == null ? '—' : double.parse(value).toStringAsFixed(2);

    String formatDate(String? value) => value == null
        ? '—'
        : DateFormat('dd.MM.yyyy').format(DateTime.parse(value));

    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Статистика',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            Text('💰 Всього: ${_statistics!['all_sum']} грн'),
            Text('📅 За рік: ${_statistics!['last_year']} грн'),
            Text(
                '🗓️ За місяць: ${_statistics!['last_month']} грн'),
            SizedBox(height: 10),
            Text(
                '🔢 Кількість внесків: ${_statistics!['total_payments_count']}'),
            Text(
                '⚖️ Середній платіж: ${formatDouble(_statistics!['average_payment'])} грн'),
            Text(
                '⬆️ Найбільший: ${formatDouble(_statistics!['largest_payment'])} грн'),
            Text(
                '⬇️ Найменший: ${formatDouble(_statistics!['smallest_payment'])} грн'),
            SizedBox(height: 10),
            Text(
                '🕓 Останній платіж: ${formatDate(_statistics!['last_payment_date'])}'),
            Text(
                '🕓 Перший платіж: ${formatDate(_statistics!['first_payment_date'])}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(finance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.savings_outlined, color: Colors.pink),
        title: Text(
          '${finance.amount} грн',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (finance.description.isNotEmpty)
              Text(finance.description)
            else
              const Text('Без опису', style: TextStyle(color: Colors.grey)),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(finance.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
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
            _buildStatisticsCard(),
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
                    child: _buildStatItem(finance)
                  );
                },
              ),
            )
          ],
        ));
  }
}
