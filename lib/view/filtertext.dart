import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// フィルターテキスト入力エリア用のウィジェット
/// - [PackageManager]との連携はしていない。
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
      }),
      decoration: InputDecoration(
          hintText: "パッケージ名でフィルター",
          suffixIcon: IconButton(
            onPressed: () => setState(() {
              widget.onChanged?.call("");
              _controller.text = "";
            }),
            icon: const Icon(Icons.clear),
          )),
    );
  }
}
