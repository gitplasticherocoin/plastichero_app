import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/data/bsc_wallet_info.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:provider/provider.dart';

import '../../constants/color_theme.dart';
import '../../constants/common.dart';
import '../../constants/setting.dart';
import '../../provider/wallet_provider.dart';
import '../widget/button_widget.dart';

class SelectWalletDialog extends StatefulWidget {
  final String symbol;
  final String address;
  final ValueChanged<int> onSelect;

  const SelectWalletDialog({
    Key? key,
    this.address = '',
    required this.symbol,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<SelectWalletDialog> createState() => _SelectWalletDialogState();
}

class _SelectWalletDialogState extends State<SelectWalletDialog> {
  String selectAddress = '';
  int selectIdx = -1;

  List<WalletInfo> walletInfoList = [];
  List<BSCWalletInfo> bscWalletInfoList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectAddress = widget.address;
  }

  @override
  Widget build(BuildContext context) {
    double disHeight = MediaQuery.of(context).size.height;
    EdgeInsets bottomEdge = MediaQuery.of(context).viewInsets;
    double topPadding = window.viewPadding.top / window.devicePixelRatio;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      constraints: BoxConstraints(maxHeight: disHeight - bottomEdge.bottom - topPadding - Common.appBar),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'wallet_selection'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontFamily: Setting.appFont,
              fontWeight: FontWeight.w700,
              color: Color(ColorTheme.defaultText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
            child: Text(
              'wallet_selection_guide'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: Setting.appFont,
                fontWeight: FontWeight.w400,
                color: Color(ColorTheme.defaultText),
              ),
            ),
          ),
          Flexible(
            child: Consumer<WalletProvider>(
              builder: (context, provider, __) {
                if (widget.symbol.toUpperCase() == WalletType.pth.symbol) {
                  walletInfoList = provider.getPTHWalletInfoList;
                  return ListView.separated(
                    itemCount: walletInfoList.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 9.0),
                    separatorBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(ColorTheme.c_ededed),
                      );
                    },
                    itemBuilder: (context, index) {
                      WalletInfo info = walletInfoList[index];

                      return GestureDetector(
                        onTap: () {
                          if (selectAddress != info.address) {
                            setState(() {
                              selectIdx = index;
                              selectAddress = info.address;
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 16.0, bottom: 15.0, left: 10.0, right: 10.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      info.name.isNotEmpty ? info.name : '${info.symbol} WALLET',
                                      style: const TextStyle(
                                        height: 1.2,
                                        fontSize: 15,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.defaultText),
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      '${CommonFunction.getDecimalFormatFormString(info.balance)} ${info.symbol}',
                                      style: const TextStyle(
                                        height: 1.2,
                                        fontSize: 14,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w400,
                                        color: Color(ColorTheme.c_767676),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (selectAddress == info.address) ? const Color(ColorTheme.appColor) : const Color(ColorTheme.c_dbdbdb),
                                ),
                                child: SvgPicture.asset(
                                  "images/icon_check_w_m.svg",
                                  width: 12,
                                  height: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  bscWalletInfoList = provider.getBSCWalletInfoList;
                  return ListView.separated(
                    itemCount: bscWalletInfoList.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 9.0),
                    separatorBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(ColorTheme.c_ededed),
                      );
                    },
                    itemBuilder: (context, index) {
                      BSCWalletInfo info = bscWalletInfoList[index];

                      return GestureDetector(
                        onTap: () {
                          if (selectAddress != info.address) {
                            setState(() {
                              selectIdx = index;
                              selectAddress = info.address;
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 16.0, bottom: 15.0, left: 10.0, right: 10.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      info.name.isNotEmpty ? info.name : '${widget.symbol} WALLET',
                                      style: const TextStyle(
                                        height: 1.2,
                                        fontSize: 15,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.defaultText),
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      '${CommonFunction.getDecimalFormatFormString(widget.symbol.toUpperCase() == BSCWalletType.bnb.symbol ? info.bnbBalance : info.balance)} ${widget.symbol}',
                                      style: const TextStyle(
                                        height: 1.2,
                                        fontSize: 14,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w400,
                                        color: Color(ColorTheme.c_767676),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (selectAddress == info.address) ? const Color(ColorTheme.appColor) : const Color(ColorTheme.c_dbdbdb),
                                ),
                                child: SvgPicture.asset(
                                  "images/icon_check_w_m.svg",
                                  width: 12,
                                  height: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 10,
                  child: BtnBorderAppColor(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    text: "close".tr(),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  flex: 17,
                  child: BtnFill(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelect(selectIdx);
                    },
                    text: "confirm".tr(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
