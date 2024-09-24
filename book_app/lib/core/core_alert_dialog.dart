import 'package:flutter/material.dart';

Future<dynamic> coreAlertDialog(BuildContext context, Widget content,
    {Widget? title, List<Widget>? actions}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: content,
          contentPadding:
              const EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 20),
          actionsPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          title: title,
          actions: actions ??
              [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
              ],
        );
      });
}
