import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';
import 'packageinfo.dart';
import 'packageview.dart';

export 'packageview.dart';

/// 表示用のパッケージ情報管理クラス
class PackageManager with ChangeNotifier {
  PackageManager(this.path);

  /// pubspec.yamlのパス
  final String path;

  /// pubspec.yamlのバッファ中身
  String _yamlBody = "";

  List<PackageView> _packages = <PackageView>[];

  /// 読み込んだパッケージの情報
  List<PackageView> get packages => _packages;

  List<int> _viewIndex = <int>[];

  /// フィルタリングした結果としてのpackageのindexをここに入れる。
  List<int> get viewIndex => _viewIndex;

  /// ファイルからデータをロード</br>
  /// 前から保持していた情報は廃棄される。
  void load() {
    final info = PubspecInfo.create(filename: path);
    _yamlBody = info.yamlBody;
    _packages = info.info.map((e) => PackageView(e)).toList();
    filter();
    _dirty = false;
    notifyListeners();
  }

  /// パッケージ情報のフィルター処理
  /// - [value]に一致したものを[viewIndex]に設定する。
  /// nullもしくは空文字の場合は全データ表示
  void filter([String? value]) {
    _viewIndex = [for (int i = 0; i < packages.length; i++) i];
    if (value != null && value.isNotEmpty) {
      _viewIndex.removeWhere((element) =>
          !packages[element].name.toLowerCase().contains(value.toLowerCase()));
    }
    notifyListeners();
  }

  /// 保存
  Future<void> save() async {
    if (_dirty) {
      final buffer = await PackageManager.update(_yamlBody, packages);
      File(path).writeAsStringSync(buffer, flush: true);
    }
    load();
  }

  bool _dirty = false;

  /// データを保存するべきかどうか
  /// - trueの場合保存するべき状態。
  bool get dirty => _dirty;

  /// 更新ボタンの更新
  /// - [index]は[packages]の位置。
  /// - [value]は更新値。
  void doUpdate(int index, bool value) {
    if (index < 0 || index >= packages.length) {
      return;
    }
    if (packages[index].doUpdate != value) {
      packages[index].doUpdate = value;

      _dirty = !packages.every((element) => !element.doUpdate);
      notifyListeners();
    }
  }

  /// Quote文字の出力
  static String _quotedString(ScalarStyle? style) {
    if (style != null) {
      switch (style) {
        case ScalarStyle.DOUBLE_QUOTED:
          return '"';
        case ScalarStyle.SINGLE_QUOTED:
          return "'";
        default:
          break;
      }
    }
    return "";
  }

  /// [PackageView]の[doUpdate]がtrueのもののバージョンを変更する
  static Future<String> update(String source, List<PackageView> data) async {
    // dataからdoUpdateがtrue、linkがhostedのみを抽出
    final target =
        data.where((e) => e.doUpdate && e.link == Source.hosted).toList();
    // さらにstartオフセット位置の昇順でソートする
    target.sort((a, b) => (a.data.specVersionPosition?.span.start.offset ?? 0)
        .compareTo(b.data.specVersionPosition?.span.start.offset ?? 0));

    String destnation = "";

    int sourcePosition = 0;
    for (final a in target) {
      if (a.data.specVersionPosition != null) {
        destnation += source.substring(
            sourcePosition, a.data.specVersionPosition!.span.start.offset);
        sourcePosition = a.data.specVersionPosition!.span.end.offset;
      }
      final qS = _quotedString(a.data.specVersionPosition?.style);
      destnation += "$qS^${await a.latest}$qS";
    }
    destnation += source.substring(sourcePosition);
    return destnation;
  }
}
