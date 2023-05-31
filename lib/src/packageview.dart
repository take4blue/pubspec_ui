import 'dart:io';

import 'package:async/async.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'packageinfo.dart';

/// Packageを表示するためのView情報
class PackageView {
  PackageView(Package data) : _data = data;

  final Package _data;

  /// パッケージ情報
  Package get data => _data;

  /// パッケージ名
  String get name => _data.name;

  /// pubspec側のバージョン
  String get specVersion => _data.specVersion;

  /// lock側のバージョン
  String get lockVersion => _data.lockVersion;

  /// リンク先種類</br>
  /// lockファイルのsourceの内容を入れる。
  Source get link => _data.link;

  /// リンク先</br>
  /// urlもしくはpathの内容をそのまま入れる
  String get target => _data.target;

  /// pubspec側を更新してくれというフラグ</br>
  /// trueの場合hostedのみ"^${latest}"で更新する。
  bool doUpdate = false;

  /// latest情報のキャッシュ
  final _latest = AsyncMemoizer<String>();

  /// 最新バージョンを得る。</br>
  /// 内部的には[Completer]で情報をキャッシュしている。
  Future<String> get latest => _latest.runOnce(() async {
        if (link == Source.hosted) {
          // pubdevのversionsからstableのテーブルを検索しバージョンに関するテーブルを取得する。
          // 取得する。
          final uri = Uri.parse("$target/packages/$name/versions");
          final response = await http.get(uri);

          // 下の行のコメントを外すことで、返されたHTMLを出力できる。
          // print(response.body);

          // ステータスコードをチェックする。「200 OK」以外のときはその旨を表示して終了する。
          if (response.statusCode == 200) {
            // 取得したHTMLのボディをパースする。
            final document = parse(response.body);

            // 要素を絞り込んで、結果を文字列のリストで得る。
            final stable = document.querySelector('h2[id="stable"]');
            if (stable != null && stable.nextElementSibling != null) {
              final result = stable.nextElementSibling!
                  .querySelectorAll('tr[data-version]')
                  .map((v) {
                return v.attributes["data-version"];
              }).toList();
              if (result.isNotEmpty) {
                return result.first ?? "";
              }
            }
          }
        }
        return "";
      });

  /// URIターゲットを取得する
  Uri get uriTarget {
    late Uri to;
    switch (link) {
      case Source.git:
        to = Uri.parse(target);
        break;
      case Source.hosted:
        to = Uri.parse("$target/packages/$name");
        break;
      case Source.path:
        to = Uri.directory(File(target).absolute.path);
        break;
      case Source.sdk:
        to = Uri();
        break;
    }
    return to;
  }

  /// ページジャンプ
  void launch() {
    launchUrl(uriTarget);
  }
}
