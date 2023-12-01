import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiTextField extends StatefulWidget {
  const UiTextField({
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.value,
    this.onChanged,
    this.decoration,
    this.textAlignVertical,
    this.maxLines = 1,
    this.controller,
    this.inputFormatters,
    this.keyboardType,
    this.style,
    super.key,
  });
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextAlignVertical? textAlignVertical;
  final int? maxLines;
  @override
  State<UiTextField> createState() => _UiTextFieldState();
}

class _UiTextFieldState extends State<UiTextField> {
  late final _isInnerControllerUsed = widget.controller == null;
  late final _controller =
      widget.controller ?? TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant final UiTextField oldWidget) {
    _controller.text = widget.value ?? '';
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    if (_isInnerControllerUsed) _controller.dispose();
  }

  @override
  Widget build(final BuildContext context) => TextFormField(
        controller: _controller,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        style: widget.style,
        autocorrect: widget.autocorrect,
        textAlignVertical: widget.textAlignVertical,
        maxLines: widget.maxLines,
        enableSuggestions: widget.enableSuggestions,
        inputFormatters: widget.inputFormatters,
        decoration: widget.decoration,
      );
}
