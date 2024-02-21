import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/main_tab_type.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/provider/push_notification_provider.dart';
import 'package:plastichero_app/provider/share_provider.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/info_dialog.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/page/setting_page.dart';
import 'package:plastichero_app/ui/page/wallet_main_page.dart';
import 'package:plastichero_app/ui/widget/swap/swap_main.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPageArguments {
  final int? launch;

  MainPageArguments({this.launch});
}

// ignore: must_be_immutable
class MainPage extends StatefulWidget {
  static const tag = 'MainPage';
  static const routeName = 'main';

  MainPage({Key? key, this.launch}) : super(key: key);

  int? launch;

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  //static const tag = '_MainPageState';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext? mainContext;

  PushNotificationProvider? pushNotificationProvider;
  ShareProvider? shareProvider;

  late TabController _tabController;
  int _tabIndex = 0;

  final String _url = Setting.isTest ? Setting.domainDev : Setting.domain;

  final GlobalKey webViewKey1 = GlobalKey();
  final GlobalKey webViewKey2 = GlobalKey();
  final GlobalKey webViewKey3 = GlobalKey();
  final GlobalKey webViewKey4 = GlobalKey();

  String _urlRequest1 = "";
  String _urlRequest2 = "";
  String _urlRequest3 = "";

  // String _urlRequest4 = "";

  InAppWebViewController? webViewController1;
  InAppWebViewController? webViewController2;
  InAppWebViewController? webViewController3;
  InAppWebViewController? webViewController4;

  bool _isLoaded = false;

  String _code = "";
  DateTime? backBtnPressedTime;

  late final LoadingDialog loadingDialog;

  late PullToRefreshController pullToRefreshController;

  MyinfoProvider? myInfoPovider;


  void refreshPages() {
    webViewController1?.reload();
    webViewController2?.reload();
    webViewController3?.reload();
    webViewController4?.reload();


  }
  void shareListener() {
    if (shareProvider != null) {
      String data = shareProvider!.getShareData();
      if (data.isNotEmpty) {}
    }
  }

