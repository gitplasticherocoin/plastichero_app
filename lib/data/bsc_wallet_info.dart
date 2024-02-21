

import 'package:plastichero_app/api/api_param_key.dart';

class BSCWalletInfo {
  int idx = -1;
  String name = '';
  String address = '';
  bool isMain = false;
  String balance = '0';
  String bPthSymbol = '';
  String bnbBalance = '0';
  String bnbSymbol = '';
  bool openSpinner = false;

  BSCWalletInfo({
    this.idx = -1,
    this.name = '',
    this.address = '',
    this.isMain = false,
    this.balance = '0',
    this.bPthSymbol = '',
    this.bnbBalance = '0',
    this.bnbSymbol = '',
    this.openSpinner = false,
  });

  BSCWalletInfo.fromJson(Map<String, dynamic> json)
      : idx = json[ApiParamKey.walletIdx] ?? -1,
        name = json[ApiParamKey.name] ?? '',
        address = json[ApiParamKey.address] ?? '',
        isMain = json[ApiParamKey.isMain] != null && json[ApiParamKey.isMain] == 'O' ? true : false {
    final bPthBalanceData = json[ApiParamKey.balance];
    if (bPthBalanceData != null && bPthBalanceData is String) {
      List<String> values = bPthBalanceData.trim().split(' ');
      if (values.isNotEmpty) {
        balance = values.elementAt(0);
        if (values.length > 1) {
          bPthSymbol = values.elementAt(1);
        }
      }
    }
    final bnbBalanceData = json[ApiParamKey.bnbBalance];
    if (bnbBalanceData != null && bnbBalanceData is String) {
      List<String> values = bnbBalanceData.trim().split(' ');
      if (values.isNotEmpty) {
        bnbBalance = values.elementAt(0);
        if (values.length > 1) {
          bnbSymbol = values.elementAt(1);
        }
      }
    }
  }

  BSCWalletInfo.copy(BSCWalletInfo bscWalletInfo) {
    idx = bscWalletInfo.idx;
    name = bscWalletInfo.name;
    address = bscWalletInfo.address;
    isMain = bscWalletInfo.isMain;
    balance = bscWalletInfo.balance;
    bPthSymbol = bscWalletInfo.bPthSymbol;
    bnbBalance = bscWalletInfo.bnbBalance;
    bnbSymbol = bscWalletInfo.bnbSymbol;
    openSpinner = bscWalletInfo.openSpinner;
  }
}
