import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:provider/provider.dart';

import '../../api/api_param_key.dart';
import '../../api/member/check_response.dart';
import '../../api/wallet/wallet_bpth.dart';
import '../../constants/common.dart';
import '../../constants/setting.dart';
import '../../provider/welcome_to_bpth_provider.dart';

import '../widget/toolbar_widget.dart';

class GetWalletPage extends StatefulWidget {
  const GetWalletPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return GetWalletPageState();
  }
}

class GetWalletPageState extends State<GetWalletPage> {
  double mainSidePadding = 24;
  double containerSidePadding = 14;
  double gridSpacing = 10;

  double mnemonicItemWidth = 0;
  double mnemonicItemHeight = 0;

  double mnemonicHeight = 0;
  double mnemonicWidth = 0;

  double childAspectRatio = 90 / 50;

  int mnemonicLength = 12;

  List<int> mnemonicInputLengthList = [];
  List<String> mnemonicInputList = [];
  int inputCnt = 0;

  late List<TextEditingController> textEditingControllerList;
  late List<FocusNode> focusNodeList;

  int currentIndex = -1;

  bool isEmptyText = false;

  late LoadingDialog loadingDialog;

  @override
  void initState() {
    super.initState();

    loadingDialog = LoadingDialog(context: context);

    mnemonicInputLengthList = List.generate(mnemonicLength, (index) => 0);
    mnemonicInputList = List.generate(mnemonicLength, (index) => '');
    textEditingControllerList = List.generate(mnemonicLength, (index) => TextEditingController());
    focusNodeList = List.generate(mnemonicLength, (index) => FocusNode());
    for (int i = 0; i < focusNodeList.length; i++) {
      var element = focusNodeList.elementAt(i);
      element.addListener(() {
        if (element.hasFocus) {
          currentIndex = i;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mnemonicItemWidth = (MediaQuery.of(context).size.width - mainSidePadding * 2 - gridSpacing * 2 - containerSidePadding * 2) / 3;
    mnemonicItemHeight = (mnemonicItemWidth * 50 / 90);

    mnemonicWidth = mnemonicItemWidth * 3 + 2 * gridSpacing;
    mnemonicHeight = mnemonicItemHeight * ((mnemonicLength / 3).ceil()).toDouble() + 5 * ((mnemonicLength / 3).floor());

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
              appBar: DefaultToolbar(
                titleText: 'get_wallet'.tr(),
                centerTitle: false,
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              body: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'msg_get_wallet'.tr(),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Focus(
                          autofocus: true,
                          onKey: (node, event) {
                            if (currentIndex > 0) {
                              if (event is RawKeyUpEvent) {
                                if (event.data.logicalKey.keyLabel == 'Backspace') {
                                  if (textEditingControllerList.elementAt(currentIndex).text.isEmpty) {
                                    if (isEmptyText) {
                                      focusNodeList.elementAt(currentIndex).previousFocus();
                                      if (textEditingControllerList.elementAt(currentIndex - 1).text.isEmpty) {
                                        isEmptyText = true;
                                      } else {
                                        isEmptyText = false;
                                      }
                                    } else {
                                      isEmptyText = true;
                                    }
                                    return KeyEventResult.handled;
                                  }
                                }
                              }
                            }

                            return KeyEventResult.ignored;
                          },
                          child: Container(
                            decoration: BoxDecoration(color: const Color(ColorTheme.c_f3f3f3), borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(14),
                            child: SizedBox(
                              height: mnemonicHeight,
                              width: mnemonicWidth,
                              child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: mnemonicLength,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 5, childAspectRatio: childAspectRatio),
                                  itemBuilder: (context, index) {
                                    return mnemonicItem(index);
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isKeyboardVisible
                              ? 0
                              : MediaQuery.of(context).size.height -
                                  MediaQuery.of(context).padding.top -
                                  MediaQuery.of(context).padding.bottom -
                                  Common.appBar -
                                  10 -
                                  20 -
                                  12 -
                                  mnemonicHeight -
                                  containerSidePadding * 2 -
                                  24 -
                                  54 -
                                  24,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        BtnFill(
                          text: 'get'.tr(),
                          isEnable: inputCnt == mnemonicLength,
                          onTap: () async {
                            CommonFunction.hideKeyboard(context);

                            String tempMnemonic = '';
                            tempMnemonic = mnemonicInputList.join(' ');

                            AESHelper aes = AESHelper();

                            Map<String, String> encryptData = aes.encrypt(tempMnemonic);

                            // print('aaaaa1 $tempMnemonic');
                            // print('aaaaa2 ${encryptData['data']} / ${encryptData['iv']}');
                            // print('aaaaa3 ${aes.decrypt(encryptData['data']!, encryptData['iv']!)}');

                            bool result = await createBpth(encryptData['data']!, encryptData['iv']!);

                            if (mounted) {
                              if (result) {
                                CommonFunction.showToast(context, 'msg_success_create_wallet'.tr());
                                Navigator.popUntil(context, ModalRoute.withName("/mainPage"));
                                Provider.of<WelcomeTobPTHProvider>(context, listen: false).firstCreatedBPTH(true);
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
              )),
        ),
      );
    });
  }

  Widget mnemonicItem(int index) {
    return Stack(
      children: [
        Positioned.fill(
            top: 8,
            child: Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), color: Colors.white),
              child: InputTextField(
                expands: true,
                maxLines: null,
                contentPadding: const EdgeInsets.only(left: 22, right: 10, top: 5, bottom: 5),
                defaultFillColor: Colors.white,
                borderRadius: 21,
                textInputAction: index == mnemonicLength - 1 ? TextInputAction.done : TextInputAction.next,
                controller: textEditingControllerList.elementAt(index),
                focusNode: focusNodeList.elementAt(index),
                style: TextStyle(
                    height: 1.2,
                    fontSize: (mnemonicItemWidth * 40 / 90) / 3,
                    color: const Color(ColorTheme.defaultText),
                    fontFamily: Setting.appFont,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    decorationThickness: 0),
                onChanged: (value) {
                  if (mnemonicInputLengthList.elementAt(index) == 0 && value.isNotEmpty) {
                    setState(() {
                      inputCnt++;
                    });
                  } else if (mnemonicInputLengthList.elementAt(index) > 0 && value.isEmpty) {
                    setState(() {
                      inputCnt--;
                    });
                  }

                  mnemonicInputLengthList[index] = value.length;
                  mnemonicInputList[index] = value;
                },
              ),
            )),
        Positioned(
            left: 3,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(ColorTheme.c_19984b)),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white),
              ),
            )),
      ],
    );
  }

  @override
  void dispose() {
    for (var element in textEditingControllerList) {
      element.dispose();
    }
    for (var element in focusNodeList) {
      element.dispose();
    }

    super.dispose();
  }

  Future<bool> createBpth(String mnemonic, String timestamp) async {
    loadingDialog.show();

    var manager = ApiManagerBPTHWallet();

    dynamic json;

    try {
      loadingDialog.show();
      json = await manager.create(mnemonic: mnemonic, timestamp: timestamp);
      loadingDialog.hide();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        return true;
      } else {
        if (mounted) {
          // await CheckResponse.checkErrorResponse(context, json);
          CommonFunction.showConnectErrorDialog(context, json);
        }
        return false;
      }
    } catch (e) {
      loadingDialog.hide();
      CommonFunction.showInfoDialog(context, 'msg_fail_get_wallet'.tr());
      return false;
    }

    loadingDialog.hide();
    return false;
  }
}
