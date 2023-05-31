import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pubspec_ui/src/packagemanager.dart';

import 'view/mainpage.dart';

void main(List<String> args) {
  // デフォルトはpubspec.yamlを使う。
  // テスト用になるがPUBSPEC_PATHが設定されていればそこに入っているyamlファイルを優先で使う。
  final path =
      const String.fromEnvironment('PUBSPEC_PATH', defaultValue: "pubspec.yaml")
          .replaceAll("'", "");
  runApp(MaterialApp(
      home: ChangeNotifierProvider(
          create: (_) => PackageManager(path)..load(), // データ生成時にロードも行う
          child: const MainPage())));
}
