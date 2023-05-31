import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packagemanager.dart';
import 'package:pubspec_ui/view/updatecheck.dart';

class MockManager extends PackageManager {
  MockManager(super.path);

  List<PackageView> wPack = <PackageView>[];

  @override
  List<PackageView> get packages => wPack;
}

void main() {
  group('enable', () {
    testWidgets('not checked', (tester) async {
      final data = MockManager("hoge")
        ..packages.add(PackageView(const Package(
            name: "hgoe",
            specVersion: "specVersion",
            lockVersion: "lockVersion",
            link: Source.path,
            target: "../hoge")));
      final target = MaterialApp(
        home: ChangeNotifierProvider<PackageManager>(
            create: (_) => data, child: const Scaffold(body: UpdateCheck(0))),
      );
      await tester.pumpWidget(target);
      final widget = tester.firstWidget<Checkbox>(find.byType(Checkbox));
      expect(widget.value, false);
      expect(widget.onChanged == null, false);
    });
    testWidgets('checked', (tester) async {
      final data = MockManager("hoge")
        ..packages.add(PackageView(const Package(
            name: "hgoe",
            specVersion: "specVersion",
            lockVersion: "lockVersion",
            link: Source.path,
            target: "../hoge"))
          ..doUpdate = true);
      final target = MaterialApp(
        home: ChangeNotifierProvider<PackageManager>(
            create: (_) => data, child: const Scaffold(body: UpdateCheck(0))),
      );
      await tester.pumpWidget(target);
      final widget = tester.firstWidget<Checkbox>(find.byType(Checkbox));
      expect(widget.value, true);
      expect(widget.onChanged == null, false);
    });
  });
  group('disable', () {
    testWidgets('not checked', (tester) async {
      final data = MockManager("hoge")
        ..packages.add(PackageView(const Package(
            name: "hgoe",
            specVersion: "",
            lockVersion: "lockVersion",
            link: Source.path,
            target: "../hoge")));
      final target = MaterialApp(
        home: ChangeNotifierProvider<PackageManager>(
            create: (_) => data, child: const Scaffold(body: UpdateCheck(0))),
      );
      await tester.pumpWidget(target);
      final widget = tester.firstWidget<Checkbox>(find.byType(Checkbox));
      expect(widget.value, false);
      expect(widget.onChanged == null, true);
    });
    testWidgets('checked', (tester) async {
      final data = MockManager("hoge")
        ..packages.add(PackageView(const Package(
            name: "hgoe",
            specVersion: "",
            lockVersion: "lockVersion",
            link: Source.path,
            target: "../hoge"))
          ..doUpdate = true);
      final target = MaterialApp(
        home: ChangeNotifierProvider<PackageManager>(
            create: (_) => data, child: const Scaffold(body: UpdateCheck(0))),
      );
      await tester.pumpWidget(target);
      final widget = tester.firstWidget<Checkbox>(find.byType(Checkbox));
      expect(widget.value, true);
      expect(widget.onChanged == null, true);
    });
  });
  testWidgets('tap', (tester) async {
    final data = MockManager("hoge")
      ..packages.add(PackageView(const Package(
          name: "hgoe",
          specVersion: "specVersion",
          lockVersion: "lockVersion",
          link: Source.path,
          target: "../hoge")));
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: UpdateCheck(0))),
    );
    await tester.pumpWidget(target);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.firstWidget<Checkbox>(find.byType(Checkbox)).value, true);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.firstWidget<Checkbox>(find.byType(Checkbox)).value, false);
  });
}
