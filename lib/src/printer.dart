import 'dart:io';

import 'yamlnodehandler.dart';

/// Yamlの印刷クラス
class Printer extends YamlNodeHandler {
  Printer({required this.output, required this.input});

  /// 出力先
  final IOSink output;

  /// 解析対象とするYamlの中身
  final String input;

  /// [input]に対して出力処理をしている位置
  int _next = 0;

  /// 印刷開始
  void start() {
    _next = 0;
    handle(loadYamlNode(input));
    if (_next < input.length) {
      stdout.write(input.substring(_next));
      _next = input.length;
    }
    stdout.write("\n");
  }

  @override
  void handleList(YamlList target) {
    _writeNext(target.span.start.offset);
    super.handleList(target);
    _writeNext(target.span.end.offset);
    _next = target.span.end.offset + 1;
  }

  @override
  void handleScalar(YamlScalar target) {
    _writeNext(target.span.start.offset);
    if (target.value != null) {
      // target.valueはString前提で処理をしている
      _writeQuoted(target.style);
      output.write(target.value);
      _writeQuoted(target.style);
    }
    _next = target.span.end.offset;
  }

  /// [_next]から[next]までのデータを出力する
  void _writeNext(int next) {
    output.write(input.substring(_next, next));
    _next = next;
  }

  /// Quote文字の出力
  void _writeQuoted(ScalarStyle style) {
    switch (style) {
      case ScalarStyle.DOUBLE_QUOTED:
        output.write('"');
        break;
      case ScalarStyle.SINGLE_QUOTED:
        output.write("'");
        break;
      case ScalarStyle.ANY:
        break;
      case ScalarStyle.FOLDED:
        break;
      case ScalarStyle.LITERAL:
        break;
      case ScalarStyle.PLAIN:
        break;
    }
  }
}
