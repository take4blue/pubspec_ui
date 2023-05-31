import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packagemanager.dart';
import 'package:pubspec_ui/view/linkbutton.dart';

class MockPackageView extends PackageView {
  MockPackageView(super.data);

  final Completer<String> latestString = Completer();

  bool launched = false;

  @override
  Future<String> get latest => latestString.future;

  @override
  void launch() {
    launched = true;
  }
}

void main() {
  testWidgets("git", (tester) async {
    final data = MockPackageView(const Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.git,
        target: "https://hoge/hage"));

    final target = MaterialApp(home: LinkButton(data));
    await tester.pumpWidget(target);
    expect(find.text("git"), findsOneWidget);
    final Finder tooltip = find.byType(Tooltip);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(tooltip));
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text(data.uriTarget.toString()), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(data.launched, true);
  });

  testWidgets("pubdev", (tester) async {
    final data = MockPackageView(const Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.hosted,
        target: "https://hoge/hage"));

    final target = MaterialApp(home: LinkButton(data));
    await tester.pumpWidget(target);
    expect(find.text("pubdev"), findsOneWidget);
    final Finder tooltip = find.byType(Tooltip);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(tooltip));
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text(data.uriTarget.toString()), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(data.launched, true);
  });

  testWidgets("path", (tester) async {
    final data = MockPackageView(const Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.path,
        target: "../hoge"));

    final target = MaterialApp(home: LinkButton(data));
    await tester.pumpWidget(target);
    expect(find.text("path"), findsOneWidget);
    final Finder tooltip = find.byType(Tooltip);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(tooltip));
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text(data.uriTarget.toString()), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(data.launched, true);
  });

  testWidgets("sdk", (tester) async {
    final data = MockPackageView(const Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.sdk,
        target: "https://hoge/hage"));

    final target = MaterialApp(home: LinkButton(data));
    await tester.pumpWidget(target);
    expect(find.text("sdk"), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(data.launched, false);
  });
}
