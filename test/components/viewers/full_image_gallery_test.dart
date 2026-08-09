import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';
import 'package:tt_club_ua/components/viewers/FullImageGallery.dart';

ImageUrlDto _img(int id) => ImageUrlDto(
      id: id,
      url: 'https://example.invalid/$id.jpg',
      networkImage: NetworkImage('https://example.invalid/$id.jpg'),
    );

void main() {
  testWidgets('renders the requested initial page', (tester) async {
    final images = [_img(1), _img(2), _img(3)];

    await tester.pumpWidget(MaterialApp(
      home: FullImageGallery(images: images, initialIndex: 1),
    ));
    await tester.pump();

    expect(find.byType(PageView), findsOneWidget);
    // Position indicator (dots) is shown when there is more than one image.
    expect(find.byType(AnimatedContainer), findsNWidgets(images.length));
  });

  testWidgets('hides the position indicator for a single image',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FullImageGallery(images: [_img(1)], initialIndex: 0),
    ));
    await tester.pump();

    expect(find.byType(AnimatedContainer), findsNothing);
  });

  testWidgets('show() returns the initial index immediately for empty list',
      (tester) async {
    late int result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () async {
              result = await FullImageGallery.show(
                context,
                images: const [],
                initialIndex: 4,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pump();

    expect(result, 4);
  });
}
