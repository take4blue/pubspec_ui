import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packagemanager.dart';

import 'latestversion.dart';
import 'linkbutton.dart';
import 'updatecheck.dart';

/// パッケージの中身を表示するデータテーブルウィジェット
class PackageTable extends StatelessWidget {
  const PackageTable({super.key});

  @override
  Widget build(BuildContext context) {
    // [PackageManager]をウォッチ
    final vm = context.watch<PackageManager>();
    final filterd = vm.viewIndex;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("パッケージ")),
          DataColumn(label: Text("要求バージョン")),
          DataColumn(label: Text("更新")),
          DataColumn(label: Text("読込バージョン")),
          DataColumn(label: Text("latest")),
          DataColumn(label: Text("リンク")),
        ],
        rows: filterd
            .map((e) => DataRow(selected: false, cells: [
                  DataCell(Text(vm.packages[e].name)),
                  DataCell(Text(vm.packages[e].specVersion)),
                  DataCell(UpdateCheck(e)),
                  DataCell(Text(vm.packages[e].lockVersion)),
                  DataCell(LatestVersion(vm.packages[e])),
                  DataCell(LinkButton(vm.packages[e])),
                ]))
            .toList(),
      ),
    );
  }
}
