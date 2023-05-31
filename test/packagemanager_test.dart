import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packagemanager.dart';
import 'package:pubspec_ui/src/pusbspecanalyzer.dart';
import 'package:pubspec_ui/src/yamlnodehandler.dart';

class MockPackageView extends PackageView {
  MockPackageView(super.data, this.latestVersion);

  final String latestVersion;

  @override
  Future<String> get latest async => latestVersion;
}

void main() {
  group('no update', () {
    test('empty', () async {
      final data = <PackageView>[];
      expect(await PackageManager.update("hoge", data), "hoge");
    });

    test('no host', () async {
      final data = <PackageView>[
        PackageView(const Package(
            name: "excel",
            specVersion: "3.0.0",
            lockVersion: "3.1.0",
            link: Source.git,
            target: "../library/excel"))
          ..doUpdate = true,
        PackageView(const Package(
            name: "excel",
            specVersion: "3.0.0",
            lockVersion: "3.1.0",
            link: Source.path,
            target: "../library/excel"))
          ..doUpdate = true,
        PackageView(const Package(
            name: "excel",
            specVersion: "3.0.0",
            lockVersion: "3.1.0",
            link: Source.sdk,
            target: "../library/excel"))
          ..doUpdate = true,
      ];
      expect(await PackageManager.update("hoge", data), "hoge");
    });
    test('doUpdate=false', () async {
      final data = <PackageView>[
        PackageView(const Package(
            name: "excel",
            specVersion: "3.0.0",
            lockVersion: "3.1.0",
            link: Source.hosted,
            target: "../library/excel")),
      ];
      expect(await PackageManager.update("hoge", data), "hoge");
    });
  });
  group('update', () {
    test('single', () async {
      String file = """dependencies:
  meta: ^1.8.0
""";
      final yaml = PubspecAnalizer()..handle(loadYamlNode(file));

      final data = <PackageView>[
        MockPackageView(
            Package(
                name: yaml.packages[0].name,
                specVersion: yaml.packages[0].version,
                specVersionPosition: yaml.packages[0].yamlVersion,
                link: Source.hosted,
                lockVersion: "hoge",
                target: "hoge"),
            "2.1.0")
          ..doUpdate = true,
      ];
      expect(await PackageManager.update(file, data), """dependencies:
  meta: ^2.1.0
""");
    });

    group('many', () {
      test('accending', () async {
        String file = """dependencies:
  meta: ^1.8.0
  csv: ^5.0.0
  yaml: ^3.1.0
""";
        final yaml = PubspecAnalizer()..handle(loadYamlNode(file));

        final data = <PackageView>[
          MockPackageView(
              Package(
                  name: yaml.packages[0].name,
                  specVersion: yaml.packages[0].version,
                  specVersionPosition: yaml.packages[0].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "2.1.0")
            ..doUpdate = true,
          MockPackageView(
              Package(
                  name: yaml.packages[1].name,
                  specVersion: yaml.packages[1].version,
                  specVersionPosition: yaml.packages[1].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "5.1.0")
            ..doUpdate = true,
          MockPackageView(
              Package(
                  name: yaml.packages[2].name,
                  specVersion: yaml.packages[2].version,
                  specVersionPosition: yaml.packages[2].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "3.2.0")
            ..doUpdate = true,
        ];
        expect(await PackageManager.update(file, data), """dependencies:
  meta: ^2.1.0
  csv: ^5.1.0
  yaml: ^3.2.0
""");
      });
      test('decending', () async {
        String file = """dependencies:
  meta: ^1.8.0
  csv: ^5.0.0
  yaml: ^3.1.0
""";
        final yaml = PubspecAnalizer()..handle(loadYamlNode(file));

        final data = <PackageView>[
          MockPackageView(
              Package(
                  name: yaml.packages[2].name,
                  specVersion: yaml.packages[2].version,
                  specVersionPosition: yaml.packages[2].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "3.2.0")
            ..doUpdate = true,
          MockPackageView(
              Package(
                  name: yaml.packages[1].name,
                  specVersion: yaml.packages[1].version,
                  specVersionPosition: yaml.packages[1].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "5.1.0")
            ..doUpdate = true,
          MockPackageView(
              Package(
                  name: yaml.packages[0].name,
                  specVersion: yaml.packages[0].version,
                  specVersionPosition: yaml.packages[0].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "2.1.0")
            ..doUpdate = true,
        ];
        expect(await PackageManager.update(file, data), """dependencies:
  meta: ^2.1.0
  csv: ^5.1.0
  yaml: ^3.2.0
""");
      });
      test('skip data', () async {
        String file = """dependencies:
  meta: ^1.8.0
  csv: ^5.0.0
  yaml: ^3.1.0
""";
        final yaml = PubspecAnalizer()..handle(loadYamlNode(file));

        final data = <PackageView>[
          MockPackageView(
              Package(
                  name: yaml.packages[2].name,
                  specVersion: yaml.packages[2].version,
                  specVersionPosition: yaml.packages[2].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "3.2.0"),
          MockPackageView(
              Package(
                  name: yaml.packages[1].name,
                  specVersion: yaml.packages[1].version,
                  specVersionPosition: yaml.packages[1].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "5.1.0")
            ..doUpdate = true,
          MockPackageView(
              Package(
                  name: yaml.packages[0].name,
                  specVersion: yaml.packages[0].version,
                  specVersionPosition: yaml.packages[0].yamlVersion,
                  link: Source.git,
                  lockVersion: "hoge",
                  target: "hoge"),
              "2.1.0")
            ..doUpdate = true,
        ];
        expect(await PackageManager.update(file, data), """dependencies:
  meta: ^1.8.0
  csv: ^5.1.0
  yaml: ^3.1.0
""");
      });
    });

    test('comment', () async {
      String file = """environment:
  sdk: '>=2.17.0 <3.0.0'

dependencies:
  meta: ^1.8.0 #comment

#comment
""";
      final yaml = PubspecAnalizer()..handle(loadYamlNode(file));

      final data = <PackageView>[
        MockPackageView(
            Package(
                name: yaml.packages[0].name,
                specVersion: yaml.packages[0].version,
                specVersionPosition: yaml.packages[0].yamlVersion,
                link: Source.hosted,
                lockVersion: "hoge",
                target: "hoge"),
            "2.1.10")
          ..doUpdate = true,
      ];
      expect(await PackageManager.update(file, data), """environment:
  sdk: '>=2.17.0 <3.0.0'

dependencies:
  meta: ^2.1.10 #comment

#comment
""");
    });
    group('quote', () {
      test('single', () async {
        String file = """dependencies:
  meta: '^1.8.0'
""";
        final yaml = PubspecAnalizer()..handle(loadYamlNode(file));

        final data = <PackageView>[
          MockPackageView(
              Package(
                  name: yaml.packages[0].name,
                  specVersion: yaml.packages[0].version,
                  specVersionPosition: yaml.packages[0].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "2.1.0")
            ..doUpdate = true,
        ];
        expect(await PackageManager.update(file, data), """dependencies:
  meta: '^2.1.0'
""");
      });
      test('double', () async {
        String file = '''dependencies:
  meta: "^1.8.0"
''';
        final yaml = PubspecAnalizer()..handle(loadYamlNode(file));

        final data = <PackageView>[
          MockPackageView(
              Package(
                  name: yaml.packages[0].name,
                  specVersion: yaml.packages[0].version,
                  specVersionPosition: yaml.packages[0].yamlVersion,
                  link: Source.hosted,
                  lockVersion: "hoge",
                  target: "hoge"),
              "2.1.0")
            ..doUpdate = true,
        ];
        expect(await PackageManager.update(file, data), '''dependencies:
  meta: "^2.1.0"
''');
      });
    });
  });

  test('load', () {
    final target = PackageManager("test_resources/test1.yaml");
    target.load();
    expect(target.packages.length, 6);
    int i = 0;
    expect(target.packages[i].name, "csv");
    expect(target.viewIndex[i], i);
    i++;
    expect(target.packages[i].name, "dart_style");
    expect(target.viewIndex[i], i);
    i++;
    expect(target.packages[i].name, "excel");
    expect(target.viewIndex[i], i);
    i++;
    expect(target.packages[i].name, "flutter");
    expect(target.viewIndex[i], i);
    i++;
    expect(target.packages[i].name, "meta");
    expect(target.viewIndex[i], i);
    i++;
    expect(target.packages[i].name, "yaml");
    expect(target.viewIndex[i], i);
    i++;
    expect(target.dirty, false);
  });

  group('doUpdate', () {
    group('true', () {
      test('first', () {
        final target = PackageManager("test_resources/test1.yaml");
        target.load();
        target.doUpdate(0, true);
        expect(target.packages[0].doUpdate, true);
        for (int i = 1; i < target.packages.length; i++) {
          expect(target.packages[i].doUpdate, false);
        }
        expect(target.dirty, true);
      });
      test('last', () {
        final target = PackageManager("test_resources/test1.yaml");
        target.load();
        target.doUpdate(5, true);
        expect(target.packages[5].doUpdate, true);
        for (int i = 0; i < target.packages.length - 1; i++) {
          expect(target.packages[i].doUpdate, false);
        }
        expect(target.dirty, true);
      });
    });
    group('false', () {
      test('first', () {
        final target = PackageManager("test_resources/test1.yaml");
        target.load();
        target.doUpdate(0, true);
        target.doUpdate(0, false);
        for (int i = 0; i < target.packages.length; i++) {
          expect(target.packages[i].doUpdate, false);
        }
        expect(target.dirty, false);
      });
      test('last', () {
        final target = PackageManager("test_resources/test1.yaml");
        target.load();
        target.doUpdate(5, true);
        target.doUpdate(5, false);
        for (int i = 0; i < target.packages.length; i++) {
          expect(target.packages[i].doUpdate, false);
        }
        expect(target.dirty, false);
      });
    });
    group('invalid index', () {
      test('under', () {
        final target = PackageManager("test_resources/test1.yaml");
        target.load();
        expect(target.dirty, false);
        target.doUpdate(-1, true);
        for (int i = 0; i < target.packages.length; i++) {
          expect(target.packages[i].doUpdate, false);
        }
        expect(target.dirty, false);
      });
      test('over', () {
        final target = PackageManager("test_resources/test1.yaml");
        target.load();
        expect(target.dirty, false);
        target.doUpdate(6, true);
        for (int i = 0; i < target.packages.length; i++) {
          expect(target.packages[i].doUpdate, false);
        }
        expect(target.dirty, false);
      });
    });
  });

  group('filter', () {
    test('lower case', () {
      final target = PackageManager("test_resources/test1.yaml");
      target.load();
      target.filter("ex");
      expect(target.viewIndex.length, 1);
      int i = 0;
      expect(target.viewIndex[i], 2);
    });
    test('upper case', () {
      final target = PackageManager("test_resources/test1.yaml");
      target.load();
      target.filter("EX");
      expect(target.viewIndex.length, 1);
      int i = 0;
      expect(target.viewIndex[i], 2);
    });
    test('empty length', () {
      final target = PackageManager("test_resources/test1.yaml");
      target.load();
      target.filter("ex");
      target.filter("");

      expect(target.viewIndex.length, 6);
      int i = 0;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
    });
    test('null', () {
      final target = PackageManager("test_resources/test1.yaml");
      target.load();
      target.filter("ex");
      target.filter();

      expect(target.viewIndex.length, 6);
      int i = 0;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
      i++;
      expect(target.viewIndex[i], i);
    });
  });

  group('save', () {
    final temp = Directory.systemTemp;
    final yaml = "${temp.path}/test4.yaml";
    final lock = "${temp.path}/test4.lock";
    setUp(() {
      File("test_resources/test4.yaml").copySync(yaml);
      File("test_resources/test4.lock").copySync(lock);
    });
    tearDown(() {
      File(yaml).deleteSync();
      File(lock).deleteSync();
    });
    test('not dirty', () async {
      final html = File("test_resources/versions.html").readAsStringSync();
      final client = MockClient(
        (request) async {
          if (!request.url.toString().startsWith("https://pub.dev/packages")) {
            return Response("", 404);
          }
          return Response(html, 200,
              headers: {'content-type': 'text/html; charset=utf-8'});
        },
      );

      final target = PackageManager(yaml)..load();

      await runWithClient(() async {
        for (final pack in target.packages) {
          await pack.latest;
        }
      }, () => client);

      await target.save();

      expect(File("test_resources/test4.yaml").readAsStringSync(),
          File(yaml).readAsStringSync());
    });

    test('dirty', () async {
      final html = File("test_resources/versions.html").readAsStringSync();
      final client = MockClient(
        (request) async {
          if (!request.url.toString().startsWith("https://pub.dev/packages")) {
            return Response("", 404);
          }
          return Response(html, 200,
              headers: {'content-type': 'text/html; charset=utf-8'});
        },
      );

      final target = PackageManager(yaml)..load();

      await runWithClient(() async {
        for (final pack in target.packages) {
          await pack.latest;
        }
      }, () => client);

      final metaindex = target.packages.indexWhere((e) => e.name == "meta");
      target.doUpdate(metaindex, true);
      await target.save();

      expect(File(yaml).readAsStringSync(), """name: hoge

environment:
  sdk: '>=2.17.0 <3.0.0'

# comment

dependencies:
  flutter:
    sdk: flutter
  meta: ^2.0.1   # comment
  csv: ^5.0.0  # comment
  yaml: ^3.1.0
  dart_style:
    path: ../library/excel
    version: ^2.0.1
  excel:
    git: https://github.com/take4blue/excel

dev_dependencies:
  test: ^1.20.0
  lints: ^2.0.1

# comment """);
      // リロードされて新しい情報になっているかのチェック
      expect(target.packages.firstWhere((e) => e.name == "meta").specVersion,
          "^2.0.1");
    });
  });
}
