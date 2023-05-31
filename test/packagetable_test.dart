import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packagemanager.dart';
import 'package:pubspec_ui/view/packagetable.dart';

class MockManager extends PackageManager {
  MockManager(super.path);

  List<PackageView> wPack = <PackageView>[];

  @override
  List<PackageView> get packages => wPack;
}

void main() {
  testWidgets('header', (tester) async {
    final data = MockManager("hoge")
      ..packages.add(PackageView(const Package(
          name: "hgoe",
          specVersion: "specVersion",
          lockVersion: "lockVersion",
          link: Source.path,
          target: "../hoge")));
    data.filter(); // これでviewIndexの再構築をする
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: PackageTable())),
    );
    await tester.pumpWidget(target);

    final text = find.byType(Text);
    int index = 0;
    expect(tester.widget<Text>(text.at(index)).data, "パッケージ");
    index++;
    expect(tester.widget<Text>(text.at(index)).data, "要求バージョン");
    index++;
    expect(tester.widget<Text>(text.at(index)).data, "更新");
    index++;
    expect(tester.widget<Text>(text.at(index)).data, "読込バージョン");
    index++;
    expect(tester.widget<Text>(text.at(index)).data, "latest");
    index++;
    expect(tester.widget<Text>(text.at(index)).data, "リンク");
    index++;
  });

  testGoldens('not filterd', (tester) async {
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

    data.filter(); // これでviewIndexの再構築をする
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: PackageTable())),
    );
    await tester.pumpWidget(target);
    await screenMatchesGolden(tester, 'not_filterd');
  });

  testGoldens('filterd', (tester) async {
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

    data.filter("a"); // これでviewIndexの再構築をする
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: PackageTable())),
    );
    await tester.pumpWidget(target);
    await screenMatchesGolden(tester, 'filterd');
  });
}
