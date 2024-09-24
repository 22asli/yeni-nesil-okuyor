import 'dart:async';
import 'package:bookapp/core/core_alert_dialog.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatefulWidget {
  const TextFormFieldWidget({
    super.key,
    required this.hintText,
    this.isObsecure = false,
    this.icon,
    required this.controller,
    this.keyboardType,
    this.validateUrl = false,
    this.minCharacters,
    this.maxCharacters = 50,
    this.maxLines = 1,
    this.minLines = 1,
    required this.isValid,
    this.validateEmail = false,
    this.validatePhoneNumber = false,
    this.validatePassword = false,
    this.capital,
  });

  final String hintText;
  final bool isObsecure;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool validateUrl;
  final int? minCharacters;
  final int? maxCharacters;
  final int? maxLines;
  final int? minLines;
  final ValueNotifier<bool> isValid;
  final bool validateEmail;
  final bool validatePhoneNumber;
  final bool validatePassword;
  final TextCapitalization? capital;

  @override
  State<TextFormFieldWidget> createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  late bool _isObsecure;
  late BorderRadius _borderRadius;
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _isObsecure = widget.isObsecure;
    _borderRadius = BorderRadius.circular(3);
    _errorMessage = null;

    try {
      widget.controller.addListener(_debounceValidation);
    } catch (e) {
      debugPrint(e.toString());
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _borderRadius = BorderRadius.circular(10);
        });
      } else {
        setState(() {
          _borderRadius = BorderRadius.circular(3);
        });
      }
    });
  }

  void _debounceValidation() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(seconds: 0), () {
      bool valid = true;
      int minChars = widget.minCharacters ?? 3;

      if (widget.validateUrl && !Uri.parse(widget.controller.text).isAbsolute) {
        valid = false;
        _errorMessage = 'Lütfen Geçerli Bir URL Giriniz';
      } else if (widget.validateEmail &&
          !isValidEmail(widget.controller.text)) {
        valid = false;
        _errorMessage = 'Lütfen Geçerli Bir Mail Adresi Giriniz';
      } else if (widget.validatePhoneNumber &&
          !isValidPhoneNumber(widget.controller.text)) {
        valid = false;
        _errorMessage = 'Lütfen Geçerli Bir Telefon Numarası Giriniz';
      } else if (widget.validatePassword &&
          !isValidPassword(widget.controller.text)) {
        valid = false;
        _errorMessage = 'Lütfen Geçerli Bir Şifre Giriniz';
      } else if (widget.controller.text.length < minChars) {
        valid = false;
        _errorMessage = 'En Az 4 Karakter Giriniz';
      }

      if (mounted) {
        setState(() {
          _errorMessage = valid ? null : _errorMessage;
        });
      }
      widget.isValid.value = valid;
    });
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^.{4,}$');
    return passwordRegex.hasMatch(password);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_debounceValidation);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextFormField(
        maxLength: widget.maxCharacters,
        buildCounter: (BuildContext context,
                {required int currentLength,
                required bool isFocused,
                required int? maxLength}) =>
            null,
        cursorColor: Colors.deepOrange,
        textCapitalization: widget.capital ?? TextCapitalization.none,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        controller: widget.controller,
        obscureText: _isObsecure,
        keyboardType: widget.keyboardType,
        focusNode: _focusNode,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          prefixIconColor:
              _focusNode.hasFocus ? Colors.deepOrange : Colors.grey,
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          suffixIcon: _errorMessage != null && widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.error, color: Colors.red),
                  onPressed: () =>
                      coreAlertDialog(context, Text(_errorMessage!)))
              : (widget.isObsecure
                  ? InkWell(
                      onTap: () {
                        setState(() => _isObsecure = !_isObsecure);
                      },
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: _focusNode.hasFocus
                            ? Colors.deepOrange
                            : Colors.grey,
                      ),
                    )
                  : null),
          hintText: widget.hintText,
          filled: true,
          fillColor: Colors.grey[200],
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
