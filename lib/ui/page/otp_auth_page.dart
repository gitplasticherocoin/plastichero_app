import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_param_key.dart';
import '../../api/member/check_response.dart';
import '../../api/wallet/wallet_otp.dart';
import '../../constants/color_theme.dart';
import '../../constants/preference_key.dart';
import '../../constants/setting.dart';
import '../../main.dart';
import '../../util/common_function.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/otp_qr_dialog.dart';
import '../widget/button_widget.dart';
import '../widget/text_widget.dart';
import '../widget/toolbar_widget.dart';

class OtpAuthPage extends StatefulWidget {
  const OtpAuthPage({Key? key}) : super(key: key);

  @override
  State<OtpAuthPage> createState() => _OtpAuthPageState();
}

class _OtpAuthPageState extends State<OtpAuthPage> {
  late final LoadingDialog loadingDialog;
  late final ValueNotifier<bool> btnNotifier;
  late final TextEditingController authController;

  final String googleOtpPackage = "com.google.android.apps.authenticator2";

  String secret = '';
  String qrCode = '';

  @override
  void initState() {
    super.initState();

    loadingDialog = LoadingDialog(context: context);
    btnNotifier = ValueNotifier<bool>(false);
    authController = TextEditingController();

    getCreateKeyHandler();
  }

