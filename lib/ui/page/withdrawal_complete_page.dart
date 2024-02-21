import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/util/common_function.dart';

import '../../constants/color_theme.dart';
import '../../constants/setting.dart';
import '../widget/toolbar_widget.dart';

class WithdrawalCompletePage extends StatefulWidget {
  const WithdrawalCompletePage({Key? key}) : super(key: key);

  @override
  State<WithdrawalCompletePage> createState() => _WithdrawalCompletePageState();
}

class _WithdrawalCompletePageState extends State<WithdrawalCompletePage> {
  Map<String, dynamic>? args;

  String from = '';
  String to = '';
  String amount = '';
  String symbol = '';
  String memo = '';
  String gasPrice = '';
  String gasLimit = '';

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      from = args?['from'] ?? '';
      to = args?['to'] ?? '';
      amount = args?['amount'] ?? '';
      symbol = args?['symbol'] ?? '';
      memo = args?['memo'] ?? '';
      gasPrice = args?['gas_price'] ?? '';
      gasLimit = args?['gas_limit'] ?? '';
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: DefaultToolbar(
              isBackButton: false,
              centerTitle: false,
              leading: const SizedBox(width: 24.0),
              leadingWidth: 24.0,
              titleText: 'withdraw_complete'.tr(),
            ),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 24.0),
              child: BtnFill(
                onTap: () {
                  Navigator.pop(context);
                },
                text: 'confirm'.tr(),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 19.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //TODO: From
                  wTitleView(title: 'From'),
                  wContentsView(
                    margin: const EdgeInsets.only(top: 6.0, bottom: 10.0),
                    contents: from,
                  ),

                  //TODO: To
                  wTitleView(title: 'To'),
                  wContentsView(
                    margin: const EdgeInsets.only(top: 6.0, bottom: 10.0),
                    contents: to,
                  ),

                  //TODO: Amount
                  wTitleView(title: 'amount'.tr()),
                  wContentsView(
                    margin: const EdgeInsets.only(top: 6.0, bottom: 10.0),
                    contents: '${CommonFunction.getDecimalFormatFormString(amount)} $symbol',
                  ),

                  //TODO: Memo
                  if (symbol.toUpperCase() == WalletType.pth.symbol) ...[
                    wTitleView(title: 'memo'.tr()),
                    wContentsView(
                      margin: const EdgeInsets.only(top: 6.0),
                      contents: memo,
                    ),
                  ],

                  //TODO: Memo
                  if (symbol.toUpperCase() != WalletType.pth.symbol) ...[
                    wTitleView(title: 'gas_fee'.tr()),
                    wContentsView(
                      margin: const EdgeInsets.only(top: 6.0, bottom: 10.0),
                      contents: CommonFunction.getDecimalFormatFormString(gasPrice),
                    ),
                    wTitleView(title: 'max_amount_of_gas'.tr()),
                    wContentsView(
                      margin: const EdgeInsets.only(top: 6.0),
                      contents: CommonFunction.getDecimalFormatFormString(gasLimit),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget wTitleView({required String title}) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        height: 1.2,
        fontFamily: Setting.appFont,
        fontWeight: FontWeight.w500,
        color: Color(ColorTheme.defaultText),
      ),
    );
  }

  Widget wContentsView({required String contents, EdgeInsetsGeometry? margin}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(ColorTheme.c_ededed),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        contents,
        style: const TextStyle(
          fontSize: 15,
          height: 1.2,
          fontFamily: Setting.appFont,
          fontWeight: FontWeight.w500,
          color: Color(ColorTheme.defaultText),
        ),
      ),
    );
  }
}