  Future<void> setCode() async {
    final code =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";

    String locale = ui.window.locale.languageCode;
    final lang = await CommonFunction.getPreferencesString(PreferenceKey.lang) ?? '';
    if (lang != null && lang!.isNotEmpty) {
      if (lang == 'en') {
        locale = lang;
      } else if (lang == 'ko' || lang == 'ko_KR') {
        locale = "ko";
      }
    }

    Debug.log("locale", locale);

    setState(() {
      _urlRequest1 = "$_url/mobile/index.php?lang=$locale&code=$code";
      _urlRequest2 = "$_url/mobile/member/point.php?lang=$locale&code=$code";
      _urlRequest3 = "$_url/mobile/gift/list.php?lang=$locale&code=$code";
      // _urlRequest4 = "$_url/?code=$code";
      _code = code;
      _isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: Setting.isUseWallet ? 5 : 4, vsync: this, animationDuration: Duration.zero);
    WidgetsBinding.instance.addObserver(this);
    loadingDialog = LoadingDialog(context: context);

    shareProvider ??= Provider.of<ShareProvider>(context, listen: false)
      ..addListener(shareListener);
    myInfoPovider = Provider.of<MyinfoProvider>(context, listen: false)
    ..addListener(refreshPages);

    pushNotificationProvider ??=
        Provider.of<PushNotificationProvider>(context, listen: false)
          ..addListener(() {
            String data = pushNotificationProvider!.getPushData;
            if (data.isNotEmpty) {
              pushProcessing(data);
            }
          });



    CommonFunction.getPreferencesBoolean(PreferenceKey.useLock).then((value) {
      value ??= false;
      AppLock.of(context)!.setEnabled(value);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      pullToRefreshController = PullToRefreshController(
          onRefresh: _refreshWebView
      );
      setCode();
      if (Common.pushData.isNotEmpty) {
        String data = Common.pushData;
        Common.pushData = '';
        pushProcessing(data);
      } else {
        String data =
            Provider.of<PushNotificationProvider>(context, listen: false)
                .getPushData;
        if (data.isNotEmpty) {
          pushProcessing(data);
        }
      }

      if (Common.shareData.isNotEmpty) {
        // String data = Common.shareData;
        Common.shareData = '';
      } else {
        String data = shareProvider!.getShareData();
        if (data.isNotEmpty) {}
      }
    });

    //TODO: deleteMe
    // Future.delayed(const Duration(milliseconds: 500), () {
    //   Navigator.of(context).pushNamed(Routes.welcomePage).then( (value) {
    //
    //     if(value == true) {
    //       tapTab(2);
    //       print("true");
    //     }else {
    //       print("false");
    //     }
    //   });
    // });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {}
  }

  Future<void> pushProcessing(String? data) async {
    if (data != null) {
      dynamic messageData;
      try {
        messageData = jsonDecode(data);
      } catch (e) {
        messageData = null;
      }

      if (messageData != null) {
        if (messageData.containsKey(ApiParamKey.launch)) {
          String? launch = messageData[ApiParamKey.launch];
          if (launch != null) {
            if (launch == PushLaunchType.wallet.value) {
            } else if (launch == PushLaunchType.notice.value) {
            } else if (launch == PushLaunchType.qna.value) {}
          }
        }
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    shareProvider?.removeListener(shareListener);
    shareProvider = null;
    myInfoPovider?.removeListener(refreshPages);
    myInfoPovider = null;
    super.dispose();
  }

  Future<bool> backButtonAction() async {
    DateTime currentTime = DateTime.now();

    bool backBtn = false;

    if (backBtnPressedTime == null) {
      backBtn = true;
    } else if (currentTime.difference(backBtnPressedTime!) >
        const Duration(seconds: 2)) {
      backBtn = true;
    }

    if (backBtn) {
      backBtnPressedTime = currentTime;
      CommonFunction.showToast(context, 'back_button_msg'.tr());
      return false;
    }

    await FlutterExitApp.exitApp(iosForceExit: Platform.isIOS);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    pushNotificationProvider ??=
        Provider.of<PushNotificationProvider>(context, listen: false)
          ..addListener(() {
            String data = pushNotificationProvider!.getPushData;
            if (data.isNotEmpty) {
              pushProcessing(data);
            }
          });
    // var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        switch (_tabIndex) {
          case 0:
            if (await webViewController1?.canGoBack() ?? false) {
              webViewController1?.goBack();
              return false;
            }
            return await backButtonAction();
          case 1:
            if (await webViewController2?.canGoBack() ?? false) {
              webViewController2?.goBack();
              return false;
            }
            return await backButtonAction();
          case 2:
            if(!Setting.isUseWallet) {
              if (await webViewController3?.canGoBack() ?? false) {
                webViewController3?.goBack();
                return false;
              }
              return await backButtonAction();
            }else {
              return await backButtonAction();
            }
          case 3:
            if(Setting.isUseWallet) {
              if (await webViewController3?.canGoBack() ?? false) {
                webViewController3?.goBack();
                return false;
              }
              return await backButtonAction();
            }else {
              return await backButtonAction();
            }
          default:
            return await backButtonAction();
        }
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: false,
              extendBody: true,
              appBar: DefaultToolbar(
                backgroundColor: const Color(ColorTheme.appColor),
                leadingWidth: 24,
                title: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: SvgPicture.asset("images/logo_white.svg",
                        width: 127, height: 20)),
                centerTitle: false,
                isBackButton: false,
                toolbarHeight: 100.0,
                actions: [
                  //TODO: swap 기능 적용할것
                  if (Setting.isUseSwap)
                    GestureDetector(
                      onTap: showSwap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Row(
                          children: [
                            SvgPicture.asset("images/icon_swap.svg",
                                width: 20, height: 20),
                            const SizedBox(width: 2),
                            Text("swap.title".tr(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.0 ,
                                                  fontFamily: Setting.appFont,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                )
                                              ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
              // endDrawer: Drawer(
              //   width: width,
              //   child:  const SettingPage(),
              // ),
              body: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Theme(
                    data: ThemeData(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: _isLoaded
                        ?  DefaultTabController(
                            length: Setting.isUseWallet ? 5 : 4,
                            initialIndex: _tabIndex,
                            child: Column(
                              children: [
                                Expanded(
                                    child: TabBarView(
                                  controller: _tabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    RefreshIndicator(
                                      onRefresh: _refreshWebView, 
                                      child:  InAppWebView(
                                          key: webViewKey1,
                                          // initialUrlRequest: URLRequest(url: WebUri("${_url}/?code=$_code")),
                                          initialUrlRequest: URLRequest(
                                              url: WebUri(_urlRequest1)),
                                          initialSettings:
                                              InAppWebViewSettings(
                                            transparentBackground: true,
                                            javaScriptEnabled: true,
                                            useHybridComposition: true,
                                            // javaScriptCanOpenWindowsAutomatically: true,
                                            // supportMultipleWindows: true,
                                            applicationNameForUserAgent:
                                                "PlasticheroApp", // 지갑앱에서도 동일하게 사용하면 됩니다.
                                          ),
                                          pullToRefreshController: pullToRefreshController,
                                          onWebViewCreated: (controller) {
                                            webViewController1 =
                                                controller;
                                            addAppJavascriptHandler(
                                                controller);
                                          },
                                        onLoadStop: (controller, url) async{
                                            pullToRefreshController.endRefreshing();
                                        },

                                        ),

                                    ),
                                    InAppWebView(
                                      key: webViewKey2,
                                      // initialUrlRequest: URLRequest(url: WebUri("${_url}/?code=$_code")),
                                      initialUrlRequest: URLRequest(
                                          url: WebUri(_urlRequest2)),
                                      initialSettings:
                                          InAppWebViewSettings(
                                        transparentBackground: true,
                                        javaScriptEnabled: true,
                                        // javaScriptCanOpenWindowsAutomatically: true,
                                        // supportMultipleWindows: true,
                                            useHybridComposition: true,
                                        applicationNameForUserAgent:
                                            "PlasticheroApp", // 지갑앱에서도 동일하게 사용하면 됩니다.
                                      ),
                                      pullToRefreshController: pullToRefreshController,
                                      onWebViewCreated: (controller) {
                                        webViewController2 = controller;
                                        addAppJavascriptHandler(
                                            controller);
                                      },
                                      onLoadStop: (controller, url) async{
                                        pullToRefreshController.endRefreshing();
                                      },
                                    ),
                                    if(Setting.isUseWallet)
                                    const WalletMainPage(),
                                    InAppWebView(
                                      key: webViewKey3,
                                      // initialUrlRequest: URLRequest(url: WebUri("${_url}/?code=$_code")),
                                      initialUrlRequest: URLRequest(
                                          url: WebUri(_urlRequest3)),
                                      initialSettings:
                                          InAppWebViewSettings(
                                        transparentBackground: true,
                                        javaScriptEnabled: true,
                                            useHybridComposition: true,
                                        // javaScriptCanOpenWindowsAutomatically: true,
                                        // supportMultipleWindows: true,
                                        applicationNameForUserAgent:
                                            "PlasticheroApp", // 지갑앱에서도 동일하게 사용하면 됩니다.
                                      ),
                                      pullToRefreshController: pullToRefreshController,
                                      onWebViewCreated: (controller) {
                                        webViewController3 = controller;
                                        addAppJavascriptHandler(
                                            controller);
                                      },
                                      onLoadStop: (controller, url) async{
                                        pullToRefreshController.endRefreshing();
                                      },
                                    ),
                                    SettingPage(
                                      goPoint: () {
                                        setState(() {
                                          _tabIndex = 1;
                                          _tabController.index = 1;
                                        });
                                      },
                                      goGift: () {
                                        if(Setting.isUseWallet) {
                                          setState(() {
                                            _tabIndex = 3;
                                            _tabController.index = 3;
                                          });
                                        }else {
                                          setState(() {
                                            _tabIndex = 2;
                                            _tabController.index = 2;
                                          });
                                        }
                                      },
                                      goHome: () {
                                        setState(() {
                                          _tabIndex = 0;
                                          _tabController.index = 0;
                                        });
                                      },
                                      goWallet: () {
                                        if(Setting.isUseWallet) {
                                          setState(() {
                                            _tabIndex = 2;
                                            _tabController.index = 2;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                )),
                                const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(ColorTheme.c_ededed)),
                                SizedBox(
                                  height: 56,
                                  child: TabBar(
                                    controller: _tabController,
                                    tabs: getMainTab(),
                                    onTap: tapTab,
                                    indicatorColor: Colors.transparent,
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  List<Widget> getMainTab() {
    if(Setting.isUseWallet) {
     return  [
        Tab(
            icon: SvgPicture.asset(_tabIndex == 0
                ? "images/nav_menu_home_pressed.svg"
                : "images/nav_menu_home.svg")),
        Tab(
            icon: SvgPicture.asset(_tabIndex == 1
                ? "images/nav_menu_point_on.svg"
                : "images/nav_menu_point_off.svg")),

        Tab(
            icon: SvgPicture.asset(_tabIndex == 2
                ? "images/nav_menu_wallet_pressed.svg"
                : "images/nav_menu_wallet.svg")),
        Tab(
            icon: SvgPicture.asset(_tabIndex == 3
                ? "images/nav_menu_shop_pressed.svg"
                : "images/nav_menu_shop.svg")),
        Tab(
            icon: SvgPicture.asset(_tabIndex == 4
                ? "images/nav_menu_mypage_pressed.svg"
                : "images/nav_menu_mypage.svg")),
      ];
    }else {
      return  [
        Tab(
            icon: SvgPicture.asset(_tabIndex == 0
                ? "images/nav_menu_home_pressed.svg"
                : "images/nav_menu_home.svg")),
        Tab(
            icon: SvgPicture.asset(_tabIndex == 1
                ? "images/nav_menu_point_on.svg"
                : "images/nav_menu_point_off.svg")),


        Tab(
            icon: SvgPicture.asset(_tabIndex == 2
                ? "images/nav_menu_shop_pressed.svg"
                : "images/nav_menu_shop.svg")),
        Tab(
            icon: SvgPicture.asset(_tabIndex == 3
                ? "images/nav_menu_mypage_pressed.svg"
                : "images/nav_menu_mypage.svg")),
      ];
    }
  }

  void tapTab(int index) {
    switch (index) {
      case 0:
        webViewController1?.loadUrl(
            urlRequest: URLRequest(url: WebUri(_urlRequest1)));
        break;
      case 1:
        webViewController2?.loadUrl(
            urlRequest: URLRequest(url: WebUri(_urlRequest2)));
        break;
      case 2:
        if(!Setting.isUseWallet) {
          webViewController3?.loadUrl(
              urlRequest: URLRequest(url: WebUri(_urlRequest3)));
        }
        break;
      case 3:
        if(Setting.isUseWallet) {
          webViewController3?.loadUrl(
              urlRequest: URLRequest(url: WebUri(_urlRequest3)));
        }
        break;
    }
    setState(() {
      _tabIndex = index;
      _tabController.index = index;
    });
    hideLoading();
  }

  hideLoading() {
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      loadingDialog.hide();
    });
  }

  void showServicePrepared() {
    showDialog(
        context: context,
        builder: (BuildContext context) => InfoDialog(
              title: "info".tr(),
              body: "service_prepare".tr(),
              btnText: "confirm".tr(),
            ));
  }

  void addAppJavascriptHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
        handlerName: "wallet",
        callback: (args) async {
          await Navigator.of(context)
              .pushNamed(Routes.welcomePage)
              .then((value) {
            if (value == true) {
              tapTab(2);
            }
          });
        });

    controller.addJavaScriptHandler(
        handlerName: "fail",
        callback: (args) {
          PlasticheroMember.logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.loginPage, (route) => false);
        });
    controller.addJavaScriptHandler(
        handlerName: "window",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);
          if (value["url"].isNotEmpty) {
            final url = value["url"]!;
            openExternalWindow(url);

          }
        });

    controller.addJavaScriptHandler(
        handlerName: "linkAccount",
        callback: (args) {
          Navigator.of(context).pushNamed(Routes.signupIdPage,
              arguments: {'joinType': 'snsLoginCreate'}).whenComplete(() {
            webViewController1?.loadUrl(
                urlRequest: URLRequest(url: WebUri(_urlRequest1)));
          });
        });
    controller.addJavaScriptHandler(
        handlerName: "untrust",
        callback: (args) {
          Navigator.of(context).pushNamed(Routes.signupSmsPage, arguments: {
            'certType': CertType.changePhone,
            'type': CertChangeType.phone,
            'error': 'untrust',
          }).whenComplete(()  {
            webViewController1?.reload();
            webViewController2?.reload();
            webViewController3?.reload();
            webViewController4?.reload();
          });
        });
    controller.addJavaScriptHandler(
        handlerName: "loading",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);
          if (value["status"] == "show") {
            Debug.log("loading", "show executed");
            loadingDialog.show();
          } else if (value["status"] == "hide") {
            Debug.log("loading", "hide executed");
            loadingDialog.hide();
          }
        });
    controller.addJavaScriptHandler(
        handlerName: "tab",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);
          final status = value["status"] ?? "";
          if (status != "") {
            tapTab(MainTabType.getIndex(status));
          }
        });
    controller.addJavaScriptHandler(
        handlerName: "open",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);
          final title = value["title"] ?? "";
          String url = value["url"] ?? "";
          if (url != "") {
            Uri uri = Uri.parse(url);
            if (uri.queryParameters.keys.length == 0) {
              url = "$url?code=$_code";
            } else {
              url = "$url&code=$_code";
            }
            Navigator.of(context).pushNamed(Routes.webPage,
                arguments: {"url": url, "title": title});
          }
        });
  }

  void showSwap() {
    CommonFunction.showBottomSheet(
        context: context,
        isDismissible: true,
        child: SwapMainWidget(
          onShowList: () {
            Navigator.of(context).pop();
            tapTab(1);
          },
        ));
  }

  Future<void> _refreshWebView() async {
    if (mounted) {
      webViewController1?.reload();
      webViewController2?.reload();
      webViewController3?.reload();
    }
  }

  Future<void> openExternalWindow(String url) async {
    final urlLink =Uri.parse(url);
    if(await canLaunchUrl(urlLink)) {
      launchUrl(urlLink , mode: LaunchMode.externalApplication);
    }
  }
}
