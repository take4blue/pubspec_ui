import 'packageinfo.dart';
import 'yamlnodehandler.dart';

// こちらのファイルは、[PubspecInfo]を作るための補助用クラス類

/// pubspec.lockのpackagesの第3段目からsource, version, 取得先を取り出す</br>
/// handlerに渡すのは第2段目のvalue側。
class LockPackageAnalyzer extends YamlNodeHandler {
  Source link = Source.hosted;
  String version = "";
  String source = "";

  @override
  void handleScalar(YamlScalar target) {
    if (stackKey.isNotEmpty) {
      if (stackKey.last.value == "version") {
        version = target.value;
      }
      if (stackKey.last.value == "source") {
        switch (target.value as String) {
          case "path":
            link = Source.path;
            break;
          case "git":
            link = Source.git;
            break;
          case "hosted":
            link = Source.hosted;
            break;
          case "sdk":
            link = Source.sdk;
            break;
        }
      }
      if (stackKey.last.value == "url") {
        source = target.value;
      }
      if (stackKey.last.value == "path") {
        source = target.value;
      }
    }
  }
}

/// lockファイルとの突合せを行い[Package]を作成する
class PubspecMatchLock extends YamlNodeHandler {
  PubspecMatchLock(this.pubspec);

  /// [PubspecAnalizer]で読み込んだpackages情報をnameでソートしたもの
  final List<PubspecPackage> pubspec;

  /// 突合せ結果
  final List<Package> packages = <Package>[];

  /// pubspec.lockの中身
  void match(String lock) {
    final yaml = loadYamlNode(lock);
    handle(yaml);
  }

  @override
  void handleMapValue(YamlNode value) {
    if (stackKey.isNotEmpty) {
      if (stackKey.length == 2 && stackKey[0].value == "packages") {
        final index =
            pubspec.indexWhere((element) => element.name == stackKey[1].value);
        if (index != -1) {
          final lock = LockPackageAnalyzer();
          lock.handle(value);
          packages.add(Package(
              name: pubspec[index].name,
              specVersion: pubspec[index].version,
              lockVersion: lock.version,
              link: lock.link,
              target: lock.source));
        }
        return;
      }
    }
    super.handleMapValue(value);
  }

  @override
  void handleScalar(YamlScalar target) {}
}

/// PubspecPackage生成用のためのYamlパーサー
class PubspecPackageAnalizer extends YamlNodeHandler {
  PubspecPackageAnalizer({YamlNode? key}) {
    if (key != null) {
      stackKey.add(key);
    }
  }
  String name = "";
  String version = "";

  @override
  void handleScalar(YamlScalar target) {
    if (stackKey.isNotEmpty) {
      name = stackKey[0].value;
      if (stackKey.length == 1 && target.value != null) {
        version = target.value;
      }
    }
    if (stackKey.last.value == "version" && target.value != null) {
      version = target.value;
    }
  }
}

/// pubspec側のpackage情報
class PubspecPackage {
  /// [YamlMap]の中身である<Kye(YamlNode), value(YamlNode)>からパッケージ情報を取得する
  factory PubspecPackage.create(YamlNode key, YamlNode value) {
    final analyzer = PubspecPackageAnalizer(key: key);
    analyzer.handle(value);
    return PubspecPackage(analyzer.name, analyzer.version);
  }

  const PubspecPackage(this.name, this.version);

  /// パッケージ名
  final String name;

  /// pubspec.yaml側の要求バージョン
  final String version;
}

/// pubspec側の読み込み用</br>
/// dependenciesを読み込みList<PubspecPackage>を作成する
class PubspecAnalizer extends YamlNodeHandler {
  final List<PubspecPackage> packages = <PubspecPackage>[];

  @override
  void handleMapValue(YamlNode value) {
    if (stackKey.length >= 2 && stackKey[0].value == "dependencies") {
      // dependenciesの2段目でpackagesの生成処理を行う
      packages.add(PubspecPackage.create(stackKey[1], value));
    } else {
      super.handleMapValue(value);
    }
  }

  @override
  void handleScalar(YamlScalar target) {}
}
