import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubspec_ui/view/filtertext.dart';

void main() {
  group('input text', () {
    testWidgets("legal text", (tester) async {
      String value = "";
      final target = MaterialApp(
          home: Scaffold(body: FilterText(onChanged: (a) => value = a)));
      await tester.pumpWidget(target);
      const text = "abcdefghijklmnopqrstuvwxyz0123456789_";
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
      expect(value, text);
      expect(find.text(text), findsOneWidget);
    });
    testWidgets("illegal text", (tester) async {
      String value = "";
      final target = MaterialApp(
          home: Scaffold(body: FilterText(onChanged: (a) => value = a)));
      await tester.pumpWidget(target);
      const success = "abc";
      await tester.enterText(find.byType(TextField), "abcA");
      await tester.pumpAndSettle();
      expect(value, success);
      expect(find.text(success), findsOneWidget);
    });

    testWidgets("no callback", (tester) async {
      const target = MaterialApp(home: Scaffold(body: FilterText()));
      await tester.pumpWidget(target);
      const text = "abcdefghijklmnopqrstuvwxyz0123456789_";
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
      expect(find.text(text), findsOneWidget);
    });
  });

  testWidgets("clear", (tester) async {
    String value = "";
    final target = MaterialApp(
        home: Scaffold(body: FilterText(onChanged: (a) => value = a)));
    await tester.pumpWidget(target);
    const text = "abcdefghijklmnopqrstuvwxyz0123456789_";
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(value.isEmpty, true);
    expect(find.text(text), findsNothing);
  });
}
