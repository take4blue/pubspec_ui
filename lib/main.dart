import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:url_launcher/url_launcher.dart';

void main(List<String> args) {
  // デフォルトはpubspec.yamlを使う。
  // テスト用になるがPUBSPEC_PATHが設定されていればそこに入っているyamlファイルを優先で使う。
  final path =
      const String.fromEnvironment('PUBSPEC_PATH', defaultValue: "pubspec.yaml")
          .replaceAll("'", "");
  runApp(MaterialApp(home: MainPage(path: path)));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.path});

  /// 解析対象とするyamlファイル。
  final String path;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 読み込んだパッケージの情報
  late List<Package> packages;

  /// フィルタリングした結果で、これを使って表示する。
  late List<Package> filterd;

  /// データ収集関数
  void get() {
    packages = PubspecInfo.create(filename: widget.path).info;
    filter("");
  }

  @override
  void initState() {
    get();
    super.initState();
  }

  /// データのフィルタリング
  void filter(String value) {
    if (value.isEmpty) {
      filterd = packages;
    } else {
      filterd = packages
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()))
          .toList(growable: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("pubspec パッケージ一覧"),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    // データの再読み込み
                    get();
                  });
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: Column(
          children: [
            FilterText(
              onChanged: (value) {
                setState(() {
                  filter(value);
                });
              },
            ),
            Expanded(child: PackageTable(packages: filterd))
          ],
        ));
  }
}

/// フィルターテキスト入力エリア用のウィジェット
class FilterText extends StatefulWidget {
  const FilterText({super.key, this.onChanged});

  /// 値変更時のコールバック
  final ValueChanged<String>? onChanged;

  @override
  State<FilterText> createState() => _FilterTextState();
}

class _FilterTextState extends State<FilterText> {
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]')),
      ],
      controller: _controller,
      onChanged: (value) => setState(() {
        widget.onChanged?.call(value);
        if (value.isEmpty) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      }),
      decoration: InputDecoration(
          hintText: "パッケージ名でフィルター",
          suffixIcon: IconButton(
            onPressed: () => setState(() {
              widget.onChanged?.call("");
              _controller.text = "";
              FocusScope.of(context).requestFocus(FocusNode());
            }),
            icon: const Icon(Icons.clear),
          )),
    );
  }
}

/// パッケージの中身を表示するデータテーブルウィジェット
class PackageTable extends StatelessWidget {
  const PackageTable({super.key, required this.packages});

  /// 表示対象とするパッケージのリスト
  final List<Package> packages;

  static String sourceName(Source value) {
    switch (value) {
      case Source.git:
        return "git";
      case Source.hosted:
        return "pubdev";
      case Source.path:
        return "path";
      case Source.sdk:
        return "sdk";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("パッケージ")),
          DataColumn(label: Text("要求バージョン")),
          DataColumn(label: Text("読込バージョン")),
          DataColumn(label: Text("latest")),
          DataColumn(label: Text("リンク")),
        ],
        rows: packages.map((e) {
          // リンク用のボタン作成
          Widget button = TextButton(
            onPressed:
                e.link != Source.sdk ? () => launchUrl(e.uriTarget) : null,
            child: Text(sourceName(e.link)),
          );
          if (e.link != Source.sdk) {
            button = Tooltip(
                message: e.uriTarget.toString(),
                waitDuration: const Duration(seconds: 1),
                child: button);
          }
          return DataRow(selected: false, cells: [
            DataCell(Text(e.name)),
            DataCell(Text(e.specVersion)),
            DataCell(Text(e.lockVersion)),
            DataCell(FutureBuilder(
              future: e.latest,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final value = snapshot.data ?? "?";
                  return Text(
                    value,
                    style: value == e.lockVersion
                        ? null
                        : const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                  );
                } else {
                  return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator());
                }
              },
            )),
            DataCell(button),
          ]);
        }).toList(),
      ),
    );
  }
}
