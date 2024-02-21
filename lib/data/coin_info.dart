import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/constants/common.dart';

class CoinInfo {
  String account;
  int mining;
  String token;
  String balance;
  String savingsBalance;
  int lastUpdated;
  String amount;
  String symbol;
  String amountPrefix;
  String imageUrl;
  String appImageUrl;
  CoinType type;

  CoinInfo({
    this.account = '',
    this.mining = 0,
    this.token = '',
    this.balance = '',
    this.savingsBalance = '',
    this.lastUpdated = 0,
    this.amount = '',
    this.symbol = '',
    this.amountPrefix = '',
    this.imageUrl = '',
    this.appImageUrl = '',
    this.type = CoinType.point,
  });

  CoinInfo.fromJson(Map<String, dynamic> json)
      : account = json[ApiParamKey.account] ?? '',
        mining = json[ApiParamKey.mining] ?? 0,
        token = json[ApiParamKey.token] ?? '',
        balance = json[ApiParamKey.balance] ?? '',
        savingsBalance = json[ApiParamKey.savingsBalance] ?? '',
        lastUpdated = json[ApiParamKey.lastUpdated] ?? 0,
        amount = json[ApiParamKey.amount] ?? '',
        symbol = json[ApiParamKey.symbol] ?? '',
        amountPrefix = json[ApiParamKey.amountPrefix] ?? '',
        imageUrl = json[ApiParamKey.imageUrl] ?? '',
        appImageUrl = json[ApiParamKey.appImageUrl] ?? '',
        type = json[ApiParamKey.type] != null && json[ApiParamKey.type] == CoinType.coin.name
            ? CoinType.coin
            : json[ApiParamKey.type] != null && json[ApiParamKey.type] == CoinType.token.name
                ? CoinType.token
                : CoinType.point;
}
