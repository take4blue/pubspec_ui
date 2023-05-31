import 'package:flutter/material.dart';
import 'package:pubspec_ui/src/packageinfo.dart';
import 'package:pubspec_ui/src/packageview.dart';

/// リンク用のボタン
class LinkButton extends StatelessWidget {
  const LinkButton(this.e, {super.key});

  final PackageView e;

  static String _sourceName(Source value) {
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
    Widget button = TextButton(
      onPressed: e.link != Source.sdk ? () => e.launch() : null,
      child: Text(_sourceName(e.link)),
    );
    if (e.link != Source.sdk) {
      button = Tooltip(
          message: e.uriTarget.toString(),
          waitDuration: const Duration(seconds: 1),
          child: button);
    }
    return button;
  }
}
