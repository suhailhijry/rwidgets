import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// TextFieldEx
///
/// this is just a temporary text field implementation, I am currently brainstorming
/// a much better implementation.
class TextFieldEx extends StatefulWidget {
  final String initialText;
  final String hintText;
  final void Function(String) onValueChanged;
  final void Function(String) onSubmitted;
  final bool Function(String) onValidateInput;
  final String errorString;
  final TextInputAction submitAction;
  final TextDirection initialTextDirection;
  final TextAlign initialTextAlignment;
  final bool submitIfInvalid;

  TextFieldEx({
    this.initialText,
    this.hintText,
    this.onValueChanged,
    this.onSubmitted,
    this.onValidateInput,
    this.errorString,
    this.submitIfInvalid = false,
    this.submitAction = TextInputAction.go,
    this.initialTextDirection = TextDirection.ltr,
    this.initialTextAlignment = TextAlign.left,
  });

  @override
  _TextFieldExState createState() => _TextFieldExState();
}

class _TextFieldExState extends State<TextFieldEx> {
  TextEditingController _controller;
  FocusNode _focusNode;
  TextDirection _textDirection;
  TextAlign _textAlign;
  String _error;

  bool _isValueValid(String value) {
    return widget.onValidateInput?.call(value) ?? true;
  }

  void _onValueChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _textDirection = widget.initialTextDirection;
        _textAlign = widget.initialTextAlignment;
      } else {
        final isValueRTL = intl.Bidi.detectRtlDirectionality(value);
        if (isValueRTL) {
          _textDirection = TextDirection.rtl;
          _textAlign = TextAlign.right;
        } else {
          _textDirection = TextDirection.ltr;
          _textAlign = TextAlign.left;
        }
        widget.onValueChanged?.call(value);
      }

      if (!_isValueValid(value)) {
        _error = widget.errorString;
      } else {
        _error = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _textDirection = TextDirection.ltr;
    _textAlign = TextAlign.left;
    _focusNode = FocusNode();
    _textDirection = widget.initialTextDirection;
    _textAlign = widget.initialTextAlignment;
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textDirection: _textDirection,
      textAlign: _textAlign,
      controller: _controller,
      focusNode: _focusNode,
      onTap: () {
        if (!_focusNode.hasFocus) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        }
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorText: _error,
      ),
      minLines: 1,
      maxLines: null,
      textInputAction: widget.submitAction,
      onChanged: _onValueChanged,
      onSubmitted: (value) {
        value = value.trim();
        bool isValid = _isValueValid(value);
        if (isValid || widget.submitIfInvalid) {
          widget.onSubmitted?.call(value);
          _controller.text = value;
        } else {
          widget.onSubmitted?.call(widget.initialText);
          _controller.text = widget.initialText;
          _onValueChanged(widget.initialText);
        }
      },
    );
  }
}
