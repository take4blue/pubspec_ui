import 'dart:io';

import 'package:path/path.dart' as p;

import 'pusbspecanalyzer.dart';
import 'yamlnodehandler.dart';

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
      required this.target,
      this.specVersionPosition});

  /// パッケージ名
  final String name;

  /// pubspec側のバージョン
  final String specVersion;

  /// specVersionのyaml内情報
  final YamlScalar? specVersionPosition;

  /// lock側のバージョン
  final String lockVersion;

  /// リンク先種類</br>
  /// lockファイルのsourceの内容を入れる。
  final Source link;

  /// リンク先</br>
  /// urlもしくはpathの内容をそのまま入れる
  final String target;
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
    late String body;

    if (filename != null) {
      final yamlFile = File(filename);
      if (!yamlFile.existsSync()) {
        throw PathNotFoundException(yamlFile.path, const OSError());
      }
      final lockFile = File("${p.withoutExtension(filename)}.lock");
      if (!lockFile.existsSync()) {
        throw PathNotFoundException(lockFile.path, const OSError());
      }
      body = yamlFile.readAsStringSync();
      yamlnode = loadYaml(body);
      lock = lockFile.readAsStringSync();
    } else if (yaml != null && lock != null) {
      yamlnode = loadYaml(yaml);
      body = yaml;
    } else if (yaml == null || lock == null) {
      throw ArgumentError("yaml/lock is null");
    }

    final pubspec = PubspecAnalizer();
    pubspec.handle(yamlnode);

    final matcher = PubspecMatchLock(pubspec.packages);
    matcher.match(lock);

    return PubspecInfo._(matcher.packages, yamlnode, body);
  }

  // プライベートなコンストラクタ
  const PubspecInfo._(this.info, this.yaml, this.yamlBody);

  /// パッケージ情報
  final List<Package> info;

  /// pubspec.yamlの情報
  final YamlNode yaml;

  /// pubspec.yamlファイルの中身。
  final String yamlBody;
}
