import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero/ui/widget/text_widget.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:plastichero_app/api/wallet/wallet_common.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/data/bsc_wallet_info.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/provider/wallet_provider.dart';
import 'package:plastichero_app/provider/welcome_to_bpth_provider.dart';
import 'package:plastichero_app/ui/dialog/input_dialog.dart';
import 'package:plastichero_app/ui/page/property_detail_page.dart';
import 'package:plastichero_app/ui/page/transaction_detail_page.dart';
import 'package:plastichero_app/ui/page/wallet_management_page.dart';
import 'package:plastichero_app/ui/widget/main_slide_view.dart';
import 'package:plastichero_app/util/common_function.dart';

import 'package:provider/provider.dart';

import '../../api/api_param_key.dart';
import '../../api/member/check_response.dart';
import '../../api/wallet/wallet_pth.dart';
import '../../constants/color_theme.dart';
import '../../constants/preference_key.dart';
import '../../constants/setting.dart';

import '../../data/transaction_info.dart';
import '../../manager/otp_manager.dart';
import '../../routes.dart';
import '../indicator/effect/expanding_dots_effect.dart';
import '../indicator/smooth_page_indicator.dart';

import '../widget/ellipsis_text_view.dart';
import 'change_wallet_password_page..dart';

class WalletMainPage extends StatefulWidget {
  const WalletMainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WalletMainPageState();
  }
}

class _WalletMainPageState extends State<WalletMainPage> with SingleTickerProviderStateMixin {
  ScrollController indicatorController = ScrollController();

  GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey();
  StreamController<double> scrollStreamController = StreamController<double>.broadcast();
  ScrollController scrollController = ScrollController();
  PageController? pageController;
  List<WalletInfo> pthWalletInfoList = [];
  List<BSCWalletInfo> bscWalletInfoList = [];
  List<String> spinnerItems1 = ['change_wallet_password', 'change_wallet_name', 'manage_total_wallets' ,'master_key_title'];
  List<String> spinnerItems2 = ['change_wallet_name', 'manage_total_wallets'];
  bool scrollDown = false;
  bool bottomScroll = false;
  double scrollExtentAfter = 0.0;
  double scrollPixels = 0.0;
  bool isFirstLoadRunning1 = true;
  bool isFirstLoadRunning2 = true;
  bool isLoadRunning = false;
  List<bool> isFirstLoadRunning1BottomList = [true];
  List<bool> isFirstLoadRunning2BottomList = [true];
  bool isKeyboardUp = false;
  bool isPTH = true;
  int currentPage = 0;
  WalletProvider? walletProvider;
  //WelcomeTobPTHProvider? welcomeTobPTHProvider;
  Map<String, dynamic>? arguments;
  bool isAfterSignup = false;
  double bottomListH = 0;
  bool isAddingBPTH = false;

  List<int> lastIdxList = [];
  List<bool> isMoreItemList = [];
  List<bool> isMoreLoadingItemList = [];

  MyinfoProvider? myInfoPovider;

  String _newPass = "";
  bool _isEnalbePButton = false;


  void closeSpinner({bool forceSetState = false}) {
    bool isUpdate = false;
    for (var i = 0; i < pthWalletInfoList.length; i++) {
      if (pthWalletInfoList[i].openSpinner) {
        isUpdate = true;
        pthWalletInfoList[i].openSpinner = false;
      }
    }

    for (var i = 0; i < bscWalletInfoList.length; i++) {
      if (bscWalletInfoList[i].openSpinner) {
        isUpdate = true;
        bscWalletInfoList[i].openSpinner = false;
      }
    }
    if (isUpdate || forceSetState) {
      setState(() {});
    }
  }

