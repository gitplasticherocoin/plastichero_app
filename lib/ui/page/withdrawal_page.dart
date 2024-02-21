import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:provider/provider.dart';

import '../../api/api_param_key.dart';
import '../../api/member/check_response.dart';
import '../../api/wallet/wallet_bnb.dart';
import '../../api/wallet/wallet_bpth.dart';
import '../../api/wallet/wallet_pth.dart';
import '../../constants/color_theme.dart';
import '../../constants/common.dart';
import '../../constants/preference_key.dart';
import '../../constants/setting.dart';
import '../../data/bsc_wallet_info.dart';
import '../../data/wallet_info.dart';
import '../../provider/wallet_provider.dart';
import '../../routes.dart';
import '../../util/common_function.dart';
import '../../util/debug.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/select_wallet_dailog.dart';
import '../dialog/set_gas_dialog.dart';
import '../widget/button_widget.dart';
import '../widget/text_widget.dart';
import '../widget/toolbar_widget.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({
    Key? key,
  }) : super(key: key);

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final gkAmount = GlobalKey<AmountTextFiledState>();

  late final LoadingDialog loadingDialog;
  late final ValueNotifier<bool> btnNotifier;

  late final TextEditingController toAddressController;
  late final TextEditingController amountController;
  late final TextEditingController memoController;
  late final TextEditingController gasPriceController;
  late final TextEditingController gasAmountController;
  late final TextEditingController otpController;

  late final FocusNode amountFocus;
  late final FocusNode otpFocus;
  late final FocusNode memoFocus;

  final String weiAmount = '1000000000000000000';

  List<WalletInfo> walletInfoList = [];
  List<BSCWalletInfo> bscWalletInfoList = [];

  Map<String, dynamic>? args;

  WalletType walletType = WalletType.pth;
  WalletInfo? walletInfo;

  bool isPTH = false;
  bool isLoadList = false;
  bool isAgree = false;

  String from = '';
  String balance = '';
  String symbol = '';
  String bnbBalance = '';

  @override
  void initState() {
    super.initState();

    loadingDialog = LoadingDialog(context: context);
    btnNotifier = ValueNotifier<bool>(false);

    toAddressController = TextEditingController();
    amountController = TextEditingController();
    memoController = TextEditingController();
    gasPriceController = TextEditingController();
    gasAmountController = TextEditingController();
    otpController = TextEditingController();

    amountFocus = FocusNode();
    otpFocus = FocusNode();
    memoFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      walletInfoList = Provider.of<WalletProvider>(context, listen: false).getPTHWalletInfoList;
      bscWalletInfoList = Provider.of<WalletProvider>(context, listen: false).getBSCWalletInfoList;

      // if (walletInfo == null || (!isPTH && bnbBalance.isEmpty)) {
      getWalletList();
      // }
    });
  }

  @override
  void dispose() {
    btnNotifier.dispose();

    toAddressController.dispose();
    amountController.dispose();
    memoController.dispose();
    gasPriceController.dispose();
    gasAmountController.dispose();
    otpController.dispose();

    amountFocus.dispose();
    otpFocus.dispose();
    memoFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

      symbol = args?['symbol'] ?? WalletType.pth.symbol;
      if (symbol == WalletType.pth.symbol) {
        isPTH = true;
        walletType = WalletType.pth;
      } else {
        isPTH = false;
        walletType = WalletType.bsc;
      }

      from = args?['address'] ?? '';
      bnbBalance = args?['bnb_balance'] ?? '';

      if (args?['wallet_info'] != null && args?['wallet_info'] is BSCWalletInfo) {
        BSCWalletInfo bscWalletInfo = args?['wallet_info'] as BSCWalletInfo;
        walletInfo = convertToWalletInfo(bscWalletInfo);
        bnbBalance = bscWalletInfo.bnbBalance;
      } else {
        walletInfo = args?['wallet_info'];
      }

      setData(false);
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: unFocus,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: DefaultToolbar(
              isBackButton: true,
              onBackPressed: () {
                Navigator.of(context).pop();
              },
              centerTitle: false,
              titleText: "withdraw".tr(),
            ),
            body: SizedBox.expand(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 19.0),
                      child: Column(
                        children: <Widget>[
                          // TODO: From
                          wTitleView(title: 'From', isAsterisk: true),
                          GestureDetector(
                            onTap: () {
                              CommonFunction.hideKeyboard(context);
                              showSelectWalletDialog();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 16, top: 16, right: 15, bottom: 16),
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(ColorTheme.c_ededed),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      from,
                                      style: const TextStyle(
                                        height: 1.2,
                                        fontSize: 15.0,
                                        color: Color(ColorTheme.defaultText),
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  SvgPicture.asset(
                                    'images/icon_textfield_down.svg',
                                    width: 14.0,
                                    height: 14.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${'amount_owned'.tr()} : ',
                                style: const TextStyle(
                                  height: 1.2,
                                  fontSize: 15.0,
                                  color: Color(ColorTheme.c_4b4b4b),
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '${CommonFunction.getDecimalFormatFormString(balance)} $symbol',
                                  style: const TextStyle(
                                    height: 1.2,
                                    fontSize: 15.0,
                                    color: Color(ColorTheme.c_4b4b4b),
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // TODO: To
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 6),
                            child: wTitleView(title: 'To', isAsterisk: true),
                          ),
                          Stack(
                            children: [
                              InputTextField(
                                controller: toAddressController,
                                hintText: 'address_placeholder'.tr(),
                                contentPadding: const EdgeInsets.only(left: 16, top: 16, right: 46, bottom: 16),
                                textInputAction: TextInputAction.next,
                                denySpace: true,
                                onChanged: (_) {
                                  setEnableBtn();
                                },
                                onFieldSubmitted: (value) {
                                  amountFocus.requestFocus();
                                },
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0.0,
                                child: GestureDetector(
                                  onTap: () async {
                                    CommonFunction.hideKeyboard(context);
                                    var result = await Navigator.pushNamed(context, Routes.qrScanPage);
                                    if (result != null && result is String) {
                                      List<String> split = result.split(Common.qrcodeSplit);
                                      toAddressController.text = split[0];
                                      if (gkAmount.currentState != null && split.length > 1) {
                                        amountController.text = CommonFunction.getDecimalFormatFormString(
                                          split[1],
                                          decimalDigits: isPTH ? Setting.decimalDigits : Setting.bPthDecimalDigits,
                                        );
                                      }
                                      setEnableBtn();
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 12, 16, 12),
                                    child: SvgPicture.asset('images/icon_qrscan.svg', width: 20, height: 20,
                                        ),
                                  ),
                                ),
                              )
                            ],
                          ),

                          // TODO: Amount
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 6),
                            child: wTitleView(title: 'amount'.tr(), isAsterisk: true),
                          ),
                          AmountTextFiled(
                            key: gkAmount,
                            focusNode: amountFocus,
                            controller: amountController,
                            hintText: 'amount_placeholder'.tr(),
                            textInputAction: TextInputAction.next,
                            maxDecimal: symbol.toUpperCase() == WalletType.pth.symbol ? Setting.decimalDigits : Setting.bPthDecimalDigits,
                            onChanged: (_) {
                              setEnableBtn();
                            },
                            onFieldSubmitted: (value) {
                              otpFocus.requestFocus();
                            },
                          ),

                          // TODO: OTP
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 6),
                            child: wTitleView(title: 'otp_auth_code'.tr(), isAsterisk: true),
                          ),
                          InputTextField(
                            focusNode: otpFocus,
                            controller: otpController,
                            hintText: 'enter_auth_code_placeholder'.tr(),
                            keyboardType: TextInputType.number,
                            textInputAction: isPTH ? TextInputAction.next : TextInputAction.done,
                            denySpace: true,
                            maxLength: 6,
                            onChanged: (value) {
                              setEnableBtn();
                            },
                            onFieldSubmitted: (value) {
                              if (isPTH) {
                                memoFocus.requestFocus();
                              }
                            },
                          ),

                          // TODO: Memo
                          if (isPTH) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 6),
                              child: wTitleView(title: 'memo'.tr(), isAsterisk: false),
                            ),
                            InputTextField(
                              focusNode: memoFocus,
                              controller: memoController,
                              hintText: 'memo_placeholder'.tr(),
                            ),
                          ],

                          Container(
                            width: double.infinity,
                            height: 1.0,
                            color: const Color(ColorTheme.c_ededed),
                            margin: const EdgeInsets.only(top: 14, bottom: 14),
                          ),

                          // TODO: Precaution
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(ColorTheme.c_f3f3f3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'images/icon_notice.svg',
                                      width: 14,
                                      height: 14,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'precautions'.tr(),
                                      style: const TextStyle(
                                        height: 1.2,
                                        fontSize: 14,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.defaultText),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                wGuideView(text: 'withdrawal_precautions1'.tr()),
                                const SizedBox(height: 5),
                                wGuideView(text: 'withdrawal_precautions2'.tr()),
                                const SizedBox(height: 5),
                                wGuideView(text: 'withdrawal_precautions3'.tr()),
                              ],
                            ),
                          ),

                          // TODO: Withdrawal Agree
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isAgree = !isAgree;
                                  });
                                  setEnableBtn();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAgree ? const Color(ColorTheme.appColor) : const Color(ColorTheme.c_dbdbdb),
                                  ),
                                  child: SvgPicture.asset(
                                    "images/icon_check_w_m.svg",
                                    width: 12,
                                    height: 9,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0, right: 14.0),
                                  child: Text(
                                    'withdrawal_agree'.tr(),
                                    style: const TextStyle(
                                      height: 1.2,
                                      fontSize: 14.0,
                                      color: Color(ColorTheme.defaultText),
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // TODO: Button
                  ValueListenableBuilder<bool>(
                    valueListenable: btnNotifier,
                    builder: (_, isEnable, __) {
                      return BtnFill(
                        margin: const EdgeInsets.fromLTRB(24, 5, 24, 24),
                        onTap: () {
                          CommonFunction.hideKeyboard(context);

                          transfer();
                        },
                        isEnable: isEnable,
                        text: "confirm".tr(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //  TODO: wTitleView()
  Widget wTitleView({required String title, required bool isAsterisk}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            height: 1.2,
            fontFamily: Setting.appFont,
            fontWeight: FontWeight.w500,
            color: Color(ColorTheme.defaultText),
          ),
        ),
        if (isAsterisk)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 15,
              height: 1.2,
              fontFamily: Setting.appFont,
              fontWeight: FontWeight.w500,
              color: Color(ColorTheme.errorText),
            ),
          ),
      ],
    );
  }

  Widget wGuideView({required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 3.0,
          height: 3.0,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(ColorTheme.defaultText),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: const TextStyle(
              height: 1.2,
              fontSize: 13.0,
              color: Color(ColorTheme.defaultText),
              fontFamily: Setting.appFont,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  WalletInfo convertToWalletInfo(BSCWalletInfo info) {
    return WalletInfo(
      idx: info.idx,
      name: info.name,
      address: info.address,
      balance: info.balance,
      symbol: info.bPthSymbol,
    );
  }

  void setData(bool isSetState) {
    if (walletInfo != null) {
      from = walletInfo!.address;
      balance = symbol.toUpperCase() == BSCWalletType.bnb.symbol ? bnbBalance : walletInfo!.balance;
      if (isSetState) {
        setState(() {});
      }
    }
  }

  // TODO: unFocus()
  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  // TODO: setEnableBtn()
  void setEnableBtn() {
    bool isToAddress = toAddressController.text.trim().isNotEmpty;
    // Decimal dTotal = CommonFunction.getDecimalFromStr(totalBalance) ?? Decimal.zero;
    Decimal dAmount = CommonFunction.getDecimalFromStr(amountController.text.trim()) ?? Decimal.zero;
    // bool isAmount = (dTotal > Decimal.zero) && dTotal >= dAmount;
    // print('## isToAddress = $isToAddress, isAmount = $isAmount');
    // print('## dTotal = ${dTotal.toString()}, dAmount = ${dAmount.toString()}');
    btnNotifier.value = walletInfo != null && isToAddress && dAmount > Decimal.zero && isAgree && otpController.text.trim().length == 6;
  }

  String? getFailMessage(dynamic json) {
    String? msg;
    try {
      msg = json[ApiParamKey.msg];
      if (msg == null) {
        dynamic result = json[ApiParamKey.result];
        msg = result[ApiParamKey.message];
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return msg;
  }

  // TODO: checkValidate()
  void transfer() async {
    if (walletInfo == null) {
      CommonFunction.showToast(context, 'msg_error_wallet_info'.tr());
      return;
    }

    int walletIdx = walletInfo!.idx;
    String to = toAddressController.text.trim();
    String amount = amountController.text.trim().replaceAll(',', '');
    String token = otpController.text.trim();
    String memo = memoController.text.trim();
    if (from == to) {
      CommonFunction.showInfoDialog(context, 'msg_error_same_address'.tr());
      return;
    }
    Decimal bBalance = CommonFunction.getDecimalFromStr(symbol.toUpperCase() == BSCWalletType.bnb.symbol ? bnbBalance : walletInfo!.balance) ?? Decimal.zero;
    Decimal dAmount = CommonFunction.getDecimalFromStr(amount) ?? Decimal.zero;

    if (dAmount <= Decimal.zero) {
      CommonFunction.showInfoDialog(context, 'amount_placeholder'.tr());
      return;
    }

    if (bBalance < dAmount) {
      CommonFunction.showInfoDialog(context, 'msg_error_excess_amount'.tr());
      return;
    }

    if (isPTH) {
      transferPTH(
        walletIdx: walletIdx,
        from: from,
        to: to,
        amount: amount,
        symbol: symbol,
        token: token,
        memo: memo,
      );
    } else {
      getGasHandler(walletIdx: walletIdx, from: from, to: to, amount: amount, symbol: symbol, token: token);
    }
  }

  // TODO: showSelectWalletDialog
  void showSelectWalletDialog() {
    CommonFunction.hideKeyboard(context);

    showModalBottomSheet<void>(
      context: context,
      barrierColor: const Color(ColorTheme.dim),
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SelectWalletDialog(
          symbol: symbol,
          address: from,
          onSelect: (int index) {
            if (index < 0) {
              return;
            }
            if (isPTH && index < walletInfoList.length) {
              walletInfo = walletInfoList[index];
            } else if (index < bscWalletInfoList.length) {
              walletInfo = convertToWalletInfo(bscWalletInfoList[index]);
              bnbBalance = bscWalletInfoList[index].bnbBalance;
            }

            if (walletInfo != null) {
              setData(true);
            }
          },
        );
      },
    );
  }

  void getWalletList() async {
    if (isLoadList) {
      return;
    }
    isLoadList = true;

    if (isPTH) {
      await getPTHListHandler();
    } else {
      await getBPTHListHandler();
    }

    isLoadList = false;
  }

  Future<void> getPTHListHandler() async {
    var manager = ApiManagerPTHWallet();
    dynamic json;

    try {
      json = await manager.list();
      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result] ?? [];
        walletInfoList = (result as List).map((json) => WalletInfo.fromJson(json)).toList();

        if (mounted) {
          for (WalletInfo info in walletInfoList) {
            if (from == info.address) {
              walletInfo = info;
              break;
            }
          }
          setData(true);
          Provider.of<WalletProvider>(context, listen: false).setWalletInfoList(pthWalletInfoList: walletInfoList);
        }
      } else {
        if (mounted) {
          // CommonFunction.showInfoDialog(context, json[ApiParamKey.msg]);
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getBPTHListHandler() async {
    var manager = ApiManagerBPTHWallet();
    dynamic json;

    try {
      json = await manager.list();
      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result] ?? [];
        bscWalletInfoList = (result as List).map((json) => BSCWalletInfo.fromJson(json)).toList();

        if (mounted) {
          for (BSCWalletInfo info in bscWalletInfoList) {
            if (from == info.address) {
              walletInfo = convertToWalletInfo(info);
              bnbBalance = info.bnbBalance;
              break;
            }
          }
          setData(true);
          Provider.of<WalletProvider>(context, listen: false).setBSCWalletInfoList(bscWalletInfoList: bscWalletInfoList);
        }
      } else {
        if (mounted) {
          // CommonFunction.showInfoDialog(context, json[ApiParamKey.msg]);
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getGasHandler({
    required int walletIdx,
    required String from,
    required String to,
    required String amount,
    required String symbol,
    required String token,
  }) async {
    dynamic json;

    // String gasPrice = '';
    String gasBnb = '';
    String gasLimit = '';

    try {
      loadingDialog.show();

      if (symbol.toUpperCase() == BSCWalletType.bnb.symbol) {
        var manager = ApiManagerBNBWallet();
        json = await manager.getGas(walletIdx: walletIdx, to: to, amount: amount);
      } else {
        var manager = ApiManagerBPTHWallet();
        json = await manager.getGas(walletIdx: walletIdx, to: to, amount: amount);
      }
      loadingDialog.hide();

      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result] ?? [];

        // gasPrice = result[ApiParamKey.gasPrice] ?? '';
        gasBnb = result[ApiParamKey.gasBnb] ?? '';
        gasLimit = result[ApiParamKey.gasLimit] == null ? '' : result[ApiParamKey.gasLimit].toString();

        gasPriceController.text = gasBnb;
        gasAmountController.text = gasLimit;

        if (mounted) {
          CommonFunction.showBottomSheet(
            context: context,
            isDismissible: true,
            child: SetGasDialog(
              gasPriceController: gasPriceController,
              gasAmountController: gasAmountController,
              onComplete: () {
                String gasPrice = gasPriceController.text.trim().replaceAll(',', '');
                String gasAmount = gasAmountController.text.trim().replaceAll(',', '');

                Decimal dGasPrice = CommonFunction.getDecimalFromStr(gasPrice) ?? Decimal.zero;
                Decimal dGasAmount = CommonFunction.getDecimalFromStr(gasAmount) ?? Decimal.zero;
                Decimal dWeiAmount = Decimal.parse(weiAmount);

                bool isBnb = symbol.toUpperCase() == BSCWalletType.bnb.symbol;

                if (bnbBalance.isNotEmpty) {
                  Decimal dTotalGasPrice = dGasPrice * dGasAmount;

                  if (isBnb) {
                    Decimal dAmount = CommonFunction.getDecimalFromStr(amount) ?? Decimal.zero;
                    Decimal bBalance = CommonFunction.getDecimalFromStr(isBnb ? bnbBalance : walletInfo!.balance) ?? Decimal.zero;

                    if (bBalance < (dAmount + dTotalGasPrice)) {
                      CommonFunction.showInfoDialog(context, 'msg_error_excess_amount_gas'.tr());
                      return;
                    }
                  } else {
                    Decimal dBnbBalance = CommonFunction.getDecimalFromStr(bnbBalance) ?? Decimal.zero;
                    if (dTotalGasPrice > dBnbBalance) {
                      CommonFunction.showInfoDialog(context, 'msg_error_excess_amount_bnb'.tr());
                      return;
                    }
                  }
                }

                gasPrice = (dGasPrice * dWeiAmount).toString().replaceAll(',', '');

                if (isBnb) {
                  transferBNB(
                    walletIdx: walletIdx,
                    from: from,
                    to: to,
                    amount: amount,
                    symbol: symbol,
                    gasPrice: gasPrice,
                    gasLimit: gasAmount,
                    token: token,
                  );
                } else {
                  transferBPTH(
                    walletIdx: walletIdx,
                    from: from,
                    to: to,
                    amount: amount,
                    symbol: symbol,
                    gasPrice: gasPrice,
                    gasLimit: gasAmount,
                    token: token,
                  );
                }
              },
            ),
          );
        }
      } else {
        if (mounted) {
          CommonFunction.showInfoDialog(context, getFailMessage(json));
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }
  }

  Future<void> transferPTH({
    required int walletIdx,
    required String from,
    required String to,
    required String amount,
    required String symbol,
    required String token,
    required String memo,
  }) async {
    var result = await Navigator.pushNamed(context, Routes.withdrawalPasswordPage, arguments: {'type': 2});

    if (result == null || result is! bool || !result) {
      return;
    }

    String pass = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? '';
    String passTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? '';

    var manager = ApiManagerPTHWallet();
    dynamic json;

    try {
      loadingDialog.show();
      json = await manager.transfer(
        walletIdx: walletIdx,
        pw: AESHelper().decrypt(pass, passTs),
        to: to,
        amount: amount,
        token: token,
        memo: memo,
      );
      loadingDialog.hide();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result];

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(
          context,
          Routes.withdrawalCompletePage,
          arguments: {
            "from": from,
            "to": to,
            "amount": amount,
            "symbol": symbol,
            "memo": memo,
          },
          result: true,
        );

        return;
      } else {
        if (mounted) {
          CommonFunction.showInfoDialog(context, getFailMessage(json));
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }
  }

  Future<void> transferBNB({
    required int walletIdx,
    required String from,
    required String to,
    required String amount,
    required String symbol,
    required String gasPrice,
    required String gasLimit,
    required String token,
  }) async {
    var result = await Navigator.pushNamed(context, Routes.withdrawalPasswordPage, arguments: {'type': 2});

    if (result == null || result is! bool || !result) {
      return;
    }

    String pass = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? '';
    String passTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? '';

    var manager = ApiManagerBNBWallet();
    dynamic json;

    try {
      loadingDialog.show();
      json = await manager.transfer(
        walletIdx: walletIdx,
        pw: AESHelper().decrypt(pass, passTs),
        to: to,
        amount: amount,
        gasPrice: gasPrice,
        gasLimit: gasLimit,
        token: token,
      );
      loadingDialog.hide();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result];

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(
          context,
          Routes.withdrawalCompletePage,
          arguments: {
            "from": from,
            "to": to,
            "amount": amount,
            "symbol": symbol,
            "memo": '',
            "gas_price": gasPriceController.text.trim(),
            "gas_limit": gasLimit,
          },
          result: true,
        );

        return;
      } else {
        if (mounted) {
          CommonFunction.showInfoDialog(context, getFailMessage(json));
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }
  }

  Future<void> transferBPTH({
    required int walletIdx,
    required String from,
    required String to,
    required String amount,
    required String symbol,
    required String gasPrice,
    required String gasLimit,
    required String token,
  }) async {
    var result = await Navigator.pushNamed(context, Routes.withdrawalPasswordPage, arguments: {'type': 2});

    if (result == null || result is! bool || !result) {
      return;
    }

    String pass = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? '';
    String passTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? '';

    var manager = ApiManagerBPTHWallet();
    dynamic json;

    try {
      loadingDialog.show();
      json = await manager.transfer(
        walletIdx: walletIdx,
        pw: AESHelper().decrypt(pass, passTs),
        to: to,
        amount: amount,
        gasPrice: gasPrice,
        gasLimit: gasLimit,
        token: token,
      );
      loadingDialog.hide();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result];

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(
          context,
          Routes.withdrawalCompletePage,
          arguments: {
            "from": from,
            "to": to,
            "amount": amount,
            "symbol": symbol,
            "memo": '',
            "gas_price": gasPriceController.text.trim(),
            "gas_limit": gasLimit,
          },
          result: true,
        );

        return;
      } else {
        if (mounted) {
          CommonFunction.showInfoDialog(context, getFailMessage(json));
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }
  }
}
