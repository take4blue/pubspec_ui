import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packagemanager.dart';

import 'filtertext.dart';
import 'packagetable.dart';
import 'saveicon.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ウィジェットの更新はなし
    final vm = context.read<PackageManager>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("pubspec パッケージ一覧"),
          actions: [
            const SaveIcon(),
            IconButton(onPressed: vm.load, icon: const Icon(Icons.refresh))
          ],
        ),
        body: Column(
          children: [
            FilterText(onChanged: vm.filter),
            const Expanded(child: PackageTable())
          ],
        ));
  }
}
  