  Future<void> showPinnedSetting() async {
    GlobalKey gkTitle = GlobalKey();
    GlobalKey gkContents = GlobalKey();

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
                    key: gkTitle,
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
                    alignment: Alignment.center,
                    child: Text(
                      'setting_pinned_wallet'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.0,
                        fontSize: 18,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w500,
                        color: Color(ColorTheme.defaultText),
                      ),
                    ),
                  ),
                  Container(
                    key: gkContents,
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 14),
                    alignment: Alignment.center,
                    child: Text(
                      'msg_pinned_wallet'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.0,
                        fontSize: 14,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w400,
                        color: Color(ColorTheme.defaultText),
                      ),
                    ),
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    double titleH = 0;
                    double topPadding = window.viewPadding.top / window.devicePixelRatio;
                    double bottomPadding = window.viewPadding.bottom / window.devicePixelRatio;

                    if (gkTitle.currentContext != null) {
                      final RenderBox renderBox = gkTitle.currentContext!.findRenderObject() as RenderBox;
                      titleH += renderBox.size.height;
                    }
                    if (gkContents.currentContext != null) {
                      final RenderBox renderBox = gkContents.currentContext!.findRenderObject() as RenderBox;
                      titleH += renderBox.size.height;
                    }
                    return Container(
                      margin: const EdgeInsets.only(left: 24, right: 24),
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - titleH - topPadding - bottomPadding - 92),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        itemCount: isPTH ? pthWalletInfoList.length : bscWalletInfoList.length,
                        separatorBuilder: (context, index) {
                          return Container(
                            height: 1.0,
                            color: const Color(ColorTheme.c_ededed),
                          );
                        },
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isPTH) {
                                  for (var i = 0; i < pthWalletInfoList.length; i++) {
                                    if (index == i) {
                                      pthWalletInfoList.elementAt(i).isMain = true;
                                    } else {
                                      pthWalletInfoList.elementAt(i).isMain = false;
                                    }
                                  }
                                } else {
                                  for (var i = 0; i < bscWalletInfoList.length; i++) {
                                    if (index == i) {
                                      bscWalletInfoList.elementAt(i).isMain = true;
                                    } else {
                                      bscWalletInfoList.elementAt(i).isMain = false;
                                    }
                                  }
                                }
                              });
                            },
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Container(
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(minHeight: 54),
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: (isPTH && pthWalletInfoList[index].name.isNotEmpty || !isPTH && bscWalletInfoList[index].name.isNotEmpty)
                                        ? Text(
                                            isPTH ? pthWalletInfoList[index].name.tight() : bscWalletInfoList[index].name.tight(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: Setting.appFont,
                                              fontWeight: FontWeight.w400,
                                              color: Color(ColorTheme.defaultText),
                                            ),
                                          )
                                        : EllipsisTextView(
                                            text: isPTH ? pthWalletInfoList[index].address : bscWalletInfoList[index].address,
                                            style: const TextStyle(
                                              height: 1.0,
                                              fontSize: 15,
                                              fontFamily: Setting.appFont,
                                              fontWeight: FontWeight.w400,
                                              color: Color(ColorTheme.defaultText),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      color: (isPTH ? pthWalletInfoList[index].isMain : bscWalletInfoList[index].isMain) ? const Color(ColorTheme.c_19984b) : const Color(ColorTheme.c_ededed),
                                    ),
                                    child: SvgPicture.asset(
                                      (isPTH ? pthWalletInfoList[index].isMain : bscWalletInfoList[index].isMain) ? 'images/icon_pin_pressed.svg' : 'images/icon_pin.svg',
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 24),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 110,
                          child: BtnBorderAppColor(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            text: 'close'.tr(),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          flex: 190,
                          child: BtnFill(
                            onTap: () {
                              Navigator.pop(context);
                              if (isPTH) {
                                int index = -1;
                                if (pthWalletInfoList.isNotEmpty) {
                                  for (int i = 0; i < pthWalletInfoList.length; i++) {
                                    if (pthWalletInfoList.elementAt(i).isMain) {
                                      index = i;
                                      break;
                                    }
                                  }
                                  isFirstLoadRunning1 = true;
                                  setMain(walletInfo: pthWalletInfoList.elementAt(index));
                                }
                              } else {
                                int index = -1;
                                if (bscWalletInfoList.isNotEmpty) {
                                  for (int i = 0; i < bscWalletInfoList.length; i++) {
                                    if (bscWalletInfoList.elementAt(i).isMain) {
                                      index = i;
                                      break;
                                    }
                                  }
                                }
                                isFirstLoadRunning2 = false;
                                // setMainBSC(bscWalletInfo: bscWalletInfoList.elementAt(index));
                              }

                              pageController?.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn,
                              );

                              if (indicatorController.hasClients && indicatorController.position.pixels > 0) {
                                indicatorController.jumpTo(0);
                              }
                            },
                            text: 'complete'.tr(),
                          ),
                        ),
                      ],
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
                        color: Color(ColorTheme.defaultText),
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
                        color: Color(ColorTheme.defaultText),
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

  void goWalletCreate() {

    OtpManager(context: context).checkWithdrawl(
      isOtpCheck: false,
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
      if (isPTH) {
        Navigator.of(context).pushNamed(Routes.walletCreatePage).then((result) {
          if (result is bool && result) {
            refreshData();
          }
        });
      } else {
        // CommonFunction.showConfirmDialog(
        //     context: context,
        //     msg: "msg_create_wallet".tr(),
        //     btnCancelText: 'cancel'.tr(),
        //     btnConfirmText: 'confirm'.tr(),
        //     onConfirm: () {
        //       addBPTH();
        //     });
      }
    }
  }

  void goWalletImport() {

    OtpManager(context: context).checkWithdrawl(
      isOtpCheck: false,
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
      if (isPTH) {
        Navigator.of(context).pushNamed(Routes.walletImportPage).then((result) {
          if (result is bool && result) {
            refreshData(isImportWallet: true);
          }
        });
      } else {
        // Navigator.of(context).pushNamed(Routes.walletImportBPTHPage).then((result) {
        //   if (result is bool && result) {
        //     refreshData();
        //   }
        // });
      }
    }
  }

  void updateWallet() {
    // if (welcomeTobPTHProvider != null) {
    //   // bool bPthFirstCreated = welcomeTobPTHProvider!.getBPTHFirstCreated;
    //   // if (bPthFirstCreated) {
    //   //   welcomeTobPTHProvider!.firstCreatedBPTH(false);
    //   //   isPTH = false;
    //   //   scrollController.jumpTo(0);
    //   //   scrollStreamController.add(0);
    //   //   pageController?.jumpTo(0);
    //   // if (indicatorController.hasClients && indicatorController.position.pixels > 0) {
    //   //   indicatorController.jumpTo(0);
    //   // }
    //   //   showCreatedWallet();
    //   // }
    // } else {
    if (walletProvider != null) {
      List<WalletInfo> pthWalletInfoList = walletProvider!.getPTHWalletInfoList;
      if (this.pthWalletInfoList != pthWalletInfoList) {
        this.pthWalletInfoList = pthWalletInfoList;
        setState(() {});
      }

      List<BSCWalletInfo> bscWalletInfoList = walletProvider!.getBSCWalletInfoList;
      if (this.bscWalletInfoList != bscWalletInfoList) {
        this.bscWalletInfoList = bscWalletInfoList;
        setState(() {});
      }
    }
    // }
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    walletProvider ??= Provider.of<WalletProvider>(context, listen: false)..addListener(updateWallet);
    myInfoPovider ??= Provider.of<MyinfoProvider>(context, listen : false)..addListener(updateWallet);
    // welcomeTobPTHProvider ??= Provider.of<WelcomeTobPTHProvider>(context, listen: false)..addListener(updateWallet);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isPTH) {
        getWalletList().whenComplete(() {
          if (pthWalletInfoList.length > currentPage) {
            WalletInfo walletInfo = pthWalletInfoList.elementAt(currentPage);
            loadData(walletInfo: walletInfo, updateType: UpdateType.update);
          }
        });
      }

      // else {
      //   getBSCWalletList();
      // }

      if (isAfterSignup) {
        Navigator.pushNamed(context, Routes.withdrawalPasswordPage, arguments: {'type': 1});
      }
    });
  }

  @override
  void dispose() {
    pageController?.dispose();
    walletProvider?.removeListener(updateWallet);
    // welcomeTobPTHProvider?.removeListener(updateWallet);
    scrollController.dispose();
    scrollStreamController.close();
    indicatorController.dispose();
    myInfoPovider?.removeListener(updateWallet);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (arguments == null) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        isAfterSignup = arguments!['afterSignup'] ?? false;
      }
    }
    double expandedByPet = 41;
    double getHeight = (isPTH ? 260 + expandedByPet : 205) + ((isPTH ? pthWalletInfoList.isNotEmpty : bscWalletInfoList.isNotEmpty) ? 20 : 4);

    return WillPopScope(
      onWillPop: () async {
        if (mainScaffoldKey.currentState != null && mainScaffoldKey.currentState!.isEndDrawerOpen) {

          return false;
        } else if (isPTH
            ? ((pthWalletInfoList.length - 1 < currentPage) ? false : pthWalletInfoList[currentPage].openSpinner)
            : ((bscWalletInfoList.length - 1 < currentPage) ? false : bscWalletInfoList[currentPage].openSpinner)) {
          closeSpinner();
          return false;
        } else {
          bool result = false;
          await CommonFunction.showConfirmDialog(
              isAwait: true,
              context: context,
              msg: 'msg_exit_app'.tr(),
              btnConfirmText: 'confirm'.tr(),
              btnCancelText: 'cancel'.tr(),
              onConfirm: () {
                result = true;
              });
          if (result) {
            return true;
          } else {
            return false;
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          closeSpinner();
        },
        child: Container(
          color: Colors.white,
          child: SafeArea(
            top: true,
            bottom: true,
            child: Scaffold(
              key: mainScaffoldKey,
              body: Column(
                children: [
                  // Container(
                  //   height: 55,
                  //   padding: const EdgeInsets.only(left: 24, right: 12),
                  //   child: Row(
                  //     children: [
                  //       SvgPicture.asset('images/logo.svg', width: 127, height: 20),
                  //       const Spacer(),
                  //       InkWell(
                  //         onTap: () {
                  //           CommonFunction.hideKeyboard(context);
                  //           closeSpinner();
                  //           if (!isFirstLoadRunning1) {
                  //             mainScaffoldKey.currentState?.openEndDrawer();
                  //           }
                  //         },
                  //         hoverColor: Colors.transparent,
                  //         splashColor: Colors.transparent,
                  //         highlightColor: Colors.transparent,
                  //         child: SvgPicture.asset(
                  //           'images/navi_icon_sidemenu.svg',
                  //           width: 40,
                  //           height: 40,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                        color: visibleLine ? const Color(ColorTheme.c_ededed) : Colors.white,
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
                              closeSpinner();
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
                                            crossFadeState: (isPTH ? isFirstLoadRunning1 : isFirstLoadRunning2) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                            duration: const Duration(milliseconds: 300),
                                            firstCurve: Curves.fastOutSlowIn,
                                            firstChild: Container(
                                              constraints: BoxConstraints(
                                                minHeight: getHeight,
                                              ),
                                              alignment: Alignment.center,
                                              child: const CircularProgressIndicator(
                                                color: Color(ColorTheme.c_19984b),
                                              ),
                                            ),
                                            secondCurve: Curves.fastOutSlowIn,
                                            secondChild: Column(
                                              children: [
                                                Column(children: [
                                                  const SizedBox(height: 20),
                                                  SizedBox(
                                                    height: isPTH ? 240 + expandedByPet : 205,
                                                    child: PageView.builder(
                                                      controller: pageController,
                                                      reverse: false,
                                                      physics: const BouncingScrollPhysics(
                                                        parent: AlwaysScrollableScrollPhysics(),
                                                      ),
                                                      itemCount: isPTH ? pthWalletInfoList.length + 1 : bscWalletInfoList.length + 1,
                                                      onPageChanged: (page) {
                                                        bool isReverse = currentPage > page;
                                                        if (isPTH) {
                                                          currentPage = page;
                                                          closeSpinner(forceSetState: true);
                                                          if (pthWalletInfoList.length > page) {
                                                            WalletInfo walletInfo = pthWalletInfoList.elementAt(page);
                                                            loadData(walletInfo: walletInfo, updateType: UpdateType.update);
                                                          }
                                                        } else {
                                                          currentPage = page;
                                                          closeSpinner(forceSetState: true);
                                                        }

                                                        int itemCount = isPTH ? pthWalletInfoList.length + 1 : bscWalletInfoList.length + 1;
                                                        if (itemCount < 10) {
                                                          return;
                                                        }

                                                        double maxScrollExtent = indicatorController.position.maxScrollExtent;
                                                        if (isReverse) {
                                                          if (itemCount - page > 6 && indicatorController.position.extentBefore > 0) {
                                                            double move = maxScrollExtent - (itemCount - page - 6) * 9;

                                                            indicatorController.animateTo(
                                                              move > maxScrollExtent ? maxScrollExtent : move,
                                                              duration: const Duration(milliseconds: 700),
                                                              curve: Curves.ease,
                                                            );
                                                          }
                                                        } else {
                                                          if (page > 5 && indicatorController.position.extentAfter > 0) {
                                                            double move = (page - 5) * 9;

                                                            indicatorController.animateTo(
                                                              move > maxScrollExtent ? maxScrollExtent : move,
                                                              duration: const Duration(milliseconds: 700),
                                                              curve: Curves.ease,
                                                            );
                                                          }
                                                        }
                                                      },
                                                      itemBuilder: (context, index) {
                                                        if (isPTH ? pthWalletInfoList.length == index : bscWalletInfoList.length == index) {
                                                          return Column(
                                                            children: [
                                                              Container(
                                                                width: double.infinity,
                                                                height: isPTH ? 186 : 151,
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
                                                                  decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(15),
                                                                      topRight: Radius.circular(15),
                                                                    ),
                                                                    color: Colors.white,
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      SvgPicture.asset(
                                                                        'images/icon_wallet.svg',
                                                                        width: 52,
                                                                        height: 52,
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 8,
                                                                      ),
                                                                      Text(
                                                                        (isPTH ? pthWalletInfoList.isNotEmpty : bscWalletInfoList.isNotEmpty) ? 'msg_connect_wallet'.tr() : 'msg_empty_wallet'.tr(),
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
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: double.infinity,
                                                                height: 48,
                                                                margin: const EdgeInsets.only(left: 23, right: 23),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Container(
                                                                        height: double.infinity,
                                                                        decoration: const BoxDecoration(
                                                                          borderRadius: BorderRadius.only(
                                                                            bottomLeft: Radius.circular(15),
                                                                          ),
                                                                          color: Color(0xff4b4b4b),
                                                                        ),
                                                                        child: Material(
                                                                          color: Colors.transparent,
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              CommonFunction.hideKeyboard(context);
                                                                              scrollController.jumpTo(0);
                                                                              scrollStreamController.add(0);
                                                                              showCreatedWallet();
                                                                            },
                                                                            hoverColor: Colors.transparent,
                                                                            splashColor: Colors.transparent,
                                                                            highlightColor: const Color(0xff767676),
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
                                                                              child: GestureDetector(
                                                                                onTap: goWalletCreate,
                                                                                behavior: HitTestBehavior.opaque,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    SvgPicture.asset(
                                                                                      'images/icon_plus_.svg',
                                                                                      width: 16,
                                                                                      height: 16,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 6,
                                                                                    ),
                                                                                    Text(
                                                                                      'wallet_create'.tr(),
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
                                                                    ),
                                                                    Expanded(
                                                                      child: Container(
                                                                        height: double.infinity,
                                                                        decoration: const BoxDecoration(
                                                                          borderRadius: BorderRadius.only(
                                                                            bottomRight: Radius.circular(15),
                                                                          ),
                                                                          color: Color(0xff4b4b4b),
                                                                        ),
                                                                        child: Material(
                                                                          color: Colors.transparent,
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              CommonFunction.hideKeyboard(context);
                                                                              goWalletImport();
                                                                            },
                                                                            hoverColor: Colors.transparent,
                                                                            splashColor: Colors.transparent,
                                                                            highlightColor: const Color(0xff767676),
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
                                                                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                                SvgPicture.asset(
                                                                                  'images/icon_prev.svg',
                                                                                  width: 16,
                                                                                  height: 16,
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 6,
                                                                                ),
                                                                                Text(
                                                                                  'wallet_import'.tr(),
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
                                                                              ]),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          return Stack(children: <Widget>[
                                                            Container(
                                                              width: double.infinity,
                                                              height: isPTH ? 186 + expandedByPet + 20  : 151,
                                                              margin: const EdgeInsets.only(left: 24, right: 24, top: 6),
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                color: Colors.white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Color(0x29000000),
                                                                    blurRadius: 6,
                                                                    spreadRadius: 0,
                                                                    offset: Offset(0.0, 0.0),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              children: [
                                                                Container(
                                                                  width: double.infinity,
                                                                  height: isPTH ? 186 + expandedByPet  : 151,
                                                                  margin: const EdgeInsets.only(left: 24, right: 24, top: 6),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.only(left: 18, right: 18, top: 16),
                                                                    decoration: const BoxDecoration(
                                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                      color: Colors.white,
                                                                    ),
                                                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(right: 5.0),
                                                                              child: Text(
                                                                                isPTH
                                                                                    ? pthWalletInfoList[index].name.isNotEmpty
                                                                                        ? pthWalletInfoList[index].name.tight()
                                                                                        : '${pthWalletInfoList[index].symbol} Wallet'
                                                                                    : bscWalletInfoList[index].name,
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(
                                                                                  height: 1.0,
                                                                                  fontSize: 15,
                                                                                  fontFamily: Setting.appFont,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Color(ColorTheme.defaultText),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 5.0),
                                                                          InkWell(
                                                                            onTap: () {
                                                                              CommonFunction.hideKeyboard(context);
                                                                              if (isPTH ? pthWalletInfoList[currentPage].openSpinner : bscWalletInfoList[currentPage].openSpinner) {
                                                                                closeSpinner();
                                                                                return;
                                                                              }
                                                                              showPinnedSetting();
                                                                            },
                                                                            hoverColor: Colors.transparent,
                                                                            splashColor: Colors.transparent,
                                                                            highlightColor: Colors.transparent,
                                                                            child: Container(
                                                                              width: 24,
                                                                              height: 24,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.all(
                                                                                  Radius.circular(12),
                                                                                ),
                                                                                color: (isPTH ? pthWalletInfoList[index].isMain : bscWalletInfoList[index].isMain)
                                                                                    ? const Color(ColorTheme.c_19984b)
                                                                                    : const Color(ColorTheme.c_ededed),
                                                                              ),
                                                                              child: SvgPicture.asset(
                                                                                (isPTH ? pthWalletInfoList[index].isMain : bscWalletInfoList[index].isMain)
                                                                                    ? 'images/icon_pin_pressed.svg'
                                                                                    : 'images/icon_pin.svg',
                                                                                width: 16,
                                                                                height: 16,
                                                                                fit: BoxFit.none,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width: 10,
                                                                          ),
                                                                          InkWell(
                                                                            onTap: () {
                                                                              CommonFunction.hideKeyboard(context);
                                                                              setState(() {
                                                                                if (isPTH) {
                                                                                  pthWalletInfoList[index].openSpinner = !pthWalletInfoList[index].openSpinner;
                                                                                } else {
                                                                                  bscWalletInfoList[index].openSpinner = !bscWalletInfoList[index].openSpinner;
                                                                                }
                                                                              });
                                                                            },
                                                                            hoverColor: Colors.transparent,
                                                                            splashColor: Colors.transparent,
                                                                            highlightColor: Colors.transparent,
                                                                            child: Container(
                                                                              width: 24,
                                                                              height: 24,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.all(
                                                                                  Radius.circular(12),
                                                                                ),
                                                                                color: (isPTH ? pthWalletInfoList[index].openSpinner : bscWalletInfoList[index].openSpinner)
                                                                                    ? const Color(0xffcccccc)
                                                                                    : const Color(ColorTheme.c_ededed),
                                                                              ),
                                                                              child: SvgPicture.asset(
                                                                                'images/icon_more.svg',
                                                                                width: 16,
                                                                                height: 16,
                                                                                fit: BoxFit.none,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      if (isPTH) ...{
                                                                        Container(
                                                                          height: 1,
                                                                          margin: const EdgeInsets.only(top: 7, bottom: 10),
                                                                          color: const Color(ColorTheme.c_ededed),
                                                                        ),
                                                                        Text(
                                                                          pthWalletInfoList[index].email,
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
                                                                      },
                                                                      Container(
                                                                        height: 42,
                                                                        margin: const EdgeInsets.only(top: 10),
                                                                        decoration: const BoxDecoration(
                                                                          borderRadius: BorderRadius.all(
                                                                            Radius.circular(5),
                                                                          ),
                                                                          color: Color(ColorTheme.c_ededed),
                                                                        ),
                                                                        child: Material(
                                                                          color: Colors.transparent,
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              CommonFunction.hideKeyboard(context);
                                                                              if (isPTH ? pthWalletInfoList[currentPage].openSpinner : bscWalletInfoList[currentPage].openSpinner) {
                                                                                closeSpinner();
                                                                                return;
                                                                              }
                                                                              CommonFunction.copyData(context, isPTH ? pthWalletInfoList[index].address : bscWalletInfoList[index].address,
                                                                                  toastMsg: 'copied'.tr());
                                                                            },
                                                                            hoverColor: Colors.transparent,
                                                                            splashColor: Colors.transparent,
                                                                            highlightColor: const Color(0xffcccccc),
                                                                            borderRadius: const BorderRadius.all(
                                                                              Radius.circular(5),
                                                                            ),
                                                                            child: Container(
                                                                              padding: const EdgeInsets.only(left: 12),
                                                                              decoration: const BoxDecoration(
                                                                                borderRadius: BorderRadius.all(
                                                                                  Radius.circular(5),
                                                                                ),
                                                                              ),
                                                                              child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                Expanded(
                                                                                  child: EllipsisTextView(
                                                                                    text: isPTH ? pthWalletInfoList[index].address : bscWalletInfoList[index].address,
                                                                                    style: const TextStyle(
                                                                                      height: 1.0,
                                                                                      fontSize: 13,
                                                                                      fontFamily: Setting.appFont,
                                                                                      fontWeight: FontWeight.w400,
                                                                                      color: Color(ColorTheme.defaultText),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  width: 34,
                                                                                  height: 34,
                                                                                  alignment: Alignment.center,
                                                                                  child: SvgPicture.asset(
                                                                                    'images/icon_copy.svg',
                                                                                    width: 14,
                                                                                    height: 14,
                                                                                    fit: BoxFit.none,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: const EdgeInsets.only(top: 18),
                                                                        padding: const EdgeInsets.only(left: 4, right: 4),
                                                                        child: Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                                                          Flexible(
                                                                            child: Text(
                                                                              CommonFunction.getDecimalFormatFormString(
                                                                                isPTH ? pthWalletInfoList.elementAt(index).balance : bscWalletInfoList.elementAt(index).bnbBalance,
                                                                                decimalDigits: 6,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(
                                                                                height: 1.0,
                                                                                fontSize: 24,
                                                                                fontFamily: Setting.appFont,
                                                                                fontWeight: FontWeight.w700,
                                                                                color: Color(ColorTheme.defaultText),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width: 5,
                                                                          ),
                                                                          Container(
                                                                            padding: const EdgeInsets.only(bottom: 1),
                                                                            child: Text(
                                                                              isPTH ? pthWalletInfoList[index].symbol : bscWalletInfoList[index].bnbSymbol,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(
                                                                                height: 1.0,
                                                                                fontSize: 18,
                                                                                fontFamily: Setting.appFont,
                                                                                fontWeight: FontWeight.w700,
                                                                                color: Color(ColorTheme.defaultText),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                      ),

                                                                      ExtendedPet(email: pthWalletInfoList[index].email,),

                                                                    ]),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double.infinity,
                                                                  height: 48,
                                                                  margin: const EdgeInsets.only(left: 23, right: 23),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Container(
                                                                          height: double.infinity,
                                                                          decoration: const BoxDecoration(
                                                                            borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(15),
                                                                            ),
                                                                            color: Color(ColorTheme.c_19984b),
                                                                          ),
                                                                          child: Material(
                                                                            color: Colors.transparent,
                                                                            child: InkWell(
                                                                              onTap: () {
                                                                                CommonFunction.hideKeyboard(context);
                                                                                if (isPTH ? pthWalletInfoList[currentPage].openSpinner : bscWalletInfoList[currentPage].openSpinner) {
                                                                                  closeSpinner();
                                                                                  return;
                                                                                }
                                                                                Navigator.pushNamed(
                                                                                  context,
                                                                                  Routes.depositPage,
                                                                                  arguments: {
                                                                                    'symbol': isPTH ? pthWalletInfoList[index].symbol : bscWalletInfoList[index].bnbSymbol,
                                                                                    'address': isPTH ? pthWalletInfoList[index].address : bscWalletInfoList[index].address,
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
                                                                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                                                                                ]),
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
                                                                            color: Color(ColorTheme.c_19984b),
                                                                          ),
                                                                          child: Material(
                                                                            color: Colors.transparent,
                                                                            child: InkWell(
                                                                              onTap: () async {
                                                                                CommonFunction.hideKeyboard(context);
                                                                                if (isPTH ? pthWalletInfoList[currentPage].openSpinner : bscWalletInfoList[currentPage].openSpinner) {
                                                                                  closeSpinner();
                                                                                  return;
                                                                                }

                                                                                OtpManager(context: context).checkWithdrawl(
                                                                                  isOtpCheck : true,
                                                                                    onSuccess: () async {
                                                                                      await doOtp(index);
                                                                                }, onFail: () async {
                                                                                      showPassword(
                                                                                        onSuccess: (value) async {
                                                                                          await doOtp(value!);
                                                                                        }, index:index);
                                                                                });


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
                                                                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                                                                                ]),
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
                                                            Positioned(
                                                              top: 53,
                                                              right: 42,
                                                              width: 160.0,
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(12),
                                                                      bottomLeft: Radius.circular(12),
                                                                    ),

                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Color(0x29000000),
                                                                        blurRadius: 6,
                                                                        spreadRadius: 0,
                                                                        offset: Offset(0.0, 0.0),
                                                                      ),
                                                                    ]),
                                                                child: AnimatedOpacity(
                                                                  opacity: (isPTH ? pthWalletInfoList[index].openSpinner : bscWalletInfoList[index].openSpinner) ? 1.0 : 0.0,
                                                                  duration: const Duration(milliseconds: 200),
                                                                  curve: Curves.fastOutSlowIn,
                                                                  child: Visibility(
                                                                    visible: isPTH ? pthWalletInfoList[index].openSpinner : bscWalletInfoList[index].openSpinner,
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
                                                                        itemCount: isPTH ? spinnerItems1.length : spinnerItems2.length,
                                                                        separatorBuilder: (context, index2) {
                                                                          return Container(
                                                                            height: 1.0,
                                                                            color: const Color(ColorTheme.c_ededed),
                                                                          );
                                                                        },
                                                                        itemBuilder: (context, index2) {
                                                                          WalletInfo? walletInfo;
                                                                          BSCWalletInfo? bSCWalletInfo;
                                                                          if (isPTH) {
                                                                            walletInfo = pthWalletInfoList.elementAt(index);
                                                                          } else {
                                                                            bSCWalletInfo = bscWalletInfoList.elementAt(index);
                                                                          }
                                                                          return Material(
                                                                            color: Colors.transparent,
                                                                            child: InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  if (isPTH) {
                                                                                    if (walletInfo != null) {
                                                                                      walletInfo.openSpinner = false;
                                                                                    }
                                                                                  } else {
                                                                                    if (bSCWalletInfo != null) {
                                                                                      bSCWalletInfo.openSpinner = false;
                                                                                    }
                                                                                  }
                                                                                });
                                                                                if (isPTH) {
                                                                                  if (index2 == 0) {
                                                                                    if (walletInfo != null) {
                                                                                      Navigator.of(context).pushNamed(
                                                                                        Routes.changeWalletPasswordPage,
                                                                                        arguments: ChangeWalletPasswordArguments(walletInfo: walletInfo),
                                                                                      );
                                                                                    }
                                                                                  } else if (index2 == 1) {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      barrierColor: const Color(ColorTheme.dim),
                                                                                      barrierDismissible: false,
                                                                                      builder: (BuildContext context) {
                                                                                        return KeyboardVisibilityBuilder(
                                                                                          builder: (context, isKeyboardVisible) {
                                                                                            if (isKeyboardUp != isKeyboardVisible) {
                                                                                              isKeyboardUp = isKeyboardVisible;
                                                                                              if (!isKeyboardUp) {
                                                                                                FocusScope.of(context).unfocus();
                                                                                              }
                                                                                            }
                                                                                            return InputDialog(
                                                                                              title: 'change_wallet_name'.tr(),
                                                                                              body: 'change_wallet_name_guide'.tr(),
                                                                                              hint: walletInfo != null ? walletInfo.name.tight() : '',
                                                                                              btnConfirmText: 'confirm'.tr(),
                                                                                              btnCancelText: 'cancel'.tr(),
                                                                                              onConfirm: (value) {
                                                                                                if (mounted) {
                                                                                                  if (value != null) {
                                                                                                    setState(() {
                                                                                                      if (walletInfo != null) {
                                                                                                        walletInfo.name = value;
                                                                                                        nameModify(walletInfo: walletInfo);
                                                                                                      }
                                                                                                    });
                                                                                                  }
                                                                                                }
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  } else if (index2 == 2) {
                                                                                    Navigator.of(context)
                                                                                        .pushNamed(
                                                                                      Routes.walletManagementPage,
                                                                                      arguments: WalletManagementPageArguments(walletType: WalletType.pth),
                                                                                    )
                                                                                        .then((value) => refreshData());
                                                                                  }else if( index2 == 3) {

                                                                                    Navigator.of(context)
                                                                                        .pushNamed(
                                                                                        Routes.inputPasswordPage,
                                                                                        arguments: {"walletInfo": walletInfo}
                                                                                    );

                                                                                  }

                                                                                } else {
                                                                                  if (index2 == 0) {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      barrierColor: const Color(ColorTheme.dim),
                                                                                      barrierDismissible: false,
                                                                                      builder: (BuildContext context) => InputDialog(
                                                                                        title: 'change_wallet_name'.tr(),
                                                                                        body: 'change_wallet_name_guide'.tr(),
                                                                                        hint: bscWalletInfoList.elementAt(index).name.tight(),
                                                                                        btnConfirmText: 'confirm'.tr(),
                                                                                        btnCancelText: 'cancel'.tr(),
                                                                                        onConfirm: (value) {
                                                                                          if (mounted) {
                                                                                            if (value != null) {
                                                                                              setState(() {
                                                                                                if (bSCWalletInfo != null) {
                                                                                                  bSCWalletInfo.name = value;
                                                                                                  // bSCNameModify(bscWalletInfo: bSCWalletInfo);
                                                                                                }
                                                                                              });
                                                                                            }
                                                                                          }
                                                                                        },
                                                                                      ),
                                                                                    );
                                                                                  } else if (index2 == 1) {
                                                                                    Navigator.of(context)
                                                                                        .pushNamed(
                                                                                      Routes.walletManagementPage,
                                                                                      arguments: WalletManagementPageArguments(walletType: WalletType.bsc),
                                                                                    )
                                                                                        .then((value) => refreshData());
                                                                                  }
                                                                                }
                                                                              },
                                                                              hoverColor: Colors.transparent,
                                                                              splashColor: Colors.transparent,
                                                                              highlightColor: const Color(0xfff3f3f3),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: index2 == 0 ? const Radius.circular(12) : const Radius.circular(0),
                                                                                bottomLeft: index2 == (isPTH ? spinnerItems1.length - 1 : spinnerItems2.length - 1)
                                                                                    ? const Radius.circular(12)
                                                                                    : const Radius.circular(0),
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
                                                                                          isPTH ? spinnerItems1[index2].tr() : spinnerItems2[index2].tr(),
                                                                                          style: const TextStyle(
                                                                                            fontSize: 14,
                                                                                            fontFamily: Setting.appFont,
                                                                                            fontWeight: FontWeight.w400,
                                                                                            color: Color(ColorTheme.defaultText),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ]),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ]);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  if (isPTH ? pthWalletInfoList.isNotEmpty : bscWalletInfoList.isNotEmpty) ...{
                                                    Container(
                                                      width: 98,
                                                      height: 20,
                                                      padding: const EdgeInsets.only(bottom: 2),
                                                      alignment: Alignment.bottomCenter,
                                                      child: SingleChildScrollView(
                                                        controller: indicatorController,
                                                        scrollDirection: Axis.horizontal,
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        child: SmoothPageIndicator(
                                                          controller: pageController!,
                                                          count: isPTH ? pthWalletInfoList.length + 1 : bscWalletInfoList.length + 1,
                                                          effect: const ExpandingDotsEffect(
                                                            expansionFactor: 4,
                                                            spacing: 5,
                                                            dotHeight: 4.0,
                                                            dotWidth: 4.0,
                                                            activeDotColor: Color(ColorTheme.c_19984b),
                                                            dotColor: Color(0xffdbdbdb),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  } else ...{
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                  },
                                                ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                body: LayoutBuilder(
                                  builder: (BuildContext context, BoxConstraints constraints) {
                                    bottomListH = constraints.maxHeight;
                                    return NotificationListener<ScrollUpdateNotification>(
                                      onNotification: (notification) {
                                        scrollPixels = notification.metrics.pixels;
                                        if (isMoreItemList.elementAt(currentPage) && !isMoreLoadingItemList[currentPage] && isFirstLoadRunning1 == false && notification.metrics.extentAfter < 1000) {
                                          isMoreLoadingItemList[currentPage] = true;
                                          loadData(walletInfo: pthWalletInfoList.elementAt(currentPage), updateType: UpdateType.add);
                                          return false;
                                        }
                                        return true;
                                      },
                                      child: Column(
                                        children: [
                                          Stack(
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
                                                  isPTH ? 'transaction_history'.tr() : 'property'.tr(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    height: 1.0,
                                                    fontSize: 15,
                                                    fontFamily: Setting.appFont,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(ColorTheme.defaultText),
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
                                                    color: visibleLine ? const Color(ColorTheme.c_ededed) : Colors.white,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: AnimatedCrossFade(
                                              crossFadeState: viewList(),
                                              duration: const Duration(milliseconds: 10),
                                              firstCurve: Curves.easeInOut,
                                              firstChild: Container(
                                                height: bottomListH,
                                                margin: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
                                                padding: const EdgeInsets.only(bottom: 50),
                                                alignment: Alignment.center,
                                                child: const CircularProgressIndicator(
                                                  color: Color(ColorTheme.c_19984b),
                                                ),
                                              ),
                                              secondCurve: Curves.fastOutSlowIn,
                                              secondChild: RefreshIndicator(
                                                color: const Color(ColorTheme.appColor),
                                                onRefresh: () async {
                                                  refreshData();
                                                  await Future.delayed(const Duration(seconds: 1));
                                                },
                                                child: wList(),
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
        ),
      ),
    );
  }

  //
  // ? CrossFadeState.showFirst
  //     : CrossFadeState.showSecond,

  CrossFadeState viewList() {
    bool result = false;
    if (isFirstLoadRunning1BottomList.length - 1 >= currentPage) {
      if (isPTH) {
        if (isFirstLoadRunning1BottomList != null && isFirstLoadRunning1BottomList.isNotEmpty) {
          if (isFirstLoadRunning1BottomList.length < currentPage) {
            result = true;
          }

          if (isFirstLoadRunning1BottomList[currentPage]) {
            result = true;
          }
        }
      } else {
        if (isFirstLoadRunning2BottomList != null && isFirstLoadRunning2BottomList.isNotEmpty) {
          if (isFirstLoadRunning2BottomList.length < currentPage) {
            result = true;
          }

          if (isFirstLoadRunning2BottomList[currentPage]) {
            result = true;
          }
        }
      }
    } else {
      currentPage = isPTH ? pthWalletInfoList.length : bscWalletInfoList.length;

      pageController?.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      result = false;
    }

    if (result) {
      return CrossFadeState.showFirst;
    } else {
      return CrossFadeState.showSecond;
    }
  }

  Widget wList() {
    if (isPTH) {
      if (pthWalletInfoList.length > currentPage) {
        List<TransactionInfo>? transactionList = pthWalletInfoList.elementAt(currentPage).transactionInfoList;
        if (transactionList != null && transactionList.isNotEmpty) {
          return Container(
            height: bottomListH,
            margin: const EdgeInsets.only(left: 24, right: 24),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 12),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              shrinkWrap: true,
              itemCount:
              pthWalletInfoList.isNotEmpty && pthWalletInfoList.elementAt(currentPage).transactionInfoList != null ? pthWalletInfoList.elementAt(currentPage).transactionInfoList!.length : 0,
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 10,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 1,
                      margin: const EdgeInsets.only(left: 7.5),
                      color: const Color(ColorTheme.c_ededed),
                      alignment: Alignment.center,
                    ),
                  ]),
                );
              },
              itemBuilder: (context, index) {
                if (pthWalletInfoList.elementAt(currentPage).transactionInfoList != null) {
                  TransactionInfo? preTransactionInfo;
                  TransactionInfo transactionInfo = pthWalletInfoList.elementAt(currentPage).transactionInfoList!.elementAt(index);
                  if (index > 0 && pthWalletInfoList.elementAt(currentPage).transactionInfoList!.length > 1) {
                    preTransactionInfo = pthWalletInfoList.elementAt(currentPage).transactionInfoList!.elementAt(index - 1);
                  }
                  return InkWell(
                    onTap: () {
                      CommonFunction.hideKeyboard(context);
                      if (pthWalletInfoList[currentPage].openSpinner) {
                        closeSpinner();
                        return;
                      }
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
                              if (index < 1 ||
                                  CommonFunction.getTimeFormat('yyyy.MM.dd', preTransactionInfo != null ? preTransactionInfo.timestamp : transactionInfo.timestamp) !=
                                      CommonFunction.getTimeFormat('yyyy.MM.dd', transactionInfo.timestamp)) ...{
                                Container(
                                  width: 1,
                                  height: 5,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: index == 0 ? Colors.white : const Color(ColorTheme.c_ededed),
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
                                    color: Color(ColorTheme.c_19984b),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: const Color(ColorTheme.c_ededed),
                                  alignment: Alignment.center,
                                ),
                              },
                              Container(
                                width: 1,
                                height: 78,
                                margin: const EdgeInsets.only(right: 4),
                                color: const Color(ColorTheme.c_ededed),
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index < 1 ||
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
                                      color: Color(ColorTheme.defaultText),
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
                                      color: Color(ColorTheme.c_ededed),
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
                                        color: Color(ColorTheme.defaultText),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: EllipsisTextView(
                                      text: transactionInfo.transactionType == TransactionType.deposit ? transactionInfo.from : transactionInfo.to,
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
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(9),
                                      ),
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
                                      color: Color(ColorTheme.defaultText),
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
                                      color: Color(ColorTheme.defaultText),
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
              },
            ),
          );
        } else {
          if (!isLoadRunning) {
            return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  height: bottomListH,
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
            );
          } else {
            return Container();
          }
        }
      } else {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              height: bottomListH,
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
        );
      }
    } else {
      if (bscWalletInfoList.length > currentPage) {
        BSCWalletInfo currentWalletInfo = bscWalletInfoList.elementAt(currentPage);
        List<WalletInfo> bscWalletList = [];
        WalletInfo bnbWalletInfo = WalletInfo(
          idx: currentWalletInfo.idx,
          name: currentWalletInfo.name,
          email: '',
          address: currentWalletInfo.address,
          isMain: currentWalletInfo.isMain,
          balance: currentWalletInfo.bnbBalance,
          symbol: currentWalletInfo.bnbSymbol,
          openSpinner: currentWalletInfo.openSpinner,
        );
        WalletInfo bPTHWalletInfo = WalletInfo(
          idx: currentWalletInfo.idx,
          name: currentWalletInfo.name,
          email: '',
          address: currentWalletInfo.address,
          isMain: currentWalletInfo.isMain,
          balance: currentWalletInfo.balance,
          symbol: currentWalletInfo.bPthSymbol,
          openSpinner: currentWalletInfo.openSpinner,
        );

        bscWalletList.add(bnbWalletInfo);
        bscWalletList.add(bPTHWalletInfo);
        return Container(
          height: bottomListH,
          margin: const EdgeInsets.only(left: 24, right: 24),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 5),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            shrinkWrap: true,
            itemCount: bscWalletList.length,
            itemBuilder: (context, index) {
              if (bscWalletList.isNotEmpty) {
                WalletInfo walletInfo = bscWalletList.elementAt(index);
                return InkWell(
                  onTap: () {
                    CommonFunction.hideKeyboard(context);
                    if (bscWalletInfoList.elementAt(currentPage).openSpinner) {
                      closeSpinner();
                      return;
                    }
                    Navigator.of(context).pushNamed(
                      Routes.propertyDetailPage,
                      arguments: PropertyDetailPageArguments(
                        walletType: WalletType.bsc,
                        walletInfo: walletInfo,
                        bscWalletInfo: currentWalletInfo,
                      ),
                    );
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.only(left: 5, right: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            color: Color(ColorTheme.c_dbdbdb),
                          ),
                          child: SvgPicture.asset(
                            'images/icon_token_default.svg',
                            width: 17,
                            height: 19,
                            fit: BoxFit.none,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          walletInfo.symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.0,
                            fontSize: 15,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w500,
                            color: Color(ColorTheme.defaultText),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              CommonFunction.getDecimalFormatFormString(walletInfo.balance),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 1.0,
                                fontSize: 14,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.defaultText),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        );
      } else {
        return Container(
          height: bottomListH,
          margin: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
          padding: const EdgeInsets.only(bottom: 50),
          alignment: Alignment.center,
          child: Text(
            'msg_empty_property'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.4,
              fontSize: 14,
              fontFamily: Setting.appFont,
              fontWeight: FontWeight.w400,
              color: Color(0xff767676),
            ),
          ),
        );
      }
    }
  }

  // TODO: refreshData()
  Future<void> refreshData({bool isImportWallet = false}) async {
    if (isPTH) {
      getWalletList().whenComplete(() {
        if (pthWalletInfoList.length > currentPage) {
          WalletInfo walletInfo = pthWalletInfoList.elementAt(currentPage);
          isLoadRunning = true;
          loadData(walletInfo: walletInfo, updateType: UpdateType.update);
        }
        if (isImportWallet) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (indicatorController.hasClients) {
              indicatorController.jumpTo(indicatorController.position.maxScrollExtent);
            }
          });
        }
      });
    }

    // else {
    //   getBSCWalletList();
    // }
  }

  // TODO: loadData()
  Future<void> loadData({required WalletInfo walletInfo, required UpdateType updateType}) async {
    if (updateType == UpdateType.update) {
      isFirstLoadRunning1BottomList[currentPage] = true;
      await transferList(walletInfo: walletInfo, page: currentPage, updateType: UpdateType.update);
    } else {
      await transferList(walletInfo: walletInfo, page: currentPage, updateType: UpdateType.add);
    }
  }

  // PTH
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
        if (pthWalletInfoList != walletList) {
          setState(() {
            pthWalletInfoList = walletList;
          });
        }
        if (mounted) {
          Provider.of<WalletProvider>(context, listen: false).setWalletInfoList(pthWalletInfoList: walletList);
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning1 = false;
      isFirstLoadRunning1BottomList.clear();
      isFirstLoadRunning1BottomList.add(false);
      if (pthWalletInfoList.isNotEmpty) {
        for (int idx = 0; idx < pthWalletInfoList.length; idx++) {
          isFirstLoadRunning1BottomList.add(false);
          lastIdxList.add(-1);
          isMoreItemList.add(true);
          isMoreLoadingItemList.add(false);
        }
      }
    }
  }

  Future<void> transferList({required WalletInfo walletInfo, required int page, required UpdateType updateType}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      return;
    }

    int lastIdx = -1;
    if (updateType != UpdateType.update) {
      if (walletInfo.transactionInfoList != null && walletInfo.transactionInfoList!.isNotEmpty) {
        TransactionInfo lastTransactionInfo = walletInfo.transactionInfoList!.elementAt(walletInfo.transactionInfoList!.length - 1);
        lastIdx = lastTransactionInfo.idx;
      }
    } else {
      lastIdxList[page] = -1;
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      json = await manager.transferList(walletIdx: walletInfo.idx, lastIdx: lastIdx);
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        var result = json[ApiParamKey.result];
        if (result != null && result is List) {
          List<TransactionInfo> list = result.map((json) => TransactionInfo.fromJson(json, walletInfo.address)).toList();
          if (updateType == UpdateType.update) {
            if (walletInfo.transactionInfoList != null) {
              walletInfo.transactionInfoList!.clear();
            } else {
              walletInfo.transactionInfoList = [];
            }
          }

          if (list != null && list.isNotEmpty) {
            int tempLastIdx = list.elementAt(list.length - 1).idx;
            if (updateType == UpdateType.update) {
              if (tempLastIdx > -1) {
                lastIdxList[page] = tempLastIdx;
              } else {
                isMoreItemList[page] = false;
              }
            } else {
              if (tempLastIdx > -1 && tempLastIdx < lastIdx) {
                lastIdxList[page] = tempLastIdx;
              } else {
                isMoreItemList[page] = false;
              }
            }

            if (mounted) {
              setState(() {
                walletInfo.transactionInfoList!.addAll(list);
              });
            }
          } else {
            isMoreItemList[page] = false;
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
      isLoadRunning = false;
      isFirstLoadRunning1BottomList[page] = false;
      isMoreLoadingItemList[page] = false;
      setState(() {});
    }
  }

  Future<void> nameModify({required WalletInfo walletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning1 = false;
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
        if (mounted) {
          CommonFunction.showToast(context, 'msg_success_change_wallet_name'.tr());
        }
        getWalletList().whenComplete(() {
          if (pthWalletInfoList.length > currentPage) {
            WalletInfo walletInfo = pthWalletInfoList.elementAt(currentPage);
            loadData(walletInfo: walletInfo, updateType: UpdateType.update);
          }
        });
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFirstLoadRunning1 = false;
    }
  }

  Future<void> setMain({required WalletInfo walletInfo}) async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      isFirstLoadRunning1 = false;
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
      isFirstLoadRunning1 = false;
    }
  }

  // BNC
  // Future<void> getBSCWalletList() async {
  //   String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
  //   if (sessionCode.isEmpty) {
  //     return;
  //   }
  //
  //   var manager = ApiManagerBPTHWallet();
  //   dynamic json;
  //   try {
  //     isFirstLoadRunning2 = true;
  //
  //     json = await manager.list();
  //     final status = json[ApiParamKey.status];
  //     if (status == ApiParamKey.success) {
  //       var result = json[ApiParamKey.result];
  //       List<BSCWalletInfo> walletList = result.map<BSCWalletInfo>((json) => BSCWalletInfo.fromJson(json)).toList();
  //       if (bscWalletInfoList != walletList) {
  //         setState(() {
  //           bscWalletInfoList = walletList;
  //         });
  //
  //         if (mounted) {
  //           Provider.of<WalletProvider>(context, listen: false).setBSCWalletInfoList(bscWalletInfoList: bscWalletInfoList);
  //         }
  //       }
  //     } else {
  //       if (context.mounted) {
  //         await CheckResponse.checkErrorResponse(context, json);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   isFirstLoadRunning2 = false;
  //   isFirstLoadRunning2BottomList.clear();
  //   isFirstLoadRunning2BottomList.add(false);
  //   if (bscWalletInfoList.isNotEmpty) {
  //     for (int idx = 0; idx < bscWalletInfoList.length; idx++) {
  //       isFirstLoadRunning2BottomList.add(false);
  //     }
  //   }
  // }

  // Future<void> bSCNameModify({required BSCWalletInfo bscWalletInfo}) async {
  //   String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
  //   if (sessionCode.isEmpty) {
  //     isFirstLoadRunning2 = false;
  //     return;
  //   }
  //
  //   var manager = ApiManagerBPTHWallet();
  //   dynamic json;
  //   try {
  //     json = await manager.nameModify(
  //       walletIdx: bscWalletInfo.idx,
  //       name: bscWalletInfo.name,
  //     );
  //     final status = json[ApiParamKey.status];
  //     if (status == ApiParamKey.success) {
  //       if (mounted) {
  //         CommonFunction.showToast(context, 'msg_success_change_wallet_name'.tr());
  //       }
  //       getBSCWalletList();
  //     } else {
  //       if (context.mounted) {
  //         await CheckResponse.checkErrorResponse(context, json);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     isFirstLoadRunning2 = false;
  //   }
  // }

  // Future<void> setMainBSC({required BSCWalletInfo bscWalletInfo}) async {
  //   String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
  //   if (sessionCode.isEmpty) {
  //     isFirstLoadRunning2 = false;
  //     return;
  //   }
  //
  //   var manager = ApiManagerBPTHWallet();
  //   dynamic json;
  //   try {
  //     json = await manager.setMain(walletIdx: bscWalletInfo.idx);
  //     final status = json[ApiParamKey.status];
  //     if (status == ApiParamKey.success) {
  //       refreshData();
  //     } else {
  //       if (context.mounted) {
  //         await CheckResponse.checkErrorResponse(context, json);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     isFirstLoadRunning2 = false;
  //   }
  // }

  // Future<void> addBPTH() async {
  //   if (isAddingBPTH) {
  //     return;
  //   }
  //
  //   isAddingBPTH = true;
  //
  //   var manager = ApiManagerBPTHWallet();
  //
  //   dynamic json;
  //
  //   try {
  //     json = await manager.add();
  //
  //     final status = json[ApiParamKey.status];
  //     if (status == ApiParamKey.success) {
  //       if (mounted) {
  //         CommonFunction.showToast(context, 'msg_success_create_wallet'.tr());
  //         getBSCWalletList();
  //       }
  //     } else {
  //       if (context.mounted) {
  //         await CheckResponse.checkErrorResponse(context, json);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //
  //   isAddingBPTH = false;
  // }

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
                                    print("result : ${result}");
                                    if (result == 0  ) {

                                      if(mounted) {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pushNamed(Routes.withdrawalPasswordPage, arguments: {"type": 1})
                                            .whenComplete(() async {
                                          onSuccess.call(index != null ? index : null );
                                      });

                                      }
                                    }else if(result == 1) {
                                      if(mounted) {
                                        Navigator.of(context).pop();
                                      }
                                      onSuccess.call(index != null ? index : null );
                                    } else {
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

  Future<void> doOtp(int index) async {
    var result = await Navigator.pushNamed(
      context,
      Routes.withdrawalPage,
      arguments: {
        'symbol': isPTH ? WalletType.pth.symbol : BSCWalletType.bnb.symbol,
        'wallet_info': isPTH ? pthWalletInfoList[index] : bscWalletInfoList[index],
      },
    );
    if (result != null && result is bool) {
      if (result) {
        refreshData();
      }
    }
  }
}

class ExtendedPet extends StatefulWidget {
  final String email;

  const ExtendedPet({
    super.key,
    required this.email,
  });

  @override
  State<ExtendedPet> createState() => _ExtendedPetState();
}

class _ExtendedPetState extends State<ExtendedPet> {
  bool isLoad = false;
  String _amount = "";
  String _enablePoint = "";


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loadData();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:  isLoad,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 6),
            Text("${"swap.point_enable_change_title".tr()} : $_enablePoint ${Setting.appSymbol}",
                                maxLines: 1,
                                 textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  height: 1.0 ,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.17,
                                  color: Color(ColorTheme.c_767676),
                                )
                              ),
            const SizedBox(height:6),
            Container(
              width: double.infinity,
              height: 1,
              color: const Color(ColorTheme.c_ededed),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Text("pet_pth_title".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.0 ,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.17,
                      color: Color(ColorTheme.c_19984b),
                    )
                ),
                Expanded(child:
                Text("${"total".tr()} $_amount ${Setting.appSymbol}",
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.0 ,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.18,
                      color: Color(ColorTheme.c_19984b),
                    )
                ),
                )
              ],
            ),
            const SizedBox(height:11),

          ],
        ),
      ),
    );
  }

  Future<void> loadData() async {
    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      isLoad = false;
      json = await manager.getPetBalance(email: widget.email);

      final String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {

        final amount = json["pet_amount"];
        final enablePoint = json["point_swap_enable_amount"];

        setState(() {
          isLoad = true;
          _amount = amount.toString();
          _enablePoint = enablePoint.toString();
        });
      }

    }catch (e) {
      if (context.mounted) {
        CheckResponse.checkErrorResponse(context, json);
      }
    }

  }
}
