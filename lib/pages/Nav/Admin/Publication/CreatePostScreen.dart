import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _submitPost() {
    String title = _titleController.text;
    String content = _contentController.text;

    if (title.isNotEmpty && content.isNotEmpty) {
      // Публикация отправлена
      print("Публикация отправлена: $title\n$content");

      // Очистить поля
      _titleController.clear();
      _contentController.clear();
    } else {
      // Ошибка, если поля пустые
      print("Пожалуйста, заполните все поля.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать публикацию')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Заголовок:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Введите заголовок',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Содержание:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Введите содержание публикации',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Опубликовать'),
            ),
          ],
        ),
      ),
    );
  }
}
