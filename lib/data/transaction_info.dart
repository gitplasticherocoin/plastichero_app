

import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/constants/common.dart';

class TransactionInfo {
  int idx = 0;
  String trxId = '';
  int block = 0;
  int timestamp = 0;
  String op = '';
  String from = '';
  String to = '';
  String amount = '';
  String memo = '';
  String symbol = '';
  String operationName = '';
  TransactionType transactionType = TransactionType.deposit;

  TransactionInfo(
    String walletAddress, {
    required this.idx,
    required this.trxId,
    required this.block,
    required this.timestamp,
    required this.op,
    required this.from,
    required this.to,
    required this.amount,
    required this.memo,
    required this.symbol,
  }) {
    if (from == walletAddress) {
      transactionType = TransactionType.withdrawal;
    } else {
      transactionType = TransactionType.deposit;
    }
  }

  TransactionInfo.fromJson(Map<String, dynamic> json, String walletAddress)
      : idx = json[ApiParamKey.idx] ?? 0,
        trxId = json[ApiParamKey.trxId] ?? '',
        block = json[ApiParamKey.block] ?? 0,
        timestamp = json[ApiParamKey.timestamp] ?? 0,
        op = json[ApiParamKey.op] ?? '',
        from = json[ApiParamKey.from] ?? '',
        to = json[ApiParamKey.to] ?? '',
        amount = json[ApiParamKey.amount] ?? '',
        memo = json[ApiParamKey.memo] ?? '' {
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

    if (from == walletAddress) {
      transactionType = TransactionType.withdrawal;
    } else {
      transactionType = TransactionType.deposit;
    }
  }
}
