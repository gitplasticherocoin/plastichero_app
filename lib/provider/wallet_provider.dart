import 'package:flutter/material.dart';
import 'package:plastichero_app/data/bsc_wallet_info.dart';


import '../data/wallet_info.dart';

class WalletProvider extends ChangeNotifier {
  List<WalletInfo> _pthWalletInfoList = [];
  List<BSCWalletInfo> _bscWalletInfoList = [];

  get getPTHWalletInfoList => _pthWalletInfoList;

  get getBSCWalletInfoList => _bscWalletInfoList;

  void setWalletInfoList({List<WalletInfo>? pthWalletInfoList}) async {
    bool isNotify = false;
    if (pthWalletInfoList != null) {
      isNotify = true;
      _pthWalletInfoList = pthWalletInfoList;
    }
    if (isNotify) {
      notifyListeners();
    }
  }

  void setBSCWalletInfoList({List<BSCWalletInfo>? bscWalletInfoList}) async {
    bool isNotify = false;
    if (bscWalletInfoList != null) {
      isNotify = true;
      _bscWalletInfoList = bscWalletInfoList;
    }
    if (isNotify) {
      notifyListeners();
    }
  }

  void clearWalletInfoList() {
    _pthWalletInfoList.clear();
    _bscWalletInfoList.clear();
  }
}
