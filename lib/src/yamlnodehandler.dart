import 'package:yaml/yaml.dart';
export 'package:yaml/yaml.dart';

/// [YamlNode]に対するVisotrパターンを適用するためのクラス</br>
/// YamlNode側にacceptがないのですべてこちらのクラスの中で処理するようになる。
abstract class YamlNodeHandler {
  /// キーのスタック</br>
  /// YamlMapのキーをスタックしたもの
  final stackKey = <YamlNode>[];

  /// [YamlNode]の処理
  void handle(YamlNode target) {
    if (target is YamlScalar) {
      handleScalar(target);
    } else if (target is YamlList) {
      handleList(target);
    } else if (target is YamlMap) {
      handleMap(target);
    } else {
      // YamlNodeそのもの、もしくは未対応のYamlNode派生が出た場合
      // 例外出して実装を促す。
      throw ArgumentError();
    }
  }

  /// [YamlMap]の[value]を処理する。
  void handleMapValue(YamlNode value) {
    handle(value);
  }

  /// [YamlMap]の処理</br>
  /// keyに関してはstackKeyにスタックしていく。
  void handleMap(YamlMap target) {
    target.nodes.forEach((key, value) {
      stackKey.add(key);
      handleMapValue(value);
      stackKey.removeLast();
    });
  }

  /// [YamlList]の処理</br>
  /// nodesの個々の要素に対して[handle]を実行するのをsuperな処理にする。
  void handleList(YamlList target) {
    for (var value in target.nodes) {
      handle(value);
    }
  }

  /// [YamlScalar]の処理
  void handleScalar(YamlScalar target);
}
