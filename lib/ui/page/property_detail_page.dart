import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
// import 'package:plastichero_app/api/wallet/wallet_bnb.dart';
// import 'package:plastichero_app/api/wallet/wallet_bpth.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/bsc_transaction_info.dart';
import 'package:plastichero_app/ui/page/transaction_detail_page.dart';
import 'package:provider/provider.dart';

import '../../constants/color_theme.dart';
import '../../data/bsc_wallet_info.dart';
import '../../data/transaction_info.dart';
import '../../data/wallet_info.dart';
import '../../manager/otp_manager.dart';
import '../../provider/wallet_provider.dart';
import '../../routes.dart';
import '../../util/common_function.dart';
import '../widget/ellipsis_text_view.dart';

class PropertyDetailPageArguments {
  final WalletType walletType;
  final WalletInfo? walletInfo;
  final BSCWalletInfo? bscWalletInfo;

  PropertyDetailPageArguments({
    this.walletType = WalletType.pth,
    this.walletInfo,
    this.bscWalletInfo,
  });
}

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({Key? key}) : super(key: key);

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  GlobalKey gbHeaderKey = GlobalKey();
  GlobalKey gbBottomTitleKey = GlobalKey();
  WalletType walletType = WalletType.pth;

  WalletInfo? walletInfo;
  BSCWalletInfo? bscWalletInfo;
  StreamController<double> scrollStreamController = StreamController<double>.broadcast();
  ScrollController scrollController = ScrollController();
  bool scrollDown = false;
  bool bottomScroll = false;
  double scrollExtentAfter = 0.0;
  double scrollPixels = 0.0;
  final int pageOffset = 20;
  int lastIdx = -1;
  int limit = 0;
  double bodyH = 0;
  bool isMoreItem = true;
  bool isFirstLoadRunning = true;
  bool isLoadMoreRunning = false;
  DateTime? clickTime;
  bool isFirstLoadRunningBottom = true;
  bool isKeyboardUp = false;
  WalletProvider? walletProvider;

  void updateWallet() {
    if (walletProvider != null) {
      if (walletType == WalletType.bsc) {
        List<BSCWalletInfo> bscWalletInfoList = walletProvider!.getBSCWalletInfoList;
        if (bscWalletInfoList.isNotEmpty) {
          if (bscWalletInfo != null) {
            for (int idx = 0; idx < bscWalletInfoList.length; idx++) {
              BSCWalletInfo bscWalletInfo = bscWalletInfoList.elementAt(idx);
              if (this.bscWalletInfo!.idx == bscWalletInfo.idx) {
                this.bscWalletInfo = bscWalletInfo;
                break;
              }
            }
          }
        }
      } else {
        List<WalletInfo> pthWalletInfoList = walletProvider!.getPTHWalletInfoList;
        if (pthWalletInfoList.isNotEmpty) {
          if (walletInfo != null) {
            for (int idx = 0; idx < pthWalletInfoList.length; idx++) {
              WalletInfo walletInfo = pthWalletInfoList.elementAt(idx);
              if (this.walletInfo!.idx == walletInfo.idx) {
                this.walletInfo = walletInfo;
                break;
              }
            }
          }
        }
      }

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    walletProvider ??= Provider.of<WalletProvider>(context, listen: false)..addListener(updateWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData(UpdateType.update);
    });
  }

  @override
  void dispose() {
    walletProvider?.removeListener(updateWallet);
    scrollController.dispose();
    scrollStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context) != null && ModalRoute.of(context)!.settings.arguments is PropertyDetailPageArguments) {
      walletType = (ModalRoute.of(context)!.settings.arguments as PropertyDetailPageArguments).walletType;
      walletInfo ??= (ModalRoute.of(context)!.settings.arguments as PropertyDetailPageArguments).walletInfo;
      bscWalletInfo ??= (ModalRoute.of(context)!.settings.arguments as PropertyDetailPageArguments).bscWalletInfo;
      if (bscWalletInfo != null) {
        walletInfo ??= WalletInfo(
          idx: bscWalletInfo!.idx,
          name: bscWalletInfo!.name,
          email: '',
          address: bscWalletInfo!.address,
          isMain: bscWalletInfo!.isMain,
          balance: bscWalletInfo!.balance,
          symbol: bscWalletInfo!.bPthSymbol,
          openSpinner: bscWalletInfo!.openSpinner,
        );
      }
    }
    double getHeight = 125 + 6 + (walletInfo == null ? 24 : getTextSize(walletInfo?.balance ?? ''));

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                height: 55,
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: SvgPicture.asset(
                        'images/icon_nav_prev.svg',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        color: Color(0xffdbdbdb),
                      ),
                      child: SvgPicture.asset(
                        'images/icon_token_default.svg',
                        width: 17,
                        height: 19,
                        fit: BoxFit.none,
                      ),
                    ),
                    const SizedBox(
                      width: 8.2,
                    ),
                    Text(
                      walletInfo?.symbol ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff121212),
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<double>(
                stream: scrollStreamController.stream,
                builder: (context, snapshot) {
                  double v = snapshot.data ?? getHeight;
                  bool visibleLine = false;
                  if (v.round() == 0 || v.round() == getHeight.round()) {
                    visibleLine = false;
                  } else {
                    visibleLine = true;
                  }
                  return Container(
                    height: 1,
                    color: visibleLine ? const Color(0xffededed) : Colors.white,
                  );
                },
              ),
              Expanded(
                child: KeyboardVisibilityBuilder(
                  builder: (context2, isKeyboardVisible) {
                    if (isKeyboardUp != isKeyboardVisible) {
                      isKeyboardUp = isKeyboardVisible;
                      if (!isKeyboardUp) {
                        FocusScope.of(context).unfocus();
                      }
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          if (notification.depth == 0) {
                            if (scrollExtentAfter > notification.metrics.extentAfter) {
                              scrollDown = true;
                            } else {
                              scrollDown = false;
                            }
                            scrollExtentAfter = notification.metrics.extentAfter;
                            scrollStreamController.add(scrollExtentAfter);
                          }
                        } else if (notification is ScrollEndNotification) {
                          if (notification.depth == 0) {
                            if (bottomScroll && scrollExtentAfter > scrollPixels) {
                              bottomScroll = false;
                              Future.delayed(Duration.zero, () {
                                scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                );
                              });
                            }
                          }
                        }
                        return true;
                      },
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior().copyWith(overscroll: false),
                        child: Listener(
                          onPointerUp: (_) async {
                            if (scrollController.offset.floor() != 0 && scrollController.offset.floor() != getHeight && scrollExtentAfter > scrollPixels) {
                              bottomScroll = false;
                              if (scrollDown) {
                                scrollController.animateTo(
                                  getHeight,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                );
                              } else {
                                scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                );
                              }
                            } else if (scrollExtentAfter < scrollPixels) {
                              bottomScroll = true;
                            }
                          },
                          child: NestedScrollView(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                              return <Widget>[
                                SliverAppBar(
                                  key: gbHeaderKey,
                                  actions: <Widget>[
                                    Container(),
                                  ],
                                  backgroundColor: const Color(0x29000000),
                                  automaticallyImplyLeading: false,
                                  pinned: true,
                                  stretch: false,
                                  floating: false,
                                  elevation: 3.0,
                                  shadowColor: const Color(0x29000000),
                                  toolbarHeight: 0,
                                  expandedHeight: getHeight,
                                  flexibleSpace: FlexibleSpaceBar(
                                    stretchModes: const <StretchMode>[
                                      StretchMode.zoomBackground,
                                      StretchMode.blurBackground,
                                    ],
                                    background: Container(
                                      color: Colors.white,
                                      child: AnimatedCrossFade(
                                        crossFadeState: isFirstLoadRunning ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                        duration: const Duration(milliseconds: 300),
                                        firstCurve: Curves.fastOutSlowIn,
                                        firstChild: Container(
                                          constraints: BoxConstraints(
                                            minHeight: getHeight,
                                          ),
                                          alignment: Alignment.center,
                                          child: const CircularProgressIndicator(
                                            color: Color(0xff19984b),
                                          ),
                                        ),
                                        secondCurve: Curves.fastOutSlowIn,
                                        secondChild: SizedBox(
                                          height: getHeight,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  margin: const EdgeInsets.only(left: 24, right: 24, top: 6),
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(15),
                                                      topRight: Radius.circular(15),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0x29000000),
                                                        blurRadius: 6,
                                                        spreadRadius: 0,
                                                        offset: Offset(0.0, 0.0),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 18, right: 18, top: 19),
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(15),
                                                        topRight: Radius.circular(15),
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'property_held'.tr(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            height: 1.0,
                                                            fontSize: 14,
                                                            fontFamily: Setting.appFont,
                                                            fontWeight: FontWeight.w600,
                                                            color: Color(0xff121212),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(top: 18.4),
                                                          padding: const EdgeInsets.only(left: 4, right: 4),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  CommonFunction.getDecimalFormatFormString(
                                                                    walletInfo?.balance ?? '0',
                                                                  ),
                                                                  style: const TextStyle(
                                                                    height: 1.2,
                                                                    fontSize: 24,
                                                                    fontFamily: Setting.appFont,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: Color(0xff121212),
                                                                  ),
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
                                              Container(
                                                width: double.infinity,
                                                height: 48,
                                                margin: const EdgeInsets.only(left: 24, right: 24),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: double.infinity,
                                                        decoration: const BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            bottomLeft: Radius.circular(15),
                                                          ),
                                                          color: Color(0xff19984b),
                                                        ),
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () {
                                                              CommonFunction.hideKeyboard(context);
                                                              Navigator.pushNamed(
                                                                context,
                                                                Routes.depositPage,
                                                                arguments: {
                                                                  'symbol': walletInfo?.symbol ?? '',
                                                                  'address': walletInfo?.address ?? '',
                                                                },
                                                              );
                                                            },
                                                            hoverColor: Colors.transparent,
                                                            splashColor: Colors.transparent,
                                                            highlightColor: const Color(0xff14793c),
                                                            borderRadius: const BorderRadius.only(
                                                              bottomLeft: Radius.circular(15),
                                                            ),
                                                            child: Container(
                                                              height: double.infinity,
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  bottomLeft: Radius.circular(15),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    'images/icon_receive.svg',
                                                                    width: 16,
                                                                    height: 16,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    'deposit'.tr(),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                      height: 1.0,
                                                                      fontSize: 14,
                                                                      fontFamily: Setting.appFont,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: double.infinity,
                                                        decoration: const BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            bottomRight: Radius.circular(15),
                                                          ),
                                                          color: Color(0xff19984b),
                                                        ),
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () async {
                                                              CommonFunction.hideKeyboard(context);

                                                              OtpManager(context: context).checkOtp(
                                                                onSuccess: () async {
                                                                  var result = await Navigator.pushNamed(
                                                                    context,
                                                                    Routes.withdrawalPage,
                                                                    arguments: {
                                                                      'symbol': walletInfo?.symbol ?? '',
                                                                      'address': walletInfo?.address ?? '',
                                                                      'wallet_info': bscWalletInfo,
                                                                    },
                                                                  );
                                                                  if (result != null && result is bool) {
                                                                    if (mounted && result) {
                                                                      loadData(UpdateType.update);
                                                                    }
                                                                  }
                                                                },
                                                              );
                                                            },
                                                            hoverColor: Colors.transparent,
                                                            splashColor: Colors.transparent,
                                                            highlightColor: const Color(0xff14793c),
                                                            borderRadius: const BorderRadius.only(
                                                              bottomRight: Radius.circular(15),
                                                            ),
                                                            child: Container(
                                                              height: double.infinity,
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  bottomRight: Radius.circular(15),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    'images/icon_send.svg',
                                                                    width: 16,
                                                                    height: 16,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    'withdraw'.tr(),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                      height: 1.0,
                                                                      fontSize: 14,
                                                                      fontFamily: Setting.appFont,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
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
                                  ),
                                ),
                              ];
                            },
                            body: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                double height = constraints.maxHeight;
                                return NotificationListener<ScrollUpdateNotification>(
                                  onNotification: (notification) {
                                    if (isMoreItem && !isFirstLoadRunning && !isFirstLoadRunningBottom && !isLoadMoreRunning && notification.metrics.extentAfter < 1000) {
                                      loadData(UpdateType.add);
                                    }
                                    return false;
                                  },
                                  child: Column(
                                    children: [
                                      Stack(
                                        key: gbBottomTitleKey,
                                        children: [
                                          Container(
                                            height: 48,
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(left: 24, top: 12),
                                            padding: const EdgeInsets.only(left: 20, right: 20),
                                            alignment: Alignment.centerLeft,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                              color: Color(0xffe7f5ec),
                                            ),
                                            child: Text(
                                              'transaction_history'.tr(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                height: 1.0,
                                                fontSize: 15,
                                                fontFamily: Setting.appFont,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff121212),
                                              ),
                                            ),
                                          ),
                                          StreamBuilder<double>(
                                            stream: scrollStreamController.stream,
                                            builder: (context, snapshot) {
                                              double v = snapshot.data ?? getHeight;
                                              bool visibleLine = false;
                                              if (v.round() == 0 || v.round() == getHeight.round()) {
                                                visibleLine = false;
                                              } else {
                                                visibleLine = true;
                                              }
                                              return Container(
                                                height: 1,
                                                color: visibleLine ? const Color(0xffededed) : Colors.white,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: AnimatedCrossFade(
                                          crossFadeState: isFirstLoadRunningBottom ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                          duration: const Duration(milliseconds: 300),
                                          firstCurve: Curves.fastOutSlowIn,
                                          firstChild: Container(
                                            margin: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
                                            padding: const EdgeInsets.only(bottom: 50),
                                            alignment: Alignment.center,
                                            child: const CircularProgressIndicator(
                                              color: Color(0xff19984b),
                                            ),
                                          ),
                                          secondCurve: Curves.fastOutSlowIn,
                                          secondChild: RefreshIndicator(
                                            color: const Color(ColorTheme.appColor),
                                            onRefresh: () async {
                                              await loadData(UpdateType.update);
                                              // await Future.delayed(const Duration(seconds: 1));
                                            },
                                            child: (walletType == WalletType.bsc
                                                    ? (walletInfo != null && walletInfo!.bscTransactionInfoList != null && walletInfo!.bscTransactionInfoList!.isNotEmpty)
                                                    : (walletInfo != null && walletInfo!.transactionInfoList != null && walletInfo!.transactionInfoList!.isNotEmpty))
                                                ? Container(
                                                    margin: const EdgeInsets.only(left: 24, right: 24),
                                                    child: ListView.separated(
                                                      padding: const EdgeInsets.only(top: 12),
                                                      physics: const BouncingScrollPhysics(
                                                        parent: AlwaysScrollableScrollPhysics(),
                                                      ),
                                                      shrinkWrap: true,
                                                      itemCount: (walletType == WalletType.bsc
                                                          ? (walletInfo != null && walletInfo!.bscTransactionInfoList != null && walletInfo!.bscTransactionInfoList!.isNotEmpty
                                                              ? walletInfo!.bscTransactionInfoList!.length
                                                              : 0)
                                                          : (walletInfo != null && walletInfo!.transactionInfoList != null && walletInfo!.transactionInfoList!.isNotEmpty
                                                              ? walletInfo!.transactionInfoList!.length
                                                              : 0)),
                                                      separatorBuilder: (context, index) {
                                                        return SizedBox(
                                                          height: 10,
                                                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                            Container(
                                                              width: 1,
                                                              margin: const EdgeInsets.only(left: 7.5),
                                                              color: const Color(0xffededed),
                                                              alignment: Alignment.center,
                                                            ),
                                                          ]),
                                                        );
                                                      },
                                                      itemBuilder: (context, index) {
                                                        if (walletInfo != null) {
                                                          return item(walletInfo!, index);
                                                        } else {
                                                          return Container();
                                                        }
                                                      },
                                                    ),
                                                  )
                                                : ScrollConfiguration(
                                                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                                                    child: SingleChildScrollView(
                                                      physics: const BouncingScrollPhysics(),
                                                      child: Container(
                                                        height: height - (12 * 2) - 50,
                                                        margin: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
                                                        padding: const EdgeInsets.only(bottom: 50),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          'msg_empty_transaction_history'.tr(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            height: 1.0,
                                                            fontSize: 14,
                                                            fontFamily: Setting.appFont,
                                                            fontWeight: FontWeight.w400,
                                                            color: Color(0xff767676),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget item(WalletInfo walletInfo, int index) {
    if (walletType == WalletType.bsc) {
      if (walletInfo.bscTransactionInfoList != null && walletInfo.bscTransactionInfoList!.isNotEmpty) {
        BSCTransactionInfo bscTransactionInfo = walletInfo.bscTransactionInfoList!.elementAt(index);
        BSCTransactionInfo? preBscTransactionInfo;
        if (index > 0 && walletInfo.bscTransactionInfoList!.length > 1) {
          preBscTransactionInfo = walletInfo.bscTransactionInfoList!.elementAt(index - 1);
        }
        return InkWell(
          onTap: () {
            CommonFunction.hideKeyboard(context);
            Navigator.of(context).pushNamed(
              Routes.transactionDetailPage,
              arguments: TransactionDetailPageArguments(bscTransactionInfo: bscTransactionInfo),
            );
          },
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (index == 0 ||
                        CommonFunction.getTimeFormat('yyyy.MM.dd', preBscTransactionInfo != null ? preBscTransactionInfo.timestamp : bscTransactionInfo.timestamp) !=
                            CommonFunction.getTimeFormat('yyyy.MM.dd', bscTransactionInfo.timestamp)) ...{
                      Container(
                        width: 1,
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        color: index == 0 ? Colors.white : const Color(0xffededed),
                        alignment: Alignment.center,
                      ),
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(2.5),
                          ),
                          color: Color(0xff19984b),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.only(right: 4),
                        color: const Color(0xffededed),
                        alignment: Alignment.center,
                      ),
                    },
                    Container(
                      width: 1,
                      height: 78,
                      margin: const EdgeInsets.only(right: 4),
                      color: const Color(0xffededed),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0 ||
                        CommonFunction.getTimeFormat('yyyy.MM.dd', preBscTransactionInfo != null ? preBscTransactionInfo.timestamp : bscTransactionInfo.timestamp) !=
                            CommonFunction.getTimeFormat('yyyy.MM.dd', bscTransactionInfo.timestamp)) ...{
                      Container(
                        height: 16,
                        margin: const EdgeInsets.only(top: 2, bottom: 12),
                        child: Text(
                          CommonFunction.getTimeFormat('yyyy.MM.dd', bscTransactionInfo.timestamp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.0,
                            fontSize: 13,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff121212),
                          ),
                        ),
                      ),
                    },
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 18,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(9),
                            ),
                            color: Color(0xffededed),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            bscTransactionInfo.transactionType == TransactionType.deposit ? 'from_en'.tr() : 'to_en'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff121212),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: EllipsisTextView(
                            text: bscTransactionInfo.transactionType == TransactionType.deposit ? bscTransactionInfo.fromAddress : bscTransactionInfo.toAddress,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w400,
                              color: Color(ColorTheme.defaultText),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Text(
                          CommonFunction.getTimeFormat('HH:mm:ss', bscTransactionInfo.timestamp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff999999),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(9)),
                            color: bscTransactionInfo.transactionType == TransactionType.deposit ? const Color(ColorTheme.c_eff2fe) : const Color(ColorTheme.c_feeeee),
                          ),
                          child: SvgPicture.asset(
                            bscTransactionInfo.transactionType == TransactionType.deposit ? 'images/icon_history_receive.svg' : 'images/icon_history_send.svg',
                            width: 10,
                            height: 8,
                            fit: BoxFit.none,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          CommonFunction.getDecimalFormatFormString(
                            bscTransactionInfo.amount,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff121212),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          bscTransactionInfo.symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.5,
                            fontSize: 12,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff121212),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    } else {
      if (walletInfo.transactionInfoList != null && walletInfo.transactionInfoList!.isNotEmpty) {
        TransactionInfo transactionInfo = walletInfo.transactionInfoList!.elementAt(index);
        TransactionInfo? preTransactionInfo;
        if (index > 0 && walletInfo.transactionInfoList!.length > 1) {
          preTransactionInfo = walletInfo.transactionInfoList!.elementAt(index - 1);
        }
        return InkWell(
          onTap: () {
            CommonFunction.hideKeyboard(context);
            Navigator.of(context).pushNamed(
              Routes.transactionDetailPage,
              arguments: TransactionDetailPageArguments(transactionInfo: transactionInfo),
            );
          },
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (index == 0 ||
                        CommonFunction.getTimeFormat('yyyy.MM.dd', preTransactionInfo != null ? preTransactionInfo.timestamp : transactionInfo.timestamp) !=
                            CommonFunction.getTimeFormat('yyyy.MM.dd', transactionInfo.timestamp)) ...{
                      Container(
                        width: 1,
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        color: index == 0 ? Colors.white : const Color(0xffededed),
                        alignment: Alignment.center,
                      ),
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(2.5),
                          ),
                          color: Color(0xff19984b),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.only(right: 4),
                        color: const Color(0xffededed),
                        alignment: Alignment.center,
                      ),
                    },
                    Container(
                      width: 1,
                      height: 78,
                      margin: const EdgeInsets.only(right: 4),
                      color: const Color(0xffededed),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0 ||
                        CommonFunction.getTimeFormat('yyyy.MM.dd', preTransactionInfo != null ? preTransactionInfo.timestamp : transactionInfo.timestamp) !=
                            CommonFunction.getTimeFormat('yyyy.MM.dd', transactionInfo.timestamp)) ...{
                      Container(
                        height: 16,
                        margin: const EdgeInsets.only(top: 2, bottom: 12),
                        child: Text(
                          CommonFunction.getTimeFormat('yyyy.MM.dd', transactionInfo.timestamp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.0,
                            fontSize: 13,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff121212),
                          ),
                        ),
                      ),
                    },
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 18,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(9),
                            ),
                            color: Color(0xffededed),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            transactionInfo.transactionType == TransactionType.deposit ? 'from_en'.tr() : 'to_en'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff121212),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            transactionInfo.transactionType == TransactionType.deposit ? transactionInfo.from : transactionInfo.to,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff121212),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Text(
                          CommonFunction.getTimeFormat('HH:mm:ss', transactionInfo.timestamp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff999999),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        transactionInfo.memo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          height: 1.0,
                          fontSize: 13,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff666666),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(9)),
                            color: transactionInfo.transactionType == TransactionType.deposit ? const Color(ColorTheme.c_eff2fe) : const Color(ColorTheme.c_feeeee),
                          ),
                          child: SvgPicture.asset(
                            transactionInfo.transactionType == TransactionType.deposit ? 'images/icon_history_receive.svg' : 'images/icon_history_send.svg',
                            width: 10,
                            height: 8,
                            fit: BoxFit.none,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          CommonFunction.getDecimalFormatFormString(
                            transactionInfo.amount,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff121212),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          transactionInfo.symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.5,
                            fontSize: 12,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff121212),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    }
  }

  // TODO: loadData()
  Future<void> loadData(UpdateType updateType) async {
    if (isLoadMoreRunning) {
      return;
    }

    if (updateType == UpdateType.update) {
      lastIdx = -1;
    }
    isLoadMoreRunning = true;

    if (updateType == UpdateType.update) {
      // isFirstLoadRunning = true;
      if (walletType == WalletType.bsc) {
        // getBSCWalletList();
        // isFirstLoadRunningBottom = true;
        // await bscTransferList(UpdateType.update);
      } else {
        // isFirstLoadRunningBottom = true;
        await transferList(UpdateType.update);
        getWalletList();
      }
    } else {
      if (walletType == WalletType.bsc) {
        // await bscTransferList(UpdateType.add);
      } else {
        await transferList(UpdateType.add);
      }
    }
    isLoadMoreRunning = false;
  }

  void topScroll() {
    if (scrollController.hasClients && scrollController.offset > 0) {
      scrollController.jumpTo(0);
    }
  }

  Future<void> getWalletList() async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
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
        if (walletList.isNotEmpty) {
          if (walletInfo != null) {
            for (int idx = 0; idx < walletList.length; idx++) {
              WalletInfo walletInfo = walletList.elementAt(idx);
              if (this.walletInfo!.idx == walletInfo.idx) {
                this.walletInfo = walletInfo;
                break;
              }
            }
          }
        }

        if (walletProvider != null) {
          walletProvider!.setWalletInfoList(pthWalletInfoList: walletList);
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (isFirstLoadRunning) {
        setState(() {
          isFirstLoadRunning = false;
        });
      }
    }
  }

  // Future<void> getBSCWalletList() async {
  //   String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
  //   if (sessionCode.isEmpty) {
  //     return;
  //   }
  //
  //   var manager = ApiManagerBPTHWallet();
  //   dynamic json;
  //   try {
  //     json = await manager.list();
  //     final status = json[ApiParamKey.status];
  //     if (status == ApiParamKey.success) {
  //       var result = json[ApiParamKey.result];
  //       List<BSCWalletInfo>? bscWalletList = result.map<BSCWalletInfo>((json) => BSCWalletInfo.fromJson(json)).toList();
  //       if (bscWalletList != null && bscWalletList.isNotEmpty) {
  //         if (bscWalletInfo != null) {
  //           for (int idx = 0; idx < bscWalletList.length; idx++) {
  //             BSCWalletInfo bscWalletInfo = bscWalletList.elementAt(idx);
  //             if (this.bscWalletInfo!.idx == bscWalletInfo.idx) {
  //               this.bscWalletInfo = bscWalletInfo;
  //               break;
  //             }
  //           }
  //
  //           if (bscWalletInfo != null) {
  //             if (walletInfo == null) {
  //               walletInfo = WalletInfo(
  //                 idx: bscWalletInfo!.idx,
  //                 name: bscWalletInfo!.name,
  //                 email: '',
  //                 address: bscWalletInfo!.address,
  //                 isMain: bscWalletInfo!.isMain,
  //                 balance: bscWalletInfo!.balance,
  //                 symbol: bscWalletInfo!.bPthSymbol,
  //                 openSpinner: bscWalletInfo!.openSpinner,
  //               );
  //             } else {
  //               walletInfo!.idx = bscWalletInfo!.idx;
  //               walletInfo!.name = bscWalletInfo!.name;
  //               walletInfo!.address = bscWalletInfo!.address;
  //               walletInfo!.isMain = bscWalletInfo!.isMain;
  //               if (walletInfo!.symbol.toUpperCase() == BSCWalletType.bnb.symbol.toUpperCase()) {
  //                 walletInfo!.balance = bscWalletInfo!.bnbBalance;
  //               } else {
  //                 walletInfo!.balance = bscWalletInfo!.balance;
  //               }
  //               walletInfo!.openSpinner = bscWalletInfo!.openSpinner;
  //             }
  //           }
  //         }
  //       }
  //
  //       if (walletProvider != null) {
  //         walletProvider!.setBSCWalletInfoList(bscWalletInfoList: bscWalletList);
  //       }
  //     } else {
  //       if (context.mounted) {
  //         await CheckResponse.checkErrorResponse(context, json);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     if (isFirstLoadRunning) {
  //       setState(() {
  //         isFirstLoadRunning = false;
  //       });
  //     }
  //   }
  // }

  Future<void> transferList(UpdateType updateType) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunningBottom = false;
      return;
    }

    if (walletInfo == null) {
      return;
    }

    var manager = ApiManagerPTHWallet();

    dynamic json;
    try {
      json = await manager.transferList(walletIdx: walletInfo!.idx, lastIdx: lastIdx);
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        var result = json[ApiParamKey.result];
        if (updateType == UpdateType.update) {
          if (walletInfo != null) {
            if (walletInfo!.transactionInfoList != null) {
              walletInfo!.transactionInfoList!.clear();
            } else {
              walletInfo!.transactionInfoList = [];
            }
          }
        }

        if (result != null && result is List) {
          if (walletInfo != null) {
            List<TransactionInfo> list = result.map((json) => TransactionInfo.fromJson(json, walletInfo!.address)).toList();
            if (list.length >= limit) {
              int lastIdx = list.elementAt(list.length - 1).idx;
              if (lastIdx > 1) {
                this.lastIdx = lastIdx - 1;
              } else {
                isMoreItem = false;
              }
            } else {
              isMoreItem = false;
            }

            if (mounted) {
              setState(() {
                if (isFirstLoadRunningBottom) {
                  topScroll();
                  if (walletInfo != null) {
                    if (walletInfo!.transactionInfoList != null) {
                      walletInfo!.transactionInfoList!.clear();
                    } else {
                      walletInfo!.transactionInfoList = [];
                    }
                    walletInfo!.transactionInfoList!.addAll(list);
                  }
                }
              });
            }
          }
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (isLoadMoreRunning) {
        isLoadMoreRunning = false;
        setState(() {});
      }

      if (isFirstLoadRunningBottom) {
        isFirstLoadRunningBottom = false;
        setState(() {});
      }
    }
  }

  // Future<void> bscTransferList(UpdateType updateType) async {
  //   String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
  //   if (sessionCode.isEmpty) {
  //     isFirstLoadRunningBottom = false;
  //     return;
  //   }
  //
  //   if (walletInfo == null) {
  //     return;
  //   }
  //
  //   Object manager;
  //   if (walletInfo!.symbol.toUpperCase() == BSCWalletType.bnb.symbol.toUpperCase()) {
  //     manager = ApiManagerBNBWallet();
  //   } else {
  //     manager = ApiManagerBPTHWallet();
  //   }
  //
  //   dynamic json;
  //   try {
  //     if (walletInfo!.symbol.toUpperCase() == BSCWalletType.bnb.symbol.toUpperCase()) {
  //       if (manager is ApiManagerBNBWallet) {
  //         json = await manager.transferList(walletIdx: walletInfo!.idx, lastIdx: lastIdx);
  //       }
  //     } else {
  //       if (manager is ApiManagerBPTHWallet) {
  //         json = await manager.transferList(walletIdx: walletInfo!.idx, lastIdx: lastIdx);
  //       }
  //     }
  //
  //     final status = json[ApiParamKey.status];
  //     if (status == ApiParamKey.success) {
  //       var result = json[ApiParamKey.result];
  //       if (updateType == UpdateType.update) {
  //         if (walletInfo != null) {
  //           if (walletInfo!.bscTransactionInfoList != null) {
  //             walletInfo!.bscTransactionInfoList!.clear();
  //           } else {
  //             walletInfo!.bscTransactionInfoList = [];
  //           }
  //         }
  //       }
  //
  //       if (result != null && result is List) {
  //         if (walletInfo != null) {
  //           List<BSCTransactionInfo> bscList = result.map((json) => BSCTransactionInfo.fromJson(json, walletInfo!.address)).toList();
  //           if (bscList.isNotEmpty) {
  //             lastIdx = bscList.last.idx;
  //             isMoreItem = true;
  //           } else {
  //             isMoreItem = false;
  //           }
  //
  //           walletInfo!.bscTransactionInfoList!.addAll(bscList);
  //
  //           if (updateType == UpdateType.update) {
  //             topScroll();
  //           }
  //         }
  //       }
  //     } else {
  //       if (context.mounted) {
  //         await CheckResponse.checkErrorResponse(context, json);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     if (isFirstLoadRunningBottom) {
  //       isFirstLoadRunningBottom = false;
  //     }
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   }
  //   Future.delayed(const Duration(milliseconds: 100)).then((_) {
  //     isLoadMoreRunning = false;
  //   });
  // }

  double getTextSize(String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        height: 1.2,
        fontSize: 24,
        fontFamily: Setting.appFont,
        fontWeight: FontWeight.w700,
        color: Color(0xff121212),
      ),
    );

    // Layout and measure link
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: material.TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 92);
    return textPainter.height;
  }
}
