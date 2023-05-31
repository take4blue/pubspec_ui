import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packagemanager.dart';
import 'package:pubspec_ui/view/saveicon.dart';

class MockManager extends PackageManager {
  MockManager(super.path);

  bool wDirty = false;

  bool executeSave = false;

  @override
  Future<void> save() async {
    executeSave = true;
  }

  @override
  bool get dirty => wDirty;
}

void main() {
  testWidgets("false", (tester) async {
    final data = MockManager("hoge");
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: SaveIcon())),
    );
    await tester.pumpWidget(target);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, null);
    expect(data.executeSave, false);
  });

  testWidgets("true", (tester) async {
    final data = MockManager("hoge")..wDirty = true;
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: SaveIcon())),
    );
    await tester.pumpWidget(target);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        data.save);
    expect(data.executeSave, false);
  });

  testWidgets("tap", (tester) async {
    final data = MockManager("hoge")..wDirty = true;
    final target = MaterialApp(
      home: ChangeNotifierProvider<PackageManager>(
          create: (_) => data, child: const Scaffold(body: SaveIcon())),
    );
    await tester.pumpWidget(target);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(data.executeSave, true);
  });
}
