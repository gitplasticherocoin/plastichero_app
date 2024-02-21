import 'package:flutter/material.dart';

class WelcomeTobPTHProvider extends ChangeNotifier {
  bool _bPthFirstCreated = false;

  get getBPTHFirstCreated => _bPthFirstCreated;

  void firstCreatedBPTH(bool firstCreatedBPTH) {
    _bPthFirstCreated = firstCreatedBPTH;
    if (_bPthFirstCreated) {
      notifyListeners();
    }
  }
}
