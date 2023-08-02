import 'package:flutter/material.dart';

class Dialogs {
  static void newSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$msg")));
  }

  static void newProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (n) => Center(child: CircularProgressIndicator()));
  }
}
