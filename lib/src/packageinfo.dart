import 'dart:io';

import 'package:path/path.dart' as p;

import 'pusbspecanalyzer.dart';
import 'yamlnodehandler.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

/// リンク先
enum Source {
  hosted,
  path,
  git,
  sdk,
}

/// パッケージに関する情報
class Package {
  const Package(
      {required this.name,
      required this.specVersion,
      required this.lockVersion,
      required this.link,
      required this.target});

  /// パッケージ名
  final String name;

  /// pubspec側のバージョン
  final String specVersion;

  /// lock側のバージョン
  final String lockVersion;

  /// リンク先種類</br>
  /// lockファイルのsourceの内容を入れる。
  final Source link;

  /// リンク先</br>
  /// urlもしくはpathの内容をそのまま入れる
  final String target;

  /// 最新バージョンの取得</br>
  /// linkがhostedの場合のみ有効な情報が返るようになる。</br>
  /// それ以外は空文字</br>
  /// テストコードは書いてない
  Future<String> get latest async {
    if (link == Source.hosted) {
      // pubdevのversionsからstableのテーブルを検索しバージョンに関するテーブルを取得する。
      // 取得する。
      final response =
          await http.get(Uri.parse("$target/packages/$name/versions"));

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
  }

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
}

/// pubspecに関する情報を作成、保持する。</br>
/// [filename]か[yaml]/[lock]のいずれかを指定して使用する。
/// - [filename] : pubspec.yamlのファイル名。lockファイルは拡張子yamlを変更して使用する。
/// - [yaml] : pubspec.yamlのファイル内容を文字列にしたもの。
/// - [lock] : pubspec.lockのファイル内容を文字列にしたもの。
class PubspecInfo {
  /// [PubspecInfo]生成
  factory PubspecInfo.create({String? filename, String? yaml, String? lock}) {
    late YamlNode yamlnode;

    if (filename != null) {
      final yamlFile = File(filename);
      if (!yamlFile.existsSync()) {
        throw PathNotFoundException(yamlFile.path, const OSError());
      }
      final lockFile = File("${p.withoutExtension(filename)}.lock");
      if (!lockFile.existsSync()) {
        throw PathNotFoundException(lockFile.path, const OSError());
      }
      yamlnode = loadYaml(yamlFile.readAsStringSync());
      lock = lockFile.readAsStringSync();
    } else if (yaml != null && lock != null) {
      yamlnode = loadYaml(yaml);
    } else if (yaml == null || lock == null) {
      throw ArgumentError("yaml/lock is null");
    }

    final pubspec = PubspecAnalizer();
    pubspec.handle(yamlnode);

    final matcher = PubspecMatchLock(pubspec.packages);
    matcher.match(lock);

    return PubspecInfo._(matcher.packages, yamlnode);
  }

  // プライベートなコンストラクタ
  const PubspecInfo._(this.info, this.yaml);

  /// パッケージ情報
  final List<Package> info;

  /// pubspec.yamlの情報
  final YamlNode yaml;
}
