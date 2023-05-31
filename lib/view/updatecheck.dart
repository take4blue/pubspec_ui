import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packagemanager.dart';

/// 更新用のチェックボックス
class UpdateCheck extends StatelessWidget {
  const UpdateCheck(this.index, {super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    // [PackageManager.packages.doUpdate]をウォッチ
    final doUpdate = context.select<PackageManager, bool>(
        (value) => value.packages[index].doUpdate);
    final vm = context.read<PackageManager>();
    return Checkbox(
        value: doUpdate,
        onChanged: vm.packages[index].specVersion.isEmpty
            ? null
            : (value) =>
                context.read<PackageManager>().doUpdate(index, value ?? false));
  }
}
