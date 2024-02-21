import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';

import '../../api/member/check_response.dart';
import '../../api/wallet/wallet_bpth.dart';
import '../../constants/setting.dart';
import '../../routes.dart';
import '../../util/debug.dart';
import '../widget/button_widget.dart';
import '../widget/checkbox_02.dart';

class SafeUseGuidePage extends StatefulWidget {
  const SafeUseGuidePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return SafeUseGuidePageState();
  }
}

class SafeUseGuidePageState extends State<SafeUseGuidePage> {
  bool confirmGuide = false;

  String tag = 'SafeUseGuidePage';

  late LoadingDialog loadingDialog;

  @override
  void initState() {
    super.initState();

    loadingDialog = LoadingDialog(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: DefaultToolbar(
            titleText: 'title_safe_use_guide'.tr(),
            centerTitle: false,
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          body: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Column(
                children: [
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  'msg_safe_user_guide'.tr(),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
                                )),
                                SvgPicture.asset(
                                  'images/img_lock.svg',
                                  width: 46,
                                  height: 46,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            questionWidget('mnemonic_guide_title1'.tr(), 'mnemonic_guide_msg1'.tr()),
                            questionWidget('mnemonic_guide_title2'.tr(), 'mnemonic_guide_msg2'.tr()),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                              height: 1,
                              color: const Color(ColorTheme.c_ededed),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(ColorTheme.c_f3f3f3)),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset('images/icon_notice.svg'),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'precautions'.tr(),
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  precautionsWidget('precautions_msg1'.tr()),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  precautionsWidget('precautions_msg2'.tr()),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InkWell(
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        confirmGuide = !confirmGuide;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: confirmGuide ? const Color(ColorTheme.c_19984b) : const Color(ColorTheme.c_dbdbdb)),
                          child: SvgPicture.asset(
                            "images/icon_check_w_m.svg",
                            width: 12,
                            height: 9,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Text(
                          'confirm_safe_user_guide'.tr(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
                        ))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  BtnFill(
                      text: 'next'.tr(),
                      isEnable: confirmGuide,
                      onTap: () async {
                        String result = await getMnemonicHandler();
                        if (mounted) {
                          if (result.isNotEmpty) {
                            Navigator.pushReplacementNamed(context, Routes.myMnemonicPage, arguments: {"mnemonic": result});
                          }
                        }
                      }),
                  const SizedBox(
                    height: 24,
                  )
                ],
              )),
        ),
      ),
    );
  }

  double getTextHeight(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: ui.TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.height;
  }

  Widget precautionsWidget(String content) {
    TextStyle style = const TextStyle(height: 1.1, fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 13, color: Color(ColorTheme.defaultText));
    double height = getTextHeight(content, style);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          alignment: Alignment.center,
          child: Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(ColorTheme.defaultText)),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(content, style: style),
        )
      ],
    );
  }

  Widget questionWidget(String title, String content) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Q.',
              style: TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w500, fontSize: 24, color: Color(ColorTheme.defaultText)),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: Setting.appFont, color: Color(ColorTheme.defaultText)),
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(ColorTheme.c_e7f5ec)),
          child: Text(
            content,
            style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 14, color: Color(ColorTheme.defaultText)),
          ),
        ),
        const SizedBox(
          height: 12,
        )
      ],
    );
  }

  Future<String> getMnemonicHandler() async {
    loadingDialog.show();

    var manager = ApiManagerBPTHWallet();

    dynamic json;

    try {
      json = await manager.getMnemonic();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        var mnemonic = json[ApiParamKey.mnemonic];
        var timestamp = json[ApiParamKey.timestamp];

        final aes = AESHelper();
        final result = aes.decrypt(mnemonic, timestamp);

        // print('aaaaa result //$result// ');

        loadingDialog.hide();

        return result;
      } else {
        if (mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      Debug.log(tag, '## getNemonicHandler() error = $e');

      loadingDialog.hide();
      return "";
    }

    loadingDialog.hide();
    return "";
  }

  @override
  void dispose() {
    super.dispose();
  }
}
