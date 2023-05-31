import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pubspec_ui/src/packageinfo.dart';

void main() {
  group('Package', () {
    test("construct", () {
      const target = Package(
          name: "hoge",
          specVersion: "3.0.0",
          lockVersion: "3.1.0",
          link: Source.git,
          target: "hage");
      expect(target.name, "hoge");
      expect(target.specVersion, "3.0.0");
      expect(target.lockVersion, "3.1.0");
      expect(target.link, Source.git);
      expect(target.target, "hage");
    });
  });

  group("PubspecInfo", () {
    group("normal", () {
      test('string', () {
        String yaml = """name: test
description: test description
version: 0.0.1
homepage:

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter
  yaml: ^3.1.2
""";

        String lock = """packages:
  yaml:
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

        final target = PubspecInfo.create(yaml: yaml, lock: lock);
        expect(target.info.length, 1);
        int i = 0;
        expect(target.info[i].name, "yaml");
        expect(target.info[i].specVersion, "^3.1.2");
        expect(target.info[i].link, Source.path);
        expect(target.info[i].lockVersion, "2.0.4");
        expect(target.info[i].target, "../library/excel");
        expect(target.yamlBody, yaml);
      });
      test('file', () {
        const filename = "test_resources/test1.yaml";
        final target = PubspecInfo.create(filename: filename);
        expect(target.info.length, 6);
        int i = 0;
        expect(target.info[i].name, "csv");
        expect(target.info[i].specVersion, "^5.0.0");
        expect(target.info[i].link, Source.hosted);
        expect(target.info[i].lockVersion, "5.0.1");
        expect(target.info[i].target, "https://pub.dev");
        i++;
        expect(target.info[i].name, "dart_style");
        expect(target.info[i].specVersion, "^2.0.1");
        expect(target.info[i].link, Source.path);
        expect(target.info[i].lockVersion, "2.3.0");
        expect(target.info[i].target, "../library/excel");
        i++;
        expect(target.info[i].name, "excel");
        expect(target.info[i].specVersion, "");
        expect(target.info[i].link, Source.git);
        expect(target.info[i].lockVersion, "2.0.4");
        expect(target.info[i].target, "https://github.com/take4blue/excel");
        i++;
        expect(target.info[i].name, "flutter");
        expect(target.info[i].specVersion, "");
        expect(target.info[i].link, Source.sdk);
        expect(target.info[i].lockVersion, "0.0.0");
        expect(target.info[i].target, "");
        i++;
        expect(target.info[i].name, "meta");
        expect(target.info[i].specVersion, "^1.8.0");
        expect(target.info[i].link, Source.hosted);
        expect(target.info[i].lockVersion, "1.9.1");
        expect(target.info[i].target, "https://pub.dev");
        i++;
        expect(target.info[i].name, "yaml");
        expect(target.info[i].specVersion, "^3.1.0");
        expect(target.info[i].link, Source.hosted);
        expect(target.info[i].lockVersion, "3.1.1");
        expect(target.info[i].target, "https://pub.dev");

        expect(target.yamlBody, File(filename).readAsStringSync());
      });
    });
    group('exception', () {
      test('no string', () {
        try {
          final target = PubspecInfo.create();
          expect(target.info.isEmpty, false); // ここに来ないはず
        } on ArgumentError catch (e) {
          expect(e.message, "yaml/lock is null");
        }
        try {
          final target = PubspecInfo.create(yaml: "hoge");
          expect(target.info.isEmpty, false); // ここに来ないはず
        } on ArgumentError catch (e) {
          expect(e.message, "yaml/lock is null");
        }
        try {
          final target = PubspecInfo.create(lock: "hoge");
          expect(target.info.isEmpty, false); // ここに来ないはず
        } on ArgumentError catch (e) {
          expect(e.message, "yaml/lock is null");
        }
      });
      test('yaml file not found', () {
        try {
          final target = PubspecInfo.create(filename: "test_resources/no.yaml");
          expect(target.info.isEmpty, false); // ここに来ないはず
        } on PathNotFoundException catch (e) {
          expect(e.path, "test_resources/no.yaml");
        }
      });
      test('lock file not found', () {
        try {
          final target =
              PubspecInfo.create(filename: "test_resources/nolock.yaml");
          expect(target.info.isEmpty, false); // ここに来ないはず
        } on PathNotFoundException catch (e) {
          expect(e.path, "test_resources/nolock.lock");
        }
      });
    });
  });
}
