import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiTextField extends StatefulWidget {
  const UiTextField({
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.value,
    this.onChanged,
    this.decoration,
    this.inputFormatters,
    this.keyboardType,
    super.key,
  });
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final bool enableSuggestions;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  @override
  State<UiTextField> createState() => _UiTextFieldState();
}

class _UiTextFieldState extends State<UiTextField> {
  late final _controller = TextEditingController(text: widget.value);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.text = widget.value ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(final BuildContext context) => TextFormField(
        controller: _controller,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        inputFormatters: widget.inputFormatters,
        decoration: widget.decoration,
      );
}
