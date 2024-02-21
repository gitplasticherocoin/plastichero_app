import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'dart:ui' as ui;

class ArticlePage extends StatefulWidget {
  const ArticlePage({Key? key}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  List<Widget> tabs = [
    Tab(text: "service_article".tr()),
    Tab(text: "privacy_article".tr()),
  ];
  int _tabIndex = 0;
  String url = Setting.isTest ? Setting.domainDev : Setting.domain;
  String _lang = "en";
  @override
  void initState() {
    super.initState();


    _lang = ui.window.locale.languageCode;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final tabIndex = arguments["tabIndex"] ?? 0;
    _tabIndex = tabIndex;

    return DefaultTabController(
      length: tabs.length,
      initialIndex: _tabIndex,
      child: Scaffold(
          appBar: DefaultToolbar(
            isBackButton: true,
            onBackPressed: () {
              Navigator.of(context).pop();
            },
            centerTitle: false,
            titleText: "article".tr(),
            bottom: TabBar(
              onTap: (index) {
                _tabIndex = index;
              },
              tabs: tabs,
              labelColor: const Color(ColorTheme.defaultText),
              unselectedLabelColor: const Color(ColorTheme.c_b3b3b3),
              indicatorWeight: 2,
              automaticIndicatorColorAdjustment: true,
              indicatorPadding: EdgeInsets.zero,
              indicatorColor: const Color(ColorTheme.appColor),
            ),
          ),
          body: SafeArea(
              child: TabBarView(
            children: [
              Column(
                children: [
                  Expanded(
                      child:InAppWebView(
                        gestureRecognizers: Set()..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
                        initialUrlRequest: URLRequest(url: WebUri("${Setting.termsOfUseUrl}?lang=$_lang")),
                        initialSettings: InAppWebViewSettings(
                          transparentBackground: true,
                          applicationNameForUserAgent: "PlasticheroApp", // 지갑앱에서도 동일하게 사용하면 됩니다.
                        ),

                        onWebViewCreated: (controller) {
                          //webViewController = controller;


                        },

                      ),



                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      top: 24,
                    ),
                    child: BtnFill(
                      text: "confirm".tr(),
                      onTap: confirm1,
                    ),
                  )
                ],
              ),


              Column(
                children: [
                  Expanded(
                    child: InAppWebView(
                      gestureRecognizers: Set()..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
                      initialUrlRequest: URLRequest(url: WebUri("${Setting.termsOfPrivacyUrl}?lang=$_lang")),
                      initialSettings: InAppWebViewSettings(
                        transparentBackground: true,
                        applicationNameForUserAgent: "PlasticheroApp", // 지갑앱에서도 동일하게 사용하면 됩니다.
                      ),

                      onWebViewCreated: (controller) {
                        //webViewController = controller;


                      },

                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      top: 24,
                    ),
                    child: BtnFill(
                      text: "confirm".tr(),
                      onTap: confirm2,
                    ),
                  )
                ],
              ),
            ],
          ))),
    );
  }

  void confirm1() {
    Navigator.of(context).pop("check1");
  }
  void confirm2() {
    Navigator.of(context).pop("check2");
  }
}
