import 'package:flutter/material.dart';

class PushNotificationProvider extends ChangeNotifier {
  String pushData = '';
  bool isSelectNoty = false;

  get getPushData => pushData;

  get getIsSelectNoty => isSelectNoty;

  void setNotificationData(String data, {isSelectNoty = false}) {
    pushData = data;
    this.isSelectNoty = isSelectNoty;
    if (data.isNotEmpty) {
      notifyListeners();
    }
  }
}
