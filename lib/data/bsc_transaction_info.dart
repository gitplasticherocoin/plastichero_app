
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/constants/common.dart';

class BSCTransactionInfo {
  int idx = 0;
  String fromAddress = '';
  String toAddress = '';
  String amount = '';
  String txId = '';
  int timestamp = 0;
  int updateTimestamp = 0;
  String gasPrice = '';
  int gasLimit = 0;
  int gasUsed = 0;
  int nonce = 0;
  String symbol = '';
  TransactionType transactionType = TransactionType.deposit;

  BSCTransactionInfo(
    String walletAddress, {
    required this.idx,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.txId,
    required this.timestamp,
    this.updateTimestamp = 0,
    this.gasPrice = '',
    this.gasLimit = 0,
    this.gasUsed = 0,
    this.nonce = 0,
    required this.symbol,
  }) {
    if (fromAddress == walletAddress) {
      transactionType = TransactionType.withdrawal;
    } else {
      transactionType = TransactionType.deposit;
    }
  }

  BSCTransactionInfo.fromJson(Map<String, dynamic> json, String walletAddress)
      : idx = json[ApiParamKey.idx] ?? 0,
        fromAddress = json[ApiParamKey.fromAddress] ?? '',
        toAddress = json[ApiParamKey.toAddress] ?? '',
        amount = json[ApiParamKey.amount] ?? '',
        txId = json[ApiParamKey.txId] ?? '',
        timestamp = json[ApiParamKey.timestamp] ?? 0,
        updateTimestamp = json[ApiParamKey.updateTimestamp] ?? 0,
        gasPrice = json[ApiParamKey.gasPrice] ?? '',
        gasLimit = json[ApiParamKey.gasLimit] ?? 0,
        gasUsed = json[ApiParamKey.gasUsed] ?? 0,
        nonce = json[ApiParamKey.nonce] ?? 0 {
    final amountData = json[ApiParamKey.amount];
    if (amountData != null && amountData is String) {
      List<String> values = amountData.trim().split(' ');
      if (values.isNotEmpty) {
        amount = values.elementAt(0);
        if (values.length > 1) {
          symbol = values.elementAt(1);
        }
      }
    }

    if (fromAddress == walletAddress) {
      transactionType = TransactionType.withdrawal;
    } else {
      transactionType = TransactionType.deposit;
    }
  }
}
