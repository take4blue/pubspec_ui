import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packagemanager.dart';
import 'package:pubspec_ui/view/latestversion.dart';

class MockPackageView extends PackageView {
  MockPackageView(super.data);

  final Completer<String> latestString = Completer();

  @override
  Future<String> get latest => latestString.future;
}

void main() {
  testWidgets("waiting", (tester) async {
    final data = MockPackageView(const Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.hosted,
        target: "target"));

    final target = LatestVersion(data);
    await tester.pumpWidget(target);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testGoldens("latest equal lockVersion", (tester) async {
    final data = MockPackageView(const Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.hosted,
        target: "target"));

    final target = LatestVersion(data);
    await tester.pumpWidgetBuilder(target);
    await screenMatchesGolden(
      tester,
      'waiting',
      customPump: (tester) async =>
          await tester.pump(const Duration(milliseconds: 500)),
    );
    data.latestString.complete("lockVersion");
    await screenMatchesGolden(tester, 'equal_done');
  });

  testGoldens("latest not equal lockVersion", (tester) async {
    final data = MockPackageView(const Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.hosted,
        target: "target"));

    final target = LatestVersion(data);
    await tester.pumpWidgetBuilder(target);
    data.latestString.complete("hoge");
    await screenMatchesGolden(tester, 'not_done');
  });
}
