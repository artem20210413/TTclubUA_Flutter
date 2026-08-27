import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/root.dart';

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(MaterialApp(
    home: Builder(builder: (context) {
      capturedContext = context;
      return const Scaffold(body: SizedBox());
    }),
  ));
  await tester.pump();
  return capturedContext;
}

void main() {
  testWidgets('shows the friendly access-denied message on 403',
      (tester) async {
    final context = await _pumpContext(tester);
    final res = http.Response('{"message":"Forbidden"}', 403);

    final result = await CHECK_API(res, context);
    await tester.pump();

    expect(result, isFalse);
    expect(find.text('У вас немає прав для цієї дії'), findsOneWidget);
    expect(find.textContaining('Error: 403'), findsNothing);
  });

  testWidgets('still shows the raw error message for non-403 codes',
      (tester) async {
    final context = await _pumpContext(tester);
    final res = http.Response('{"message":"Server error"}', 500);

    final result = await CHECK_API(res, context);
    await tester.pump();

    expect(result, isFalse);
    expect(find.textContaining('Error: 500'), findsOneWidget);
    expect(find.text('У вас немає прав для цієї дії'), findsNothing);
  });

  testWidgets('403 with a malformed/empty body still shows the friendly message',
      (tester) async {
    final context = await _pumpContext(tester);
    final res = http.Response('', 403);

    final result = await CHECK_API(res, context);
    await tester.pump();

    expect(result, isFalse);
    expect(find.text('У вас немає прав для цієї дії'), findsOneWidget);
  });
}
