import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero/ui/widget/button_widget.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/bsc_transaction_info.dart';
import 'package:plastichero_app/data/transaction_info.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailPageArguments {
  final TransactionInfo? transactionInfo;
  final BSCTransactionInfo? bscTransactionInfo;

  TransactionDetailPageArguments({
    this.transactionInfo,
    this.bscTransactionInfo,
  });
}

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TransactionDetailPageState();
  }
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final String tag = 'TransactionDetailPage';

  TransactionInfo? transactionInfo;
  BSCTransactionInfo? bscTransactionInfo;

  TransactionDetailPageArguments? args;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context) != null) {
      if (ModalRoute.of(context)!.settings.arguments is TransactionDetailPageArguments) {
        args = ModalRoute.of(context)!.settings.arguments as TransactionDetailPageArguments;
        if (args != null) {
          transactionInfo = args!.transactionInfo;
        }
      }

      if (ModalRoute.of(context)!.settings.arguments is TransactionDetailPageArguments) {
        args = ModalRoute.of(context)!.settings.arguments as TransactionDetailPageArguments;
        if (args != null) {
          bscTransactionInfo = args!.bscTransactionInfo;
        }
      }
    }
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: DefaultToolbar(
          titleText: 'transaction_details'.tr(),
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 24, top: 6, right: 24, bottom: 20),
                    padding: const EdgeInsets.only(left: 18, top: 4, right: 18, bottom: 18),
                    decoration: BoxDecoration(
                      color: const Color(ColorTheme.c_f3f3f3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (bscTransactionInfo != null) ...{
                          item(title: 'from_en'.tr(), contents: bscTransactionInfo!.fromAddress, isCopy: true, isTitleShape: true),
                          item(title: 'to_en'.tr(), contents: bscTransactionInfo!.toAddress, isCopy: true, isTitleShape: true),
                          item(
                            title: 'amount'.tr(),
                            contents:
                                '${CommonFunction.getDecimalFormatFormString(bscTransactionInfo != null ? bscTransactionInfo!.amount : '')} ${bscTransactionInfo != null ? bscTransactionInfo!.symbol : ''}',
                          ),
                          item(title: 'gas_limit'.tr(), contents: bscTransactionInfo!.gasLimit.toString(), isCopy: false, isTitleShape: false),
                          item(title: 'gas_use'.tr(), contents: bscTransactionInfo!.gasUsed.toString(), isCopy: false, isTitleShape: false),
                          item(title: 'gas_fee'.tr(), contents: convertWeiToEth(bscTransactionInfo!.gasPrice), isCopy: false, isTitleShape: false),
                          item(title: 'txn_hash_en'.tr(), contents: bscTransactionInfo!.txId, isCopy: true, isBottomLine: false),
                        } else ...{
                          if (transactionInfo != null) ...{
                            item(title: 'from_en'.tr(), contents: transactionInfo!.from, isCopy: true, isTitleShape: true),
                            item(title: 'to_en'.tr(), contents: transactionInfo!.to, isCopy: true, isTitleShape: true),
                            item(
                              title: 'amount'.tr(),
                              contents: '${CommonFunction.getDecimalFormatFormString(transactionInfo != null ? transactionInfo!.amount : '')} ${transactionInfo != null ? transactionInfo!.symbol : ''}',
                            ),
                            if (transactionInfo!.memo != null && transactionInfo!.memo.isNotEmpty) ...{
                              item(title: 'txn_hash_en'.tr(), contents: transactionInfo!.trxId, isCopy: true),
                              item(title: 'memo'.tr(), contents: transactionInfo!.memo, isCopy: false, isBottomLine: false),
                            } else ...{
                              item(title: 'txn_hash_en'.tr(), contents: transactionInfo!.trxId, isCopy: true, isBottomLine: false),
                            }
                          }
                        }




                      ],
                    ),
                  ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ButtonStyle4(
                  radius: 10,
                  btnColor:Colors.white,
                  borderColor: const Color(ColorTheme.appColor),
                  textColor: const Color(ColorTheme.appColor),
                  text: 'explorer_link'.tr(),
                  onTap: () async{
                    CommonFunction.hideKeyboard(context);
                    await launchUrl(Uri.parse("${Setting.EXPLORER_LINK}/transaction/detail/${transactionInfo!.trxId}"), mode: LaunchMode.externalApplication);

                  }),
              ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget item({
    String? title,
    String? contents,
    bool isCopy = false,
    bool isTitleShape = false,
    bool isBottomLine = true,
  }) {
    if ((title != null && title.isNotEmpty) || (contents != null)) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 14),
        decoration: isBottomLine
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Color(ColorTheme.c_dbdbdb),
                  ),
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title.isNotEmpty) ...{
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: isTitleShape ? const EdgeInsets.only(left: 10, top: 1, right: 10, bottom: 1) : EdgeInsets.zero,
                constraints: isTitleShape ? const BoxConstraints(minHeight: 18) : null,
                decoration: isTitleShape
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: const Color(ColorTheme.c_dbdbdb),
                      )
                    : null,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.3,
                    fontSize: 13,
                    fontFamily: Setting.appFont,
                    fontWeight: FontWeight.w500,
                    color: Color(ColorTheme.c_666666),
                  ),
                ),
              ),
            },
            if (contents != null) ...{
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        contents,
                        // maxLines: isLineLimit ? 2: 0,
                        // overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          height: 1.2,
                          fontSize: 14,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w400,
                          color: Color(ColorTheme.defaultText),
                        ),
                      ),
                    ),
                  ),
                  if (isCopy) ...{
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        if (contents != null && contents.isNotEmpty) {
                          CommonFunction.copyData(context, contents);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, top: 2, bottom: 4),
                        child: SvgPicture.asset(
                          "images/icon_copy.svg",
                          width: 14,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  } else ...{
                    Container(),
                  }
                ],
              ),
            },
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  String convertWeiToEth(String gasPrice) {
    try {
      const int weiAmount = 1000000000000000000;

      BigInt bGasPrice = BigInt.from(int.parse(gasPrice));
      double ethValue = bGasPrice / BigInt.from(weiAmount);

      return CommonFunction.getDecimalFormatFormString(ethValue.toStringAsFixed(18));
    } catch (e) {
      debugPrint(e.toString());
    }
    return '';
  }
}