  @override
  void dispose() {
    btnNotifier.dispose();
    authController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: unFocus,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: DefaultToolbar(
              isBackButton: true,
              onBackPressed: () {
                Navigator.of(context).pop();
              },
              centerTitle: false,
              titleText: "otp_linking".tr(),
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Container(
                                height: 30,
                                padding: const EdgeInsets.only(left: 13.0, right: 12.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15.0),
                                    topLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  color: Color(ColorTheme.c_75c193),
                                ),
                                child: const Text(
                                  'STEP 1',
                                  style: TextStyle(
                                    height: 1.2,
                                    fontSize: 14,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'down_auth_app'.tr(),
                                  style: const TextStyle(
                                    height: 1.2,
                                    fontSize: 15,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              'down_auth_app_guide'.tr(),
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 13,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.c_4b4b4b),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: wButton(
                                  onTap: () {
                                    runGoogleOtp(isAppStore: true);
                                  },
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1.0, color: const Color(ColorTheme.c_dbdbdb)),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SvgPicture.asset(
                                          'images/icon_ios.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 6.0),
                                        const Text(
                                          'App Store',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: Setting.appFont,
                                            fontWeight: FontWeight.w400,
                                            color: Color(ColorTheme.defaultText),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                flex: 1,
                                child: wButton(
                                  onTap: () {
                                    runGoogleOtp(isAppStore: false);
                                  },
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1.0, color: const Color(ColorTheme.c_dbdbdb)),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SvgPicture.asset(
                                          'images/icon_google.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 6.0),
                                        const Text(
                                          'Google Play',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: Setting.appFont,
                                            fontWeight: FontWeight.w400,
                                            color: Color(ColorTheme.defaultText),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 34.0),
                          Row(
                            children: [
                              Container(
                                height: 30,
                                padding: const EdgeInsets.only(left: 13.0, right: 12.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15.0),
                                    topLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  color: Color(ColorTheme.c_75c193),
                                ),
                                child: const Text(
                                  'STEP 2',
                                  style: TextStyle(
                                    height: 1.2,
                                    fontSize: 14,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'scan_or_copy_key'.tr(),
                                  style: const TextStyle(
                                    height: 1.2,
                                    fontSize: 15,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              'scan_or_copy_key_guide'.tr(),
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 13,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.c_4b4b4b),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 12.0, bottom: 10.0),
                            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 15.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: const Color(ColorTheme.c_ededed),
                            ),
                            child: Text(
                              secret,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.defaultText),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: wButton(
                                  onTap: () {
                                    CommonFunction.hideKeyboard(context);
                                    if (secret.isNotEmpty) {
                                      CommonFunction.copyData(context, secret);
                                    }
                                  },
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1.0, color: const Color(ColorTheme.c_dbdbdb)),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'copy_key'.tr(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w400,
                                        color: Color(ColorTheme.defaultText),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                flex: 1,
                                child: wButton(
                                  onTap: () async {
                                    CommonFunction.hideKeyboard(context);
                                    CommonFunction.showBottomSheet(
                                      context: context,
                                      isDismissible: true,
                                      child: OtpQrDialog(qrCode: qrCode),
                                    );
                                  },
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1.0, color: const Color(ColorTheme.c_dbdbdb)),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'qr_code'.tr(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w400,
                                        color: Color(ColorTheme.defaultText),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 34.0),
                          Row(
                            children: [
                              Container(
                                height: 30,
                                padding: const EdgeInsets.only(left: 13.0, right: 12.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15.0),
                                    topLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  color: Color(ColorTheme.c_75c193),
                                ),
                                child: const Text(
                                  'STEP 3',
                                  style: TextStyle(
                                    height: 1.2,
                                    fontSize: 14,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'enter_auth_code'.tr(),
                                  style: const TextStyle(
                                    height: 1.2,
                                    fontSize: 15,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              'enter_auth_code_otp_guide'.tr(),
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 13,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.c_4b4b4b),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InputTextField(
                            controller: authController,
                            hintText: 'enter_auth_code_placeholder'.tr(),
                            keyboardType: TextInputType.number,
                            denySpace: true,
                            maxLength: 6,
                            onChanged: (value) {
                              btnNotifier.value = value.trim().length == 6;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: btnNotifier,
                  builder: (_, isEnable, __) {
                    return BtnFill(
                      margin: const EdgeInsets.fromLTRB(24, 5, 24, 24),
                      onTap: () {
                        CommonFunction.hideKeyboard(context);
                        setOtpHandler();
                      },
                      isEnable: isEnable,
                      text: "complete".tr(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TODO: unFocus()
  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  Widget wButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.0),
        child: child,
      ),
    );
  }

  void runGoogleOtp({bool isAppStore = false}) async {
    CommonFunction.hideKeyboard(context);

    String appStoreUrl = 'https://apps.apple.com/kr/app/google-authenticator/id388497605';
    String googleStoreUrl = 'https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=$lang';

    String marketUrl = isAppStore ? appStoreUrl : googleStoreUrl;

    if (Platform.isIOS) {
      bool isAppInstalled = await LaunchApp.isAppInstalled(
        iosUrlScheme: appStoreUrl,
      );

      if (isAppStore && isAppInstalled) {
        LaunchApp.openApp(
          iosUrlScheme: appStoreUrl,
          openStore: true,
        );
      } else {
        launchUrl(Uri.parse(marketUrl), mode: LaunchMode.externalApplication);
      }
    } else {
      bool isAppInstalled = await LaunchApp.isAppInstalled(
        androidPackageName: 'com.google.android.apps.authenticator2',
      );
      if (!isAppStore && isAppInstalled) {
        LaunchApp.openApp(
          androidPackageName: googleOtpPackage,
        );
      } else {
        launchUrl(Uri.parse(marketUrl), mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> getCreateKeyHandler() async {
    var manager = ApiManagerWalletOtp();
    dynamic json;

    try {
      json = await manager.createKey();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result];

        secret = result[ApiParamKey.secret] ?? '';
        qrCode = result[ApiParamKey.qrCode] ?? '';

        setState(() {});

        return;
      } else {
        if (mounted) {
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> setOtpHandler() async {
    if (secret.isEmpty) {
      CommonFunction.showToast(context, 'msg_otp_no_key'.tr());
      return;
    }

    var manager = ApiManagerWalletOtp();
    dynamic json;

    try {
      loadingDialog.show();
      json = await manager.setOtp(secret: secret, token: authController.text.trim());
      loadingDialog.hide();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result];

        await CommonFunction.setPreferencesBoolean(PreferenceKey.isOtp, true);

        if (mounted) {
          CommonFunction.showToast(context, 'msg_otp_auth_success'.tr());
          Navigator.pop(context, true);
        }
        return;
      } else {
        if (mounted) {
          CommonFunction.showInfoDialog(context, json[ApiParamKey.msg]);
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      loadingDialog.hide();
    }
  }
}
