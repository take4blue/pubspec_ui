import 'package:flutter_test/flutter_test.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/pusbspecanalyzer.dart';
import 'package:yaml/yaml.dart';

void main() {
  group("PubspecPackageAnalizer", () {
    test("value is version", () {
      String file = """meta: ^1.8.0""";

      final target = PubspecPackageAnalizer();
      target.handle(loadYamlNode(file));
      expect(target.name, "meta");
      expect(target.version, "^1.8.0");
    });
    test("no value", () {
      String file = """meta:""";

      final target = PubspecPackageAnalizer();
      target.handle(loadYamlNode(file));
      expect(target.name, "meta");
      expect(target.version, "");
    });
    test("no value no version", () {
      String file = """excel:
  git: https://github.com/take4blue/excel
""";

      final target = PubspecPackageAnalizer();
      target.handle(loadYamlNode(file));
      expect(target.name, "excel");
      expect(target.version, "");
    });
    test("has version tag", () {
      String file = """transmogrify:
  hosted:
    name: transmogrify
    url: https://some-package-server.com
  version: ^1.4.0""";

      final target = PubspecPackageAnalizer();
      target.handle(loadYamlNode(file));
      expect(target.name, "transmogrify");
      expect(target.version, "^1.4.0");
    });
  });
  group("PubspecPackage", () {
    test("construct", () {
      const target = PubspecPackage("hoge", "hage");
      expect(target.name, "hoge");
      expect(target.version, "hage");
    });
    test("key value", () {
      String file = "meta: ^1.8.0";

      int num = 0;
      final yaml = loadYamlNode(file) as YamlMap;
      yaml.nodes.forEach((key, value) {
        final target = PubspecPackage.create(key, value);
        expect(target.name, "meta");
        expect(target.version, "^1.8.0");
        num++;
      });
      expect(num, 1);
    });
    test("no value", () {
      String file = """meta:""";

      int num = 0;
      final yaml = loadYamlNode(file) as YamlMap;
      yaml.nodes.forEach((key, value) {
        final target = PubspecPackage.create(key, value);
        expect(target.name, "meta");
        expect(target.version, "");
        num++;
      });
      expect(num, 1);
    });
    test("key vaersion", () {
      String file = """transmogrify:
  hosted:
    name: transmogrify
    url: https://some-package-server.com
  version: ^1.4.0""";

      int num = 0;
      final yaml = loadYamlNode(file) as YamlMap;
      yaml.nodes.forEach((key, value) {
        final target = PubspecPackage.create(key, value);
        expect(target.name, "transmogrify");
        expect(target.version, "^1.4.0");
        num++;
      });
      expect(num, 1);
    });
  });

  group("PubspecAnalizer", () {
    test("empty file", () {
      String file = "";

      final yaml = loadYamlNode(file);
      final target = PubspecAnalizer();
      target.handle(yaml);
      expect(target.packages.isEmpty, true);
    });
    group("dependencies", () {
      test("key value", () {
        String file = """dependencies:
  meta: ^1.8.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 1);
        expect(target.packages[0].name, "meta");
        expect(target.packages[0].version, "^1.8.0");
      });
      test("multiple data", () {
        String file = """name: hoge

environment:
  sdk: '>=2.17.0 <3.0.0'

dependencies:
  meta: ^1.8.0
  csv: ^5.0.0
  yaml: ^3.1.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 3);
        expect(target.packages[0].name, "meta");
        expect(target.packages[0].version, "^1.8.0");
        expect(target.packages[1].name, "csv");
        expect(target.packages[1].version, "^5.0.0");
        expect(target.packages[2].name, "yaml");
        expect(target.packages[2].version, "^3.1.0");
      });
      test("key version", () {
        String file = """dependencies:
  excel:
    git: https://github.com/take4blue/excel
    version: ^1.4.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 1);
        expect(target.packages[0].name, "excel");
        expect(target.packages[0].version, "^1.4.0");
      });
      test("no data1", () {
        String file = """dependencies:
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.isEmpty, true);
      });

      test("no data2", () {
        String file = """dev_dependencies:
  test: ^1.20.0
  lints: ^2.0.1
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.isEmpty, true);
      });
      test("no data3", () {
        String file = """name: hoge

environment:
  sdk: '>=2.17.0 <3.0.0'

dev_dependencies:
  test: ^1.20.0
  lints: ^2.0.1
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.isEmpty, true);
      });
    });

    group("dependency_overrides", () {
      test("key value", () {
        String file = """dependency_overrides:
  meta: ^1.8.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 1);
        expect(target.packages[0].name, "meta");
        expect(target.packages[0].version, "^1.8.0");
      });
      test("multiple data", () {
        String file = """name: hoge

environment:
  sdk: '>=2.17.0 <3.0.0'

dependency_overrides:
  meta: ^1.8.0
  csv: ^5.0.0
  yaml: ^3.1.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 3);
        expect(target.packages[0].name, "meta");
        expect(target.packages[0].version, "^1.8.0");
        expect(target.packages[1].name, "csv");
        expect(target.packages[1].version, "^5.0.0");
        expect(target.packages[2].name, "yaml");
        expect(target.packages[2].version, "^3.1.0");
      });
      test("key version", () {
        String file = """dependency_overrides:
  excel:
    git: https://github.com/take4blue/excel
    version: ^1.4.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 1);
        expect(target.packages[0].name, "excel");
        expect(target.packages[0].version, "^1.4.0");
      });
      test("no data1", () {
        String file = """dependency_overrides:
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.isEmpty, true);
      });

      test("no data2", () {
        String file = """dev_dependencies:
  test: ^1.20.0
  lints: ^2.0.1
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.isEmpty, true);
      });
      test("no data3", () {
        String file = """name: hoge

environment:
  sdk: '>=2.17.0 <3.0.0'

dev_dependencies:
  test: ^1.20.0
  lints: ^2.0.1
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.isEmpty, true);
      });
    });

    group("multi description", () {
      test("override dependency", () {
        String file = """
dependency:
  meta: ^1.8.0
dependency_overrides:
  meta: ^1.9.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 1);
        expect(target.packages[0].name, "meta");
        expect(target.packages[0].version, "^1.9.0");
      });

      test("skip dependency version", () {
        String file = """
dependency_overrides:
  meta: ^1.9.0
dependency:
  meta: ^1.8.0
""";

        final yaml = loadYamlNode(file);
        final target = PubspecAnalizer();
        target.handle(yaml);
        expect(target.packages.length, 1);
        expect(target.packages[0].name, "meta");
        expect(target.packages[0].version, "^1.9.0");
      });
    });
  });

  group("LockPackageAnalyzer", () {
    test("no data", () {
      String file = """
""";

      final yaml = loadYamlNode(file);
      final target = LockPackageAnalyzer();
      target.handle(yaml);
      expect(target.version.isEmpty, true);
      expect(target.source.isEmpty, true);
    });
    test("git", () {
      String file = '''dependency: "direct overridden"
description:
  path: "."
  ref: HEAD
  resolved-ref: "7776095f094d2ba0ca7e62136066953c8095b5c0"
  url: "https://github.com/take4blue/excel"
source: git
version: "2.0.4"
''';

      final yaml = loadYamlNode(file);
      final target = LockPackageAnalyzer();
      target.handle(yaml);
      expect(target.link, Source.git);
      expect(target.version, "2.0.4");
      expect(target.source, "https://github.com/take4blue/excel");
    });
    test("hosted", () {
      String file = '''dependency: transitive
description:
  name: file
  sha256: "1b92bec4fc2a72f59a8e15af5f52cd441e4a7860b49499d69dfa817af20e925d"
  url: "https://pub.dev"
source: hosted
version: "6.1.4"
''';

      final yaml = loadYamlNode(file);
      final target = LockPackageAnalyzer();
      target.handle(yaml);
      expect(target.link, Source.hosted);
      expect(target.version, "6.1.4");
      expect(target.source, "https://pub.dev");
    });
    test("path", () {
      String file = '''dependency: "direct overridden"
description:
  path: "../library/excel"
  relative: true
source: path
version: "2.0.4"
''';

      final yaml = loadYamlNode(file);
      final target = LockPackageAnalyzer();
      target.handle(yaml);
      expect(target.link, Source.path);
      expect(target.version, "2.0.4");
      expect(target.source, "../library/excel");
    });
  });
  test("sdk", () {
    String file = '''dependency: "direct main"
description: flutter
source: sdk
version: "0.0.0"
''';

    final yaml = loadYamlNode(file);
    final target = LockPackageAnalyzer();
    target.handle(yaml);
    expect(target.link, Source.sdk);
    expect(target.version, "0.0.0");
    expect(target.source, "");
  });

  group("PubspecMatchLock", () {
    test("no data", () {
      String file = """
""";
      const pubspec = <PubspecPackage>[
        PubspecPackage("hoge", "1.0.0"),
      ];

      final target = PubspecMatchLock(pubspec);

      target.match(file);
      expect(target.packages.isEmpty, true);
    });
    test("no match", () {
      String file = """packages:
  dame:
    dependency: transitive
    description:
      name: hoge
      sha256: "947bfcf187f74dbc5e146c9eb9c0f10c9f8b30743e341481c1e2ed3ecc18c20c"
      url: "https://pub.dev"
    source: hosted
    version: "2.11.0"
""";
      const pubspec = <PubspecPackage>[
        PubspecPackage("hoge", "1.0.0"),
      ];

      final target = PubspecMatchLock(pubspec);

      target.match(file);
      expect(target.packages.isEmpty, true);
    });
    test("match data", () {
      String file = """packages:
  hoge:
    dependency: transitive
    description:
      name: hoge
      sha256: "947bfcf187f74dbc5e146c9eb9c0f10c9f8b30743e341481c1e2ed3ecc18c20c"
      url: "https://pub.dev"
    source: hosted
    version: "2.11.0"
""";
      const pubspec = <PubspecPackage>[
        PubspecPackage("hoge", "1.0.0"),
      ];

      final target = PubspecMatchLock(pubspec);

      target.match(file);
      expect(target.packages.length, 1);
      expect(target.packages[0].name, "hoge");
      expect(target.packages[0].specVersion, "1.0.0");
      expect(target.packages[0].link, Source.hosted);
      expect(target.packages[0].lockVersion, "2.11.0");
      expect(target.packages[0].target, "https://pub.dev");
    });
    test("match datas", () {
      String file = """packages:
  hage:
    dependency: "direct overridden"
    description:
      path: "../library/excel"
      relative: true
    source: path
    version: "2.0.4"
  hoge:
    dependency: transitive
    description:
      name: hoge
      sha256: "947bfcf187f74dbc5e146c9eb9c0f10c9f8b30743e341481c1e2ed3ecc18c20c"
      url: "https://pub.dev"
    source: hosted
    version: "2.11.0"
""";
      const pubspec = <PubspecPackage>[
        PubspecPackage("hoge", "1.0.0"),
        PubspecPackage("hage", "2.0.0"),
      ];

      final target = PubspecMatchLock(pubspec);

      target.match(file);
      expect(target.packages.length, 2);
      // lockファイル側の出現順序で生成される
      int i = 0;
      expect(target.packages[i].name, "hage");
      expect(target.packages[i].specVersion, "2.0.0");
      expect(target.packages[i].link, Source.path);
      expect(target.packages[i].lockVersion, "2.0.4");
      expect(target.packages[i].target, "../library/excel");
      i++;
      expect(target.packages[i].name, "hoge");
      expect(target.packages[i].specVersion, "1.0.0");
      expect(target.packages[i].link, Source.hosted);
      expect(target.packages[i].lockVersion, "2.11.0");
      expect(target.packages[i].target, "https://pub.dev");
    });
  });
}
