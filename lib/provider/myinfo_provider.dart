import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyinfoProvider with ChangeNotifier {
  void callRefresh() {
    notifyListeners();
  }
}