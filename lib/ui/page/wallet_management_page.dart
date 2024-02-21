import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:plastichero/ui/widget/text_widget.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_bpth.dart';
import 'package:plastichero_app/api/wallet/wallet_common.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/bsc_wallet_info.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/confirm_dialog.dart';
import 'package:plastichero_app/ui/dialog/input_dialog.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';

import '../../manager/otp_manager.dart';
import '../widget/ellipsis_text_view.dart';
import 'change_wallet_password_page..dart';

class WalletManagementPageArguments {
  WalletType walletType;

  WalletManagementPageArguments({
    required this.walletType,
  });
}

class WalletManagementPage extends StatefulWidget {
  const WalletManagementPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WalletManagementPageState();
  }
}

class _WalletManagementPageState extends State<WalletManagementPage> {
  final String tag = 'WalletManagementPageArguments';

  late final LoadingDialog loadingDialog;

  WalletManagementPageArguments? args;
  bool isFirstLoadRunning = true;
  GlobalKey gbBottomKey = GlobalKey();
  bool isKeyboardUp = false;

  List<WalletInfo> walletList = [];
  List<BSCWalletInfo> bscWalletList = [];

  WalletType walletType = WalletType.pth;

  List<String> spinnerItems = [];
  List<bool> isOpenSpinnerList = [];

  int openSpinnerIdx = -1;

  bool isAddingBPTH = false;

