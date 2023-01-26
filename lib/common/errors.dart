import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: avoid_classes_with_only_static_members
class Errors {
  // ignore: non_constant_identifier_names
  static final String PASSWORD_NOT_MATCH = 'password.notcheck';
  // ignore: non_constant_identifier_names
  static final String GENERIC_ERROR = 'general.exception';

  static Map<String, String> errors = {
    PASSWORD_NOT_MATCH: 'Senha não confere',
    GENERIC_ERROR: 'Falha ao executar operação'
  };

  static String getError(String? errorCode) {
    var message = errors[errorCode!];
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Falha ao executar operação';
  }

  static void showError(String error) {
    Fluttertoast.showToast(
        msg: error,
        webBgColor: '#ff0000',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showSuccess(String error) {
    Fluttertoast.showToast(
        msg: error,
        webBgColor: '#00ff00',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static String? fromError(DioError error) {
    try {
      var data = json.decode(error.response!.data);
      return data['internalCode'];
    } on Exception catch (_) {
      return errors[GENERIC_ERROR];
    }
  }
}
