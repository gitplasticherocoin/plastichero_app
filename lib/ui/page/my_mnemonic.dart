import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/secure_shot.dart';

import '../../constants/setting.dart';
import '../../routes.dart';

class MyMnemonicPage extends StatefulWidget {
  final String? mnemonic;

  const MyMnemonicPage({super.key, this.mnemonic});

  @override
  State<StatefulWidget> createState() {
    return MyMnemonicPageState();
  }
}

class MyMnemonicPageState extends State<MyMnemonicPage> {
  String widgetMnemonic = '';

  List<String> mnemonicList = [
    'apple',
    'banana',
    'coffee',
    'deny',
    'egg',
    'fruit',
    'grape',
    'hi',
    'ice',
    'juice',
    'ko',
    'lemon',
  ];

  double mainSidePadding = 24;
  double gridSpacing = 15;

  double mnemonicItemWidth = 0;
  double mnemonicItemHeight = 0;

  double mnemonicHeight = 0;
  double mnemonicWidth = 0;

  bool showMnemonic = false;
  bool confirmSaveMnemonic = false;

  Map<String, dynamic>? args;

  @override
  void initState() {
    super.initState();
    SecureShot.on();
  }

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      widgetMnemonic = args?['mnemonic'] ?? '';

      mnemonicList = widgetMnemonic.split(' ');
    }

    mnemonicItemWidth = (MediaQuery.of(context).size.width - mainSidePadding * 2 - gridSpacing * 2) / 3;
    mnemonicItemHeight = (mnemonicItemWidth * 50 / 94);

    mnemonicHeight = mnemonicItemHeight * ((mnemonicList.length / 3).ceil()).toDouble() + 4 * ((mnemonicList.length / 3).floor());
    mnemonicWidth = mnemonicItemWidth * 3 + 2 * gridSpacing;

    return Container(
      color: Colors.white,
      child: SafeArea(
          child: Scaffold(
        appBar: DefaultToolbar(
          centerTitle: false,
          leadingWidth: 24,
          leading: Container(),
          title: Text(
            'title_mnemonic'.tr(),
            style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w500, fontSize: 20, color: Color(ColorTheme.defaultText)),
          ),
        ),
        body: WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Padding(
              padding: EdgeInsets.only(left: mainSidePadding, right: mainSidePadding),
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'msg_mnemonic'.tr(),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            height: mnemonicHeight + 20,
                            width: mnemonicWidth,
                            child: Stack(
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: mnemonicHeight,
                                    width: mnemonicWidth,
                                    child: ScrollConfiguration(
                                      behavior: const ScrollBehavior().copyWith(overscroll: false),
                                      child: GridView.builder(
                                        itemCount: mnemonicList.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: gridSpacing, childAspectRatio: 94 / 50),
                                        itemBuilder: (BuildContext context, int index) {
                                          return mnemonicItem(index, mnemonicList.elementAt(index));
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      showMnemonic = true;
                                    });
                                  },
                                  child: !showMnemonic
                                      ? Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.black.withOpacity(0.9)),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset('images/icon_lock.svg'),
                                              const SizedBox(
                                                height: 8.6,
                                              ),
                                              Text(
                                                'show_mnemonic_msg'.tr(),
                                                style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                confirmSaveMnemonic = !confirmSaveMnemonic;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: confirmSaveMnemonic ? const Color(ColorTheme.c_19984b) : const Color(ColorTheme.c_dbdbdb)),
                                    child: SvgPicture.asset(
                                      "images/icon_check_w_m.svg",
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'check_to_save_mnemonic'.tr(),
                                  style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 14, color: Color(ColorTheme.defaultText)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          )
                        ],
                      ),
                    )),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: BtnBorderAppColor(
                          text: 'copy'.tr(),
                          isEnable: showMnemonic,
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: mnemonicList.toString()));
                            if (mounted) {
                              CommonFunction.showToast(context, 'msg_copy'.tr(), bottom: 60);
                            }
                          },
                        )),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                            child: BtnFill(
                          text: 'next'.tr(),
                          isEnable: showMnemonic && confirmSaveMnemonic,
                          onTap: () {
                            Navigator.pushNamed(context, Routes.myMnemonicRecheckPage, arguments: {"originMnemonicList": mnemonicList});
                          },
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    )
                  ],
                ),
              ),
            )),
      )),
    );
  }

  Widget mnemonicItem(int index, String text) {
    return SizedBox(
      width: mnemonicItemWidth,
      height: mnemonicItemHeight,
      child: Stack(
        children: [
          Positioned(
              top: mnemonicItemHeight * 11 / 50,
              child: Container(
                height: mnemonicItemHeight * 39 / 50,
                width: mnemonicItemWidth,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), color: const Color(ColorTheme.c_e7f5ec)),
                alignment: Alignment.center,
                child: AutoSizeText(
                  text,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
                ),
              )),
          Container(
            width: mnemonicItemHeight * 22 / 50,
            height: mnemonicItemHeight * 22 / 50,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(ColorTheme.c_19984b)),
            alignment: Alignment.center,
            child: AutoSizeText(
              (index + 1).toString(),
              style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SecureShot.off();
    super.dispose();
  }
}
