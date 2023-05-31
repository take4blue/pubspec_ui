import 'package:flutter/material.dart';
import 'package:pubspec_ui/src/packageview.dart';

/// 最新バージョンを表示するテキストの作成
/// - [Future]な部分だけをまとめた
class LatestVersion extends StatelessWidget {
  const LatestVersion(this.e, {super.key});

  final PackageView e;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: e.latest,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final value = snapshot.data ?? "?";
          return Text(
            value,
            style: value == e.lockVersion
                ? null
                : const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
          );
        } else {
          return const SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator());
        }
      },
    );
  }
}
