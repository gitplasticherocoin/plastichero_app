import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/provider/welcome_to_bpth_provider.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:provider/provider.dart';

import '../../api/wallet/wallet_bpth.dart';
import '../../constants/setting.dart';
import '../../routes.dart';
import '../../util/debug.dart';
import '../dialog/loading_dialog.dart';

class MyMnemonicRecheckPage extends StatefulWidget {
  const MyMnemonicRecheckPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyMnemonicRecheckPageState();
  }
}

class MyMnemonicRecheckPageState extends State<MyMnemonicRecheckPage> {
  Map<String, dynamic>? arguments;

  List<String> mnemonicList = [];
  List<String> originMnemonicList = [];
  List<String> randomMnemonicList = [];
  List<int> selectedMnemonicList = [];

  List<bool> selectedRandomMnemonicList = [];

  bool isMnemonicRecheck = false;

  double mainSidePadding = 24;
  double containerSidePadding = 14;

  double crossAxisSpacing = 7;
  double mainAxisSpacing = 5;
  double childAspectRatio = 90 / 50;

  double randomMainAxisSpacing = 12;
  double randomCrossAxisSpacing = 15;
  double randomChildAspectRatio = 94 / 42;

  double mnemonicItemWidth = 0;
  double mnemonicItemHeight = 0;

  double randomMnemonicItemHeight = 0;
  double randomMnemonicItemWidth = 0;

  double randomMnemonicHeight = 0;
  double randomMnemonicWidth = 0;

  double mnemonicHeight = 0;
  double mnemonicWidth = 0;
  double mnemonicPadding = 14;

  ScrollController scrollController = ScrollController();

  late LoadingDialog loadingDialog;

  @override
  void initState() {
    super.initState();

    loadingDialog = LoadingDialog(context: context);
  }

