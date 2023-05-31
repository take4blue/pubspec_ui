import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packagemanager.dart';
import 'package:pubspec_ui/view/mainpage.dart';

class MockManager extends PackageManager {
  MockManager(super.path);

  List<PackageView> wPack = <PackageView>[];

  @override
  List<PackageView> get packages => wPack;

  bool tapLoad = false;

  String filterText = "";

  @override
  void load() {
    tapLoad = true;
  }

  @override
  void filter([String? value]) {
    filterText = value ?? "";
  }

  void superFilter() {
    super.filter();
  }
}

void main() {
  testWidgets('title', (tester) async {
    final data = MockManager("hoge")
      ..packages.add(PackageView(const Package(
          name: "hgoe",
          specVersion: "specVersion",
          lockVersion: "lockVersion",
          link: Source.path,
          target: "../hoge")));
    data.superFilter(); // これでviewIndexの再構築をする
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: MainPage())),
    );
    await tester.pumpWidget(target);

    expect(find.text("pubspec パッケージ一覧"), findsOneWidget);
  });

  testGoldens('mainpageview', (tester) async {
    final data = MockManager("hoge");
    data.packages.add(PackageView(const Package(
        name: "aaaa",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.path,
        target: "../hoge")));
    data.packages.add(PackageView(const Package(
        name: "bbbb",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.path,
        target: "../hoge")));
    data.packages.add(PackageView(const Package(
        name: "cccc",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.path,
        target: "../hoge")));

    data.superFilter(); // これでviewIndexの再構築をする
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: MainPage())),
    );
    await tester.pumpWidget(target);
    await screenMatchesGolden(tester, 'mainpageview');
  });

  group('event', () {
    testWidgets('reload', (tester) async {
      final data = MockManager("hoge")
        ..packages.add(PackageView(const Package(
            name: "hgoe",
            specVersion: "specVersion",
            lockVersion: "lockVersion",
            link: Source.path,
            target: "../hoge")));
      data.superFilter(); // これでviewIndexの再構築をする
      final target = MaterialApp(
        home: ChangeNotifierProvider<PackageManager>(
            create: (_) => data, child: const Scaffold(body: MainPage())),
      );
      await tester.pumpWidget(target);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(data.tapLoad, true);
    });
    testWidgets('filter', (tester) async {
      final data = MockManager("hoge")
        ..packages.add(PackageView(const Package(
            name: "hgoe",
            specVersion: "specVersion",
            lockVersion: "lockVersion",
            link: Source.path,
            target: "../hoge")));
      data.superFilter(); // これでviewIndexの再構築をする
      final target = MaterialApp(
        home: ChangeNotifierProvider<PackageManager>(
            create: (_) => data, child: const Scaffold(body: MainPage())),
      );
      await tester.pumpWidget(target);
      await tester.enterText(find.byType(TextField), "hoge");
      await tester.pump();
      expect(data.filterText, "hoge");
    });
  });
}