  String _newPass = "";
  bool _isEnalbePButton = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingDialog = LoadingDialog(context: context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      spinnerItems.clear();
      if (walletType == WalletType.bsc) {
        spinnerItems.add('set_wallet_password');
        // spinnerItems.add('delete');
        getBSCWalletList();
      } else {
        spinnerItems.add('change_wallet_password');
        spinnerItems.add('change_wallet_name');
        spinnerItems.add('master_key_title');
        // spinnerItems.add('delete');
        getWalletList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context) != null) {
      if (ModalRoute.of(context)!.settings.arguments is WalletManagementPageArguments) {
        args = ModalRoute.of(context)!.settings.arguments as WalletManagementPageArguments;
        if (args != null) {
          walletType = args!.walletType;
        }
      }
    }
    return GestureDetector(
      onTap: () {
        closeSpinner();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: DefaultToolbar(
              titleText: 'wallet_management'.tr(),
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (!isFirstLoadRunning) ...{
                  if (walletType == WalletType.bsc) ...{
                    Expanded(
                      child: bscWalletList.isNotEmpty ? buildContents() : noDataView(),
                    ),
                  } else ...{
                    Expanded(
                      child: walletList.isNotEmpty ? buildContents() : noDataView(),
                    ),
                  }
                } else ...{
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.only(bottom: 30.0),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Color(ColorTheme.appColor),
                      ),
                    ),
                  ),
                },
                Container(
                  key: gbBottomKey,
                  padding: const EdgeInsets.only(left: 24, top: 10, right: 24, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: BtnFill(
                          icon: 'images/icon_plus_.svg',
                          text: 'wallet_create'.tr(),
                          btnColor: const Color(ColorTheme.c_4b4b4b),
                          pressBtnColor: const Color(ColorTheme.c_333333),
                          onTap: goWalletCreate,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        flex: 1,
                        child: BtnFill(
                          icon: 'images/icon_prev.svg',
                          text: 'wallet_import'.tr(),
                          btnColor: const Color(ColorTheme.c_4b4b4b),
                          pressBtnColor: const Color(ColorTheme.c_333333),
                          onTap: goWalletImport,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  closeSpinner() {
    if (openSpinnerIdx >= 0) {
      setState(() {
        openSpinnerIdx = -1;
      });
    }
  }

  refreshData() async {
    if (walletType == WalletType.bsc) {
      getBSCWalletList();
    } else {
      getWalletList();
    }
  }

  Widget noDataView() {
    double bottomAreaSizeH = 0;
    if (gbBottomKey.currentContext != null) {
      final RenderBox renderBox = gbBottomKey.currentContext!.findRenderObject() as RenderBox;
      bottomAreaSizeH = renderBox.size.height;
    }

    double height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - Common.appBar - bottomAreaSizeH + 1;
    return RefreshIndicator(
      onRefresh: () async {
        await refreshData();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            child: Text(
              'msg_empty_wallet'.tr(),
              style: const TextStyle(
                height: 1.3,
                fontSize: 14,
                fontFamily: Setting.appFont,
                fontWeight: FontWeight.w400,
                color: Color(ColorTheme.c_767676),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContents() {
    double bottomAreaSizeH = 0;
    if (gbBottomKey.currentContext != null) {
      final RenderBox renderBox = gbBottomKey.currentContext!.findRenderObject() as RenderBox;
      bottomAreaSizeH = renderBox.size.height;
    }

    double height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - Common.appBar - bottomAreaSizeH + 1;
    return RefreshIndicator(
      onRefresh: () async {
        await refreshData();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: height,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, top: 6, right: 16, bottom: 25),
              shrinkWrap: true,
              itemCount: walletType == WalletType.bsc ? bscWalletList.length : walletList.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16.0);
              },
              itemBuilder: (context, index) {
                if (walletType == WalletType.bsc) {
                  BSCWalletInfo? info = bscWalletList.elementAt(index);
                  return bscItem(index: index, bscWalletInfo: info);
                } else {
                  WalletInfo? info = walletList.elementAt(index);
                  return item(index: index, walletInfo: info);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget item({required int index, WalletInfo? walletInfo}) {
    if (walletInfo != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 16, top: 2, right: 16, bottom: 2),
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                walletInfo.name.isNotEmpty ? walletInfo.name.tight() : '${walletInfo.symbol} Wallet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.0,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w700,
                                  color: Color(ColorTheme.defaultText),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ImageButton(
                                  width: 24.0,
                                  height: 24.0,
                                  isSelected: walletInfo.isMain,
                                  boxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.c_ededed),
                                  ),
                                  pressedBoxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.appColor),
                                  ),
                                  img: 'images/icon_pin.svg',
                                  pressImg: 'images/icon_pin_pressed.svg',
                                  imgWidth: 16.0,
                                  imgHeight: 16.0,
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        if (walletList != null && walletList.length > index) {
                                          for (int idx = 0; idx < walletList.length; idx++) {
                                            WalletInfo tempWalletInfo = walletList.elementAt(idx);
                                            if (walletInfo.idx == tempWalletInfo.idx) {
                                              tempWalletInfo.isMain = true;
                                            } else {
                                              tempWalletInfo.isMain = false;
                                            }
                                          }
                                        }
                                        setMain(walletInfo: walletInfo);
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ImageButton(
                                  width: 24.0,
                                  height: 24.0,
                                  isSelected: openSpinnerIdx == index,
                                  boxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.c_ededed),
                                  ),
                                  pressedBoxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.c_cccccc),
                                  ),
                                  img: 'images/icon_more.svg',
                                  imgWidth: 16.0,
                                  imgHeight: 16.0,
                                  onTap: () {
                                    CommonFunction.hideKeyboard(context);
                                    if (openSpinnerIdx != index) {
                                      openSpinnerIdx = index;
                                    } else {
                                      openSpinnerIdx = -1;
                                    }

                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (walletInfo.email.isNotEmpty) ...[
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: const Color(ColorTheme.c_ededed),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 10.0, right: 16.0),
                          child: Text(
                            walletInfo.email,
                            style: const TextStyle(
                              height: 1.2,
                              fontSize: 14,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff767676),
                            ),
                          ),
                        ),
                      ],
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 16),
                        padding: const EdgeInsets.only(left: 12, top: 11, right: 0, bottom: 11),
                        constraints: const BoxConstraints(minHeight: 42),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: const Color(ColorTheme.c_ededed),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: EllipsisTextView(
                                text: walletInfo.address,
                                style: const TextStyle(
                                  height: 1.2,
                                  fontSize: 14,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w400,
                                  color: Color(ColorTheme.defaultText),
                                ),
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () {
                                if (walletInfo != null && walletInfo.address != null && walletInfo.address.isNotEmpty) {
                                  CommonFunction.copyData(context, walletInfo.address);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
                                child: SvgPicture.asset(
                                  "images/icon_copy.svg",
                                  width: 14,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 16, top: 14, right: 16, bottom: 14),
                        alignment: Alignment.centerRight,
                        child: RichText(
                          text: TextSpan(
                            text: CommonFunction.getDecimalFormatFormString(walletInfo.balance),
                            style: const TextStyle(
                              height: 1.2,
                              fontSize: 24,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.bold,
                              color: Color(ColorTheme.defaultText),
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' ${walletInfo.symbol}',
                                style: const TextStyle(
                                  height: 1.2,
                                  fontSize: 18,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.bold,
                                  color: Color(ColorTheme.defaultText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // BtnFill(
                //   icon: 'images/icon_send.svg',
                //   text: 'withdraw'.tr(),
                //   isRound: false,
                //   onTap: () async {
                //     closeSpinner();
                //
                //     OtpManager(context: context).checkOtp(
                //       onSuccess: () async {
                //         var result = await Navigator.pushNamed(
                //           context,
                //           Routes.withdrawalPage,
                //           arguments: {
                //             'symbol': walletInfo.symbol,
                //             'wallet_info': walletInfo,
                //           },
                //         );
                //
                //         if (result != null && result is bool) {
                //           if (result) {
                //             refreshData();
                //           }
                //         }
                //       },
                //     );
                //   },
                // )
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: spinner(index),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget bscItem({required int index, BSCWalletInfo? bscWalletInfo}) {
    if (bscWalletInfo != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 16, top: 2, right: 16, bottom: 2),
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  bscWalletInfo.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w700,
                                    color: Color(ColorTheme.defaultText),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ImageButton(
                                  width: 24.0,
                                  height: 24.0,
                                  isSelected: bscWalletInfo.isMain,
                                  boxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.c_ededed),
                                  ),
                                  pressedBoxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.appColor),
                                  ),
                                  img: 'images/icon_pin.svg',
                                  pressImg: 'images/icon_pin_pressed.svg',
                                  imgWidth: 16.0,
                                  imgHeight: 16.0,
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        if (bscWalletList != null && bscWalletList.length > index) {
                                          for (int idx = 0; idx < bscWalletList.length; idx++) {
                                            BSCWalletInfo tempWalletInfo = bscWalletList.elementAt(idx);
                                            if (bscWalletInfo.idx == tempWalletInfo.idx) {
                                              tempWalletInfo.isMain = true;
                                            } else {
                                              tempWalletInfo.isMain = false;
                                            }
                                          }
                                        }
                                        setMainBSC(bscWalletInfo: bscWalletInfo);
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ImageButton(
                                  width: 24.0,
                                  height: 24.0,
                                  isSelected: openSpinnerIdx == index,
                                  boxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.c_ededed),
                                  ),
                                  pressedBoxDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ColorTheme.c_cccccc),
                                  ),
                                  img: 'images/icon_more.svg',
                                  imgWidth: 16.0,
                                  imgHeight: 16.0,
                                  onTap: () {
                                    CommonFunction.hideKeyboard(context);
                                    if (openSpinnerIdx != index) {
                                      openSpinnerIdx = index;
                                    } else {
                                      openSpinnerIdx = -1;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 16),
                        padding: const EdgeInsets.only(left: 12, top: 11, right: 0, bottom: 11),
                        constraints: const BoxConstraints(minHeight: 42),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: const Color(ColorTheme.c_ededed),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: EllipsisTextView(
                                text: bscWalletInfo.address,
                                style: const TextStyle(
                                  height: 1.2,
                                  fontSize: 14,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w400,
                                  color: Color(ColorTheme.defaultText),
                                ),
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () {
                                if (bscWalletInfo != null && bscWalletInfo.address != null && bscWalletInfo.address.isNotEmpty) {
                                  CommonFunction.copyData(context, bscWalletInfo.address);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
                                child: SvgPicture.asset(
                                  "images/icon_copy.svg",
                                  width: 14,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 16, top: 14, right: 16, bottom: 14),
                        alignment: Alignment.centerRight,
                        child: RichText(
                          text: TextSpan(
                            text: CommonFunction.getDecimalFormatFormString(bscWalletInfo.balance),
                            style: const TextStyle(
                              height: 1.2,
                              fontSize: 24,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.bold,
                              color: Color(ColorTheme.defaultText),
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' ${bscWalletInfo.bPthSymbol}',
                                style: const TextStyle(
                                  height: 1.2,
                                  fontSize: 18,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.bold,
                                  color: Color(ColorTheme.defaultText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BtnFill(
                  icon: 'images/icon_send.svg',
                  text: 'withdraw'.tr(),
                  isRound: false,
                  onTap: () async {
                    closeSpinner();

                    OtpManager(context: context).checkOtp(
                      onSuccess: () async {
                        var result = await Navigator.pushNamed(
                          context,
                          Routes.withdrawalPage,
                          arguments: {
                            'symbol': BSCWalletType.bPth.symbol,
                            'wallet_info': bscWalletInfo,
                          },
                        );
                        if (result != null && result is bool) {
                          if (result) {
                            refreshData();
                          }
                        }
                      },
                    );
                  },
                )
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: spinner(index),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget spinner(int index) {
    bool isOpenSpinner = (openSpinnerIdx == index);
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: AnimatedOpacity(
        opacity: isOpenSpinner ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        child: Visibility(
          visible: isOpenSpinner,
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              color: Colors.white,
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spinnerItems.length,
              separatorBuilder: (context, index2) {
                return Container(
                  height: 1.0,
                  color: const Color(0xffededed),
                );
              },
              itemBuilder: (context, index2) {
                if (walletType == WalletType.bsc) {
                  if (bscWalletList.isNotEmpty) {
                    BSCWalletInfo bscWalletInfo = bscWalletList.elementAt(index);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isOpenSpinnerList.length > index) {
                            setState(() {
                              openSpinnerIdx = -1;
                            });

                            if (index2 == 0) {
                              showDialog(
                                context: context,
                                barrierColor: const Color(ColorTheme.dim),
                                barrierDismissible: false,
                                builder: (BuildContext context) => InputDialog(
                                  title: 'change_wallet_name'.tr(),
                                  body: 'change_wallet_name_guide'.tr(),
                                  hint: bscWalletInfo.bPthSymbol,
                                  onConfirm: (value) {
                                    if (mounted) {
                                      if (value != null) {
                                        setState(() {
                                          bscWalletInfo.name = value;
                                          nameModifyBSC(bscWalletInfo: bscWalletInfo);
                                        });
                                      }
                                    }
                                  },
                                  btnConfirmText: 'confirm'.tr(),
                                  btnCancelText: 'cancel'.tr(),
                                ),
                              );
                            } else if (index2 == 1) {
                              showDialog(
                                context: context,
                                barrierColor: const Color(ColorTheme.dim),
                                barrierDismissible: false,
                                builder: (BuildContext context) => ConfirmDialog(
                                  title: bscWalletInfo.bPthSymbol,
                                  body: 'delete_wallet_guide'.tr(),
                                  btnConfirmText: 'delete'.tr(),
                                  btnCancelText: 'cancel'.tr(),
                                  onConfirm: () {
                                    Navigator.pushNamed(context, Routes.withdrawalPasswordPage, arguments: {'type': 2}).then((value2) {
                                      if (value2 != null && value2 is bool) {
                                        if (value2) {
                                          removeBSC(bscWalletInfo: bscWalletInfo);
                                        } else {
                                          //delete fail
                                        }
                                      }
                                    });
                                  },
                                ),
                              );
                            }
                          }
                        },
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: const Color(0xfff3f3f3),
                        borderRadius: BorderRadius.only(
                          topLeft: index2 == 0 ? const Radius.circular(12) : const Radius.circular(0),
                          bottomLeft: index2 == spinnerItems.length - 1 ? const Radius.circular(12) : const Radius.circular(0),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 46),
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  spinnerItems.elementAt(index2).tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff121212),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                } else {
                  if (walletList.isNotEmpty) {
                    WalletInfo walletInfo = walletList.elementAt(index);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isOpenSpinnerList.length > index) {
                            setState(() {
                              openSpinnerIdx = -1;
                            });

                            if (index2 == 0) {
                              Navigator.of(context).pushNamed(
                                Routes.changeWalletPasswordPage,
                                arguments: ChangeWalletPasswordArguments(walletInfo: walletInfo),
                              );
                            } else if (index2 == 1) {
                              showDialog(
                                context: context,
                                barrierColor: const Color(ColorTheme.dim),
                                barrierDismissible: false,
                                builder: (BuildContext context) => InputDialog(
                                  title: 'change_wallet_name'.tr(),
                                  body: 'change_wallet_name_guide'.tr(),
                                  hint: walletInfo.name.tight(),
                                  onConfirm: (value) {
                                    if (mounted) {
                                      if (value != null) {
                                        setState(() {
                                          walletInfo.name = value;
                                          nameModify(walletInfo: walletInfo);
                                        });
                                      }
                                    }
                                  },
                                  btnConfirmText: 'confirm'.tr(),
                                  btnCancelText: 'cancel'.tr(),
                                ),
                              );
                            } else if (index2 == 2) {
                              Navigator.of(context)
                                  .pushNamed(
                                  Routes.inputPasswordPage,
                                  arguments: {"walletInfo": walletInfo}
                              );
                            }
                          }
                        },
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: const Color(0xfff3f3f3),
                        borderRadius: BorderRadius.only(
                          topLeft: index2 == 0 ? const Radius.circular(12) : const Radius.circular(0),
                          bottomLeft: index2 == spinnerItems.length - 1 ? const Radius.circular(12) : const Radius.circular(0),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 46),
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  spinnerItems.elementAt(index2).tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff121212),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void goWalletCreate() {


    OtpManager(context: context).checkWithdrawl(
      isOtpCheck : false,
        onSuccess: () {
        goWalletCreateCore();
        }, onFail: () {
        showPassword(onSuccess: (_) {
          goWalletCreateCore();
        });
    });
  }
  void goWalletCreateCore() {
    if (mounted) {
      closeSpinner();

      if (walletType == WalletType.bsc) {
        CommonFunction.showConfirmDialog(
            context: context,
            msg: "msg_create_wallet".tr(),
            btnCancelText: 'cancel'.tr(),
            btnConfirmText: 'confirm'.tr(),
            onConfirm: () {
              addBPTH().then((value) => refreshData());
            });
      } else {
        Navigator.of(context).pushNamed(Routes.walletCreatePage).then((value) {
          if (value is bool && value) {
            showCreatedWallet();
            refreshData();
          }
        });
      }
    }
  }

  void goWalletImport() {
    OtpManager(context: context).checkWithdrawl(
        isOtpCheck : false,
        onSuccess: () {
          goWalletImportCore();
        }, onFail: () {
      showPassword(onSuccess: (_) {
        goWalletImportCore();
      });
    });
  }

  void goWalletImportCore() {
    if (mounted) {
      closeSpinner();

      if (walletType == WalletType.bsc) {
        // Navigator.of(context).pushNamed(Routes.walletImportBPTHPage).then((value) {
        //   if (value is bool && value) {
        //     refreshData();
        //   }
        // });
      } else {
        Navigator.of(context).pushNamed(Routes.walletImportPage).then((value) {
          if (value is bool && value) {
            refreshData();
          }
        });
      }
    }
  }

  Future<void> showCreatedWallet() async {
    CommonFunction.showBottomSheet(
      context: context,
      isDismissible: true,
      child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        if (isKeyboardUp != isKeyboardVisible) {
          isKeyboardUp = isKeyboardVisible;
          if (!isKeyboardUp) {
            FocusScope.of(context).unfocus();
          }
        }
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 24, right: 24, top: 24),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'images/icon_wallet.svg',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 24, right: 24, top: 12),
                    alignment: Alignment.center,
                    child: Text(
                      'success_create_wallet'.tr(),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff121212),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    alignment: Alignment.center,
                    child: Text(
                      'msg_success_create_wallet2'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        height: 1.5,
                        fontSize: 14,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff121212),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(24),
                    child: BtnFill(
                      text: 'view_all'.tr(),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      }),
    );
  }

  Future<void> getWalletList() async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      json = await manager.list();
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        var result = json[ApiParamKey.result];
        List<WalletInfo> walletList = result.map<WalletInfo>((json) => WalletInfo.fromJson(json)).toList();
        if (this.walletList != walletList) {
          setState(() {
            this.walletList = walletList;
            isOpenSpinnerList.clear();
            if (this.walletList.isNotEmpty) {
              for (int cnt = 0; cnt < this.walletList.length; cnt++) {
                isOpenSpinnerList.add(false);
              }
            }
          });
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> setMain({required WalletInfo walletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      json = await manager.setMain(walletIdx: walletInfo.idx);
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        refreshData();
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> nameModify({required WalletInfo walletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      json = await manager.nameModify(
        walletIdx: walletInfo.idx,
        name: walletInfo.name,
      );
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        refreshData();
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> remove({required WalletInfo walletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.remove(walletIdx: walletInfo.idx);
      loadingDialog.hide();
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        refreshData();
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> getBSCWalletList() async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerBPTHWallet();
    dynamic json;
    try {
      json = await manager.list();
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        var result = json[ApiParamKey.result];
        List<BSCWalletInfo> bscWalletList = result.map<BSCWalletInfo>((json) => BSCWalletInfo.fromJson(json)).toList();
        if (this.bscWalletList != bscWalletList) {
          setState(() {
            this.bscWalletList = bscWalletList;
            isOpenSpinnerList.clear();
            if (this.bscWalletList.isNotEmpty) {
              for (int cnt = 0; cnt < this.bscWalletList.length; cnt++) {
                isOpenSpinnerList.add(false);
              }
            }
          });
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> setMainBSC({required BSCWalletInfo bscWalletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerBPTHWallet();
    dynamic json;
    try {
      json = await manager.setMain(walletIdx: bscWalletInfo.idx);
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        refreshData();
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> nameModifyBSC({required BSCWalletInfo bscWalletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerBPTHWallet();
    dynamic json;
    try {
      json = await manager.nameModify(
        walletIdx: bscWalletInfo.idx,
        name: bscWalletInfo.name,
      );
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        refreshData();
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> removeBSC({required BSCWalletInfo bscWalletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning = false;
      return;
    }

    var manager = ApiManagerBPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.remove(walletIdx: bscWalletInfo.idx);
      loadingDialog.hide();

      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        refreshData();
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning = false;
    }
  }

  Future<void> addBPTH() async {
    if (isAddingBPTH) {
      return;
    }

    isAddingBPTH = true;

    var manager = ApiManagerBPTHWallet();

    dynamic json;

    try {
      loadingDialog.show();
      json = await manager.add();
      loadingDialog.hide();

      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        if (mounted) {
          CommonFunction.showToast(context, 'msg_success_create_wallet'.tr());
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }

    isAddingBPTH = false;
  }

  void showPassword({required Function(int?) onSuccess , int? index }) {
    CommonFunction.showBottomSheet(
        context: context!,
        child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          if (isKeyboardUp != isKeyboardVisible) {
            isKeyboardUp = isKeyboardVisible;
            if (!isKeyboardUp) {
              FocusScope.of(context).unfocus();
            }
          }
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height:24),
                        Row(
                          children: [
                            Expanded(
                              child: Text("user_password".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff121212),
                                  )),
                            ),

                          ],
                        ),
                        const SizedBox(height:4),
                        Text("password_desc".tr(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.0 ,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff121212),
                            )
                        ),
                        const SizedBox(height:16),
                        Text("pass".tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.0 ,
                              fontFamily:Setting.appFont,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                              color: Color(0xff121212),
                            )
                        ),
                        const SizedBox(height:6),
                        NewPasswordTextField(
                          hint: "password_placeholder".tr(),
                          onChange: (value) {

                            _newPass = value.trim();
                            if(_newPass.length >= 8) {
                              setState(() {
                                _isEnalbePButton = true;
                              });
                            }else {
                              setState(() {
                                _isEnalbePButton = false;
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            _newPass = value.trim();
                            if(_newPass.length >= 8) {
                              setState(() {
                                _isEnalbePButton = true;
                              });
                            }else {
                              setState(() {
                                _isEnalbePButton = false;
                              });
                            }
                          },


                        ),
                        const SizedBox(height:18),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: ButtonStyle4(
                                  radius: 10 ,
                                  height: 54,
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  borderColor: const Color(ColorTheme.appColor),
                                  textColor: const Color(ColorTheme.appColor),
                                  btnColor: Colors.white,
                                  text: "close".tr(),

                                ) ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ButtonStyle1(
                                  height: 54,
                                  radius: 10,
                                  isEnable: _isEnalbePButton,
                                  disableColor: const Color(ColorTheme.c_dbdbdb),
                                  btnColor: const Color(ColorTheme.appColor),
                                  textColor: const Color(ColorTheme.c_ffffff),
                                  onTap: () async {



                                    //서버 확인을 합니다.
                                    final result = await checkWithDrawPass( _newPass);
                                    if (result == 0 ) {
                                      if(mounted) {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pushNamed(
                                            Routes.withdrawalPasswordPage, arguments: {"type": 1})
                                            .whenComplete(() async {
                                          onSuccess.call(index != null ? index : null);
                                        });
                                      }
                                    }else if(result == 1) {
                                      if(mounted) {
                                        Navigator.of(context).pop();
                                      }
                                      onSuccess.call(index != null ? index : null );
                                    }else if(result == -1) {
                                      if(mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    }



                                    // final idx = walletInfo?.idx ?? 0;
                                    // if(idx != 0 ) {

                                    //}

                                  },
                                  text: "confirm".tr()
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height:24),

                      ],
                    ));
              });
        }));
  }


  Future<int> checkWithDrawPass(String pass) async {
    var manager = ApiManageHWalletCommon();
    dynamic json;
    try {
      json = await manager.getPass(pw: pass);
      final status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        final pw = json[ApiParamKey.pw];
        if(pw != "") {
          final timestamp = json[ApiParamKey.timestamp];
          final depass = AESHelper().decrypt(pw, timestamp);
          if (depass == "" ) {
            return 0;
          } else {
            await CommonFunction.setPreferencesString(PreferenceKey.withdrawalPass, pw);
            await CommonFunction.setPreferencesString(PreferenceKey.withdrawalPassTs, timestamp);
            return 1;
          }
        }else {
          return 0;
        }

      }else {
        if(mounted) {
          final msg = json[ApiParamKey.msg] ?? "";
          CommonFunction.showToast(context, msg);
        }
        return -1;
      }
    } catch (e) {

      debugPrint(e.toString());
      return -1;
    }

  }
}
