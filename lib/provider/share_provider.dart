import 'package:flutter/material.dart';

class ShareProvider extends ChangeNotifier {
  String _shareData = '';

  String getShareData() {
    String shareData = _shareData;
    _shareData = '';
    return shareData;
  }

  void setShareData(String data) {
    _shareData = data;
    notifyListeners();
  }
}
