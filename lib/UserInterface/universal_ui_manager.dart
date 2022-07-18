import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scorekeeper/UserInterface/app_colors.dart';

class UniversalUIManager {
  Widget activityIndicator() {
    if (Platform.isAndroid) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray80),
      );
    }
    return const CupertinoActivityIndicator();
  }

  void showAlert(
    BuildContext buildContext, {
    String? title,
    Widget? content,
    required List<Widget> actions,
  }) {
    if (Platform.isAndroid) {
      _showAndroidAlert(buildContext, title: title, content: content, actions: actions);
    } else {
      _showIosAlert(buildContext, title: title, content: content, actions: actions);
    }
  }

  void _showIosAlert(
    BuildContext buildContext, {
    String? title,
    Widget? content,
    required List<Widget> actions,
  }) {
    showCupertinoDialog(
      context: buildContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return CupertinoAlertDialog(
          title: Text(title ?? ''),
          content: content,
          actions: actions,
        );
      },
    );
  }

  void _showAndroidAlert(
    BuildContext buildContext, {
    String? title,
    Widget? content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title ?? ''),
          content: content,
          actions: actions,
        );
      },
    );
  }
}
