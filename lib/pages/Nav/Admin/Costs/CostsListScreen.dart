import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import '../../../../api/routs/Dto/Costs/CostsDto.dart';
import '../../../../api/routs/costs.dart';

class CostsListScreen extends StatefulWidget {
  @override
  _CostsListScreenState createState() => _CostsListScreenState();
}

class _CostsListScreenState extends State<CostsListScreen> {
  List<CostsDto> _costs = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final token = await UserStorage.getToken();
    final res = await COSTS_LIST(token, page: _page);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'] as List;
      final newItems = data.map((e) => CostsDto.fromJson(e)).toList();

      setState(() {
        _page++;
        _costs.addAll(newItems);
        _hasMore = newItems.length == 15;
      });
    }

    setState(() => _isLoading = false);
  }

  void _openEdit(CostsDto dto) {
    // переход на форму редактирования
  }

  void _openCreate() {
    // переход на форму создания
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Витрати')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: Icon(Icons.add),
        tooltip: 'Додати витрату',
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
           // print('NEXT!!!!');
           // print(_page);
          if (!_isLoading &&
              _hasMore &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 100),
          itemCount: _costs.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _costs.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final cost = _costs[index];
            return ListTile(
              title: Text('${cost.amount} ₴'),
              subtitle: Text(cost.description),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _openEdit(cost),
              ),
            );
          },
        ),
      ),
    );
  }
}
