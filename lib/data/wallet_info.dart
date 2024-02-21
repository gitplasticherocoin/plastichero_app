
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/data/bsc_transaction_info.dart';
import 'package:plastichero_app/data/transaction_info.dart';

class WalletInfo {
  int idx;
  String name;
  String email;
  String address;
  bool isMain;
  String balance = '';
  String symbol = '';
  bool openSpinner = false;
  List<TransactionInfo>? transactionInfoList;
  List<BSCTransactionInfo>? bscTransactionInfoList;

  WalletInfo({
    this.idx = -1,
    this.name = '',
    this.email = '',
    this.address = '',
    this.isMain = false,
    this.balance = '0',
    this.symbol = '',
    this.openSpinner = false,
    this.transactionInfoList,
    this.bscTransactionInfoList,
  });

  WalletInfo.fromJson(Map<String, dynamic> json)
      : idx = json[ApiParamKey.walletIdx] ?? -1,
        name = json[ApiParamKey.name] ?? '',
        email = json[ApiParamKey.email] ?? '',
        address = json[ApiParamKey.address] ?? '',
        isMain = json[ApiParamKey.isMain] != null && json[ApiParamKey.isMain] == 'O' ? true : false {
    final value = json[ApiParamKey.balance];
    if (value != null && value is String) {
      List<String> values = value.trim().split(' ');
      if (values.isNotEmpty) {
        balance = values.elementAt(0);
        if (values.length > 1) {
          symbol = values.elementAt(1);
        }
      }
    }
  }
}
