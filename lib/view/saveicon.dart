import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packagemanager.dart';

/// 保存アイコン
class SaveIcon extends StatelessWidget {
  const SaveIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // [PackageManager.dirty]が更新された時に更新
    final dirty = context.select<PackageManager, bool>((value) => value.dirty);
    return IconButton(
        onPressed: dirty ? context.read<PackageManager>().save : null,
        icon: const Icon(Icons.save));
  }
}
