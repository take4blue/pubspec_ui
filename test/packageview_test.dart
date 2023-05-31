import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packageview.dart';

class MockPackageView extends PackageView {
  MockPackageView(super.data, this.latestVersion);

  final String latestVersion;

  @override
  Future<String> get latest async => latestVersion;
}

void main() {
  test('property get', () {
    const base = Package(
        name: "name",
        specVersion: "specVersion",
        lockVersion: "lockVersion",
        link: Source.path,
        target: "target");
    final target = PackageView(base);

    expect(target.name, base.name);
    expect(target.specVersion, base.specVersion);
    expect(target.lockVersion, base.lockVersion);
    expect(target.link, base.link);
    expect(target.target, base.target);
    expect(target.doUpdate, false);
  });

  group('latest', () {
    group('hosted', () {
      test('success', () async {
        final html = File("test_resources/versions.html").readAsStringSync();
        final client = MockClient(
          (request) async {
            if (request.url.toString() !=
                "https://pub.dev/packages/hoge/versions") {
              return Response("", 404);
            }
            return Response(html, 200,
                headers: {'content-type': 'text/html; charset=utf-8'});
          },
        );
        const base = Package(
            name: "hoge",
            specVersion: "3.0.0",
            lockVersion: "3.1.0",
            link: Source.hosted,
            target: "https://pub.dev");
        final target = PackageView(base);

        expect(
            await runWithClient(() async {
              return target.latest;
            }, () => client),
            "2.0.1");
      });
      test('error', () async {
        final html = File("test_resources/versions.html").readAsStringSync();
        final client = MockClient(
          (request) async {
            if (request.url.toString() !=
                "https://pub.dev/packages/hoge/versions") {
              return Response("", 404);
            }
            return Response(html, 300,
                headers: {'content-type': 'text/html; charset=utf-8'});
          },
        );

        const base = Package(
            name: "hoge",
            specVersion: "3.0.0",
            lockVersion: "3.1.0",
            link: Source.hosted,
            target: "https://pub.dev");
        final target = PackageView(base);
        expect(
            await runWithClient(() {
              return target.latest;
            }, () => client),
            "");
      });
    });
    test('not hosted', () async {
      const base = Package(
          name: "hoge",
          specVersion: "3.0.0",
          lockVersion: "3.1.0",
          link: Source.path,
          target: "https://pub.dev");
      final target = PackageView(base);
      expect(await target.latest, "");
    });
  });

  group("uriTarget", () {
    test("git", () {
      const base = Package(
          name: "excel",
          specVersion: "3.0.0",
          lockVersion: "3.1.0",
          link: Source.git,
          target: "https://github.com/take4blue/excel");
      final target = PackageView(base);
      expect(target.uriTarget.toString(), "https://github.com/take4blue/excel");
    });
    test("hosted", () {
      const base = Package(
          name: "excel",
          specVersion: "3.0.0",
          lockVersion: "3.1.0",
          link: Source.hosted,
          target: "https://pub.dev");
      final target = PackageView(base);
      expect(target.uriTarget.toString(), "https://pub.dev/packages/excel");
    });
    test("path relative", () {
      const base = Package(
          name: "excel",
          specVersion: "3.0.0",
          lockVersion: "3.1.0",
          link: Source.path,
          target: "../library/excel");
      final target = PackageView(base);
      expect(target.uriTarget,
          Uri.directory(File("../library/excel/").absolute.path));
    });
    test("path absolute", () {
      const base = Package(
          name: "excel",
          specVersion: "3.0.0",
          lockVersion: "3.1.0",
          link: Source.path,
          target: "/library/excel");
      final target = PackageView(base);
      expect(target.uriTarget,
          Uri.directory(File("/library/excel").absolute.path));
    });
    test("sdk", () {
      const base = Package(
          name: "excel",
          specVersion: "0.0.0",
          lockVersion: "0.0.0",
          link: Source.sdk,
          target: "");
      final target = PackageView(base);
      expect(target.uriTarget, Uri());
    });
  });
}