  @override
  Widget build(BuildContext context) {
    if (arguments == null) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        originMnemonicList = arguments!["originMnemonicList"] ?? [];

        randomMnemonicList.addAll(originMnemonicList);
        randomMnemonicList.shuffle();

        selectedRandomMnemonicList = List.generate(randomMnemonicList.length, (index) => false);
      }
    }

    mnemonicItemWidth = (MediaQuery.of(context).size.width - mainSidePadding * 2 - crossAxisSpacing * 2 - containerSidePadding * 2) / 3;
    mnemonicItemHeight = (mnemonicItemWidth * 50 / 90);

    randomMnemonicItemWidth = (MediaQuery.of(context).size.width - mainSidePadding * 2 - randomCrossAxisSpacing * 2) / 3;
    randomMnemonicItemHeight = (randomMnemonicItemWidth * 42 / 94);

    mnemonicHeight = mnemonicItemHeight * ((randomMnemonicList.length / 3).ceil()).toDouble() + mainAxisSpacing * ((randomMnemonicList.length / 3).ceil());
    mnemonicWidth = mnemonicItemWidth * 3 + 2 * crossAxisSpacing;

    randomMnemonicHeight = randomMnemonicItemHeight * ((randomMnemonicList.length / 3).ceil()).toDouble() + randomMainAxisSpacing * ((randomMnemonicList.length / 3).ceil());
    randomMnemonicWidth = randomMnemonicItemWidth * 3 + 2 * randomCrossAxisSpacing;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: DefaultToolbar(
            titleText: 'title_mnemonic_recheck'.tr(),
            centerTitle: false,
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          body: Padding(
            padding: EdgeInsets.only(left: mainSidePadding, right: mainSidePadding),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'mnemonic_recheck_msg1'.tr(),
                            style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w500, fontSize: 16, color: Color(ColorTheme.defaultText)),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            'mnemonic_recheck_msg2'.tr(),
                            style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 14, color: Color(ColorTheme.defaultText)),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Center(
                            child: Container(
                              height: mnemonicHeight + 2 * mnemonicPadding,
                              width: mnemonicWidth + 2 * mnemonicPadding,
                              padding: EdgeInsets.all(mnemonicPadding),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: const Color(ColorTheme.c_f3f3f3)),
                              child: ScrollConfiguration(
                                behavior: const ScrollBehavior().copyWith(overscroll: false),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: mnemonicList.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, mainAxisSpacing: mainAxisSpacing, crossAxisSpacing: crossAxisSpacing, childAspectRatio: childAspectRatio),
                                  itemBuilder: (BuildContext context, int index) {
                                    return mnemonicItem(index, mnemonicList.elementAt(index));
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Center(
                            child: SizedBox(
                              height: randomMnemonicHeight,
                              width: randomMnemonicWidth,
                              child: ScrollConfiguration(
                                behavior: const ScrollBehavior().copyWith(overscroll: false),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: randomMnemonicList.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, mainAxisSpacing: randomMainAxisSpacing, crossAxisSpacing: randomCrossAxisSpacing, childAspectRatio: randomChildAspectRatio),
                                  itemBuilder: (BuildContext context, int index) {
                                    return randomMnemonicItem(index, randomMnemonicList.elementAt(index));
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(
                    height: 12,
                  ),
                  BtnFill(
                    text: 'next'.tr(),
                    isEnable: isMnemonicRecheck,
                    onTap: () async {
                      String tempMnemonic = '';
                      tempMnemonic = mnemonicList.join(' ');

                      AESHelper aes = AESHelper();

                      Map<String, String> encryptData = aes.encrypt(tempMnemonic);

                      if (mnemonicList.length == originMnemonicList.length) {
                        if (listEquals(mnemonicList, originMnemonicList)) {
                          bool result = false;

                          if (encryptData['data'] != null && encryptData['iv'] != null) {
                            result = await createBpth(encryptData['data']!, encryptData['iv']!);
                          }

                          if (mounted) {
                            if (result) {
                              isMnemonicRecheck = true;
                              Navigator.popUntil(context, ModalRoute.withName("/mainPage"));
                              Provider.of<WelcomeTobPTHProvider>(context, listen: false).firstCreatedBPTH(true);
                            }
                          }
                        } else {
                          isMnemonicRecheck = false;
                          CommonFunction.showToast(context, 'msg_fail_mnemonic_recheck'.tr(), bottom: 60);
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget randomMnemonicItem(int index, String text) {
    return InkWell(
      onTap: () {
        setState(() {
          int oldCount = mnemonicList.length;
          int newCount = 0;

          if (selectedMnemonicList.contains(index)) {
            int getIndex = selectedMnemonicList.indexWhere((element) => element == index);
            mnemonicList.removeAt(getIndex);
            selectedMnemonicList.removeWhere((element) => element == index);
            selectedRandomMnemonicList[index] = false;
            isMnemonicRecheck = false;
          } else {
            mnemonicList.add(text);
            selectedMnemonicList.add(index);
            selectedRandomMnemonicList[index] = true;

            if (mnemonicList.length == originMnemonicList.length) {
              isMnemonicRecheck = true;
            } else {
              isMnemonicRecheck = false;
            }
          }

          newCount = mnemonicList.length;
        });
      },
      child: SizedBox(
        width: randomMnemonicItemWidth,
        height: randomMnemonicItemHeight,
        child: Container(
          height: randomMnemonicItemHeight,
          width: randomMnemonicItemWidth,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), color: selectedRandomMnemonicList.elementAt(index) ? const Color(ColorTheme.c_b9e0c8) : const Color(ColorTheme.c_e7f5ec)),
          alignment: Alignment.center,
          child: AutoSizeText(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
          ),
        ),
      ),
    );
  }

  Widget mnemonicItem(int index, String text) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        setState(() {
          int randomListIndex = selectedMnemonicList.elementAt(index);
          selectedRandomMnemonicList[randomListIndex] = false;
          mnemonicList.removeAt(index);
          selectedMnemonicList.removeWhere((element) => element == randomListIndex);
          isMnemonicRecheck = false;
        });
      },
      child: SizedBox(
        width: mnemonicItemWidth,
        height: mnemonicItemHeight,
        child: Stack(
          children: [
            Positioned(
                top: mnemonicItemHeight * 11 / 50,
                child: Container(
                  height: mnemonicItemHeight * 39 / 50,
                  width: mnemonicItemWidth,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), color: Colors.white),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> createBpth(String mnemonic, String timestamp) async {
    loadingDialog.show();

    var manager = ApiManagerBPTHWallet();

    dynamic json;

    try {
      json = await manager.create(mnemonic: mnemonic, timestamp: timestamp);

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        loadingDialog.hide();
        return true;
      } else {
        loadingDialog.hide();
        if (mounted) {
          CommonFunction.showInfoDialog(context, json[ApiParamKey.msg]);
        }
        return false;
      }
    } catch (e) {
      CommonFunction.showConnectErrorDialog(context, json);
    }

    loadingDialog.hide();
    return false;
  }
}
