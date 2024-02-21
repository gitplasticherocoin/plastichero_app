import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plastichero/data/member_info.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero/ui/widget/button_widget.dart';
import 'package:plastichero/ui/widget/text_widget.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_common.dart';
import 'package:plastichero_app/api/wallet/wallet_otp.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/dialog/otp_confirm_dialog.dart';
import 'package:plastichero_app/ui/page/wallet_management_page.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'dart:ui' as ui;
class SettingPage extends StatefulWidget {
  final VoidCallback goGift;
  final VoidCallback goPoint;
  final VoidCallback goHome;
  final VoidCallback goWallet;


  const SettingPage(
      {Key? key, required this.goGift, required this.goPoint, required this.goHome, required this.goWallet})
      : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _name = "";

  String _passed = "0";
  String _giftcon = "0";
  String _point = "0";
  bool _isLoaded = false;
  final String _url = Setting.isTest ? Setting.domainDev : Setting.domain;

  String _urlGiftBox = "";
  MyinfoProvider? myinfoProvider;
  late final LoadingDialog loadingDialog;

  String _pth = "-";

  bool _checkedOtp = false;
  bool _isOtp = false;
  String _withdrawalPass = "";
  String _withdrawalPassTs = "";
  bool isKeyboardUp = false;
  String _newPass = "";
  bool _isEnalbePButton = false;

  bool get isWithdrawal {
    if(_withdrawalPass == "" && _withdrawalPassTs.isEmpty) {
      return false;
    }else {
      return true;
    }
  }

  String _version = "V1.0.0";
  @override
  void initState() {
    super.initState();
    myinfoProvider = Provider.of<MyinfoProvider>(context, listen: false)
      ..addListener(loadData);
    loadingDialog = LoadingDialog(context: context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadData();

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _version = "V${packageInfo.version}";
    });
  }

  @override
  void dispose() {
    if (myinfoProvider != null) {
      myinfoProvider?.removeListener(loadData);
    }
    super.dispose();
  }

  void loadName() async {
    String code =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";


    var manager = ApiManagerMember();
    dynamic json;

    try {

      json = await manager.getSettingInfo(code: code);

      final status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        final result = json[ApiParamKey.result];

        final memberInfo = MemberInfo.fromJson(result);
        setState(() {

          _name = memberInfo.mbName;
        });

      } else {
        setState(() {
          _name = "";
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {

    }
  }



  Future<void> loadData() async {
    // final name =
    //     await CommonFunction.getPreferencesString(PreferenceKey.loginName) ??
    //         "";
    if(!_checkedOtp) {
      checkOtp();
    }

    loadName();
    final code =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";
    NumberFormat format = NumberFormat('#,###,###');

    _isOtp = await CommonFunction.getPreferencesBoolean(PreferenceKey.isOtp) ?? false;


    _withdrawalPass = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? "";
    _withdrawalPassTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? "";


    var manager = ApiManagerMember();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.getMyInfo(code: code);

      final String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json['result'];
        final String passed = result["days_passed"].toString();
        final String giftcon = format.format(result['gift']);
        final String point = format.format(result['point']);

        String locale = ui.window.locale.languageCode;
        final lang = await CommonFunction.getPreferencesString(PreferenceKey.lang) ?? '';
        if (lang != null && lang!.isNotEmpty) {
          if (lang == 'en') {
            locale = lang;
          } else if (lang == 'ko' || lang == 'ko_KR') {
            locale = "ko";
          }
        }

        setState(() {

          _passed = passed;
          _giftcon = giftcon;
          _point = point;
          _isLoaded = true;

          _urlGiftBox = "$_url/mobile/gift/box.php?lang=$locale&code=$code";
        });
      } else {
        if (context.mounted) {
          CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await getMainPTH(code);
    }
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

  Future<void> checkOtp() async {
    var manager =  ApiManagerWalletOtp();
    dynamic json;
    try {
      json = await manager.getOtp();
      final status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {
        final isOtp = json["otp_exist"];
        if(isOtp) {

          await CommonFunction.setPreferencesBoolean(PreferenceKey.isOtp, isOtp);
        }else {
          await CommonFunction.setPreferencesBoolean(PreferenceKey.isOtp, isOtp);
        }
        _checkedOtp = true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  Future<void> getMainPTH(String code) async {
    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      json = await manager.getMainBalance(sessionCode: code);
      final String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        String pth = json[ApiParamKey.result];
        if (pth.endsWith(Setting.appSymbol)) {

        } else {
          pth = "$pth ${Setting.appSymbol}";
        }

        if (pth == "- ${Setting.appSymbol}") {
          pth = "0 ${Setting.appSymbol}";
        }
        setState(() {
          _pth = pth;
        });
      }
    } catch (e) {
      Debug.log("debug", e.toString());
    } finally {
      loadingDialog.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: _isLoaded

                ? ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: Stack(
                children: [

                  RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 26,
                                ),
                                Text("${sprintf("msg_hello".tr(), [_name])},",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.0,
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w600,
                                      color: Color(ColorTheme.defaultText),
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                RichText(
                                  text: TextSpan(
                                      style: const TextStyle(
                                        color: Color(ColorTheme.c_767676),
                                        fontSize: 13,
                                        letterSpacing: -0.2,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "mypage_headline_start".tr(),
                                            style: const TextStyle()),
                                        TextSpan(
                                            text: sprintf(
                                                "msg_passed".tr(), [_passed]),
                                            style: const TextStyle(
                                              color: Color(ColorTheme.c_19984b),
                                            )),
                                        TextSpan(
                                          text: "mypage_headline_end".tr(),
                                        ),
                                      ]),
                                ),
                                const SizedBox(height: 16),

                                const Visibility(
                                  visible: Setting.isUseWallet,
                                    child: SizedBox(height: 12)),
                                Visibility(
                                  visible: Setting.isUseWallet,
                                  child: GestureDetector(
                                    onTap: _pth == "0 ${Setting.appSymbol}"
                                        ? openWelcome
                                        : widget.goWallet,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      height: 80,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(ColorTheme.c_dbdbdb),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'images/icon_wallet.svg',
                                              width: 14,
                                              height: 14,
                                              colorFilter: const ColorFilter.mode(
                                                  Color(ColorTheme.defaultText),
                                                  BlendMode.srcIn),
                                            ),
                                            const SizedBox(width: 3),
                                            const Text(Setting.appSymbol,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1.0,
                                                  fontFamily: Setting.appFont,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(
                                                      ColorTheme.defaultText),
                                                )),
                                          ],
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(_pth,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                height: 1.0,
                                                fontFamily: Setting.appFont,
                                                fontWeight: FontWeight.w600,
                                                color: Color(ColorTheme.c_19984b),
                                              )),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: widget.goPoint,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    height: 80,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(ColorTheme.c_dbdbdb),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'images/icon_point.svg',
                                            width: 14,
                                            height: 14,
                                          ),
                                          const SizedBox(width: 3),
                                          Text("point1".tr(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.0,
                                                fontFamily: Setting.appFont,
                                                fontWeight: FontWeight.w500,
                                                color: Color(
                                                    ColorTheme.defaultText),
                                              )),
                                        ],
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text("$_point P",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              height: 1.0,
                                              fontFamily: Setting.appFont,
                                              fontWeight: FontWeight.w600,
                                              color: Color(ColorTheme.c_19984b),
                                            )),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text("mypage".tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.0,
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w500,
                                      color: Color(ColorTheme.c_767676),
                                    )),
                                const SizedBox(height: 13),
                                const Divider(
                                    thickness: 1,
                                    height: 1,
                                    color: Color(ColorTheme.c_ededed)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        Routes.myInfoPage);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 14, left: 3),
                                    child: Text("my_info1".tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.0,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: goGiftBox,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 14, left: 3),
                                    child: Text("present_giftcorn".tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.0,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        )),
                                  ),
                                ),

                                Visibility(
                                  visible: Setting.isUseWallet,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height:20),
                                      Text("my_wallet".tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.0,
                                            fontFamily: Setting.appFont,
                                            fontWeight: FontWeight.w500,
                                            color: Color(ColorTheme.c_767676),
                                          )),
                                      const SizedBox(height: 13),
                                      const Divider(
                                          thickness: 1,
                                          height: 1,
                                          color: Color(ColorTheme.c_ededed)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamed(
                                            Routes.walletManagementPage,
                                            arguments: WalletManagementPageArguments(
                                                walletType: WalletType.pth),
                                          );
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(
                                              top: 16, bottom: 14, left: 3),
                                          child: Text("my_pth_wallet_manage".tr(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                height: 1.0,
                                                fontFamily: Setting.appFont,
                                                fontWeight: FontWeight.w500,
                                                color: Color(ColorTheme.defaultText),
                                              )),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              "otp_auth".tr(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.2,
                                                fontFamily: Setting.appFont,
                                                fontWeight: FontWeight.w500,
                                                color: Color(ColorTheme.defaultText),
                                              ),
                                            ),

                                            const Spacer(),
                                            GestureDetector(
                                              onTap: setOpt,
                                              behavior: HitTestBehavior.opaque,
                                              child: Container(
                                                height: 28.0,
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(14),
                                                  color: _isOtp ? const Color(ColorTheme.c_4b4b4b) : const Color(ColorTheme.c_19984b),
                                                ),
                                                alignment: Alignment.center,
                                                child: _isOtp
                                                    ? Text(
                                                  "unlink".tr(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    height: 1.2,
                                                    fontFamily: Setting.appFont,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                )
                                                    : Text(
                                                  "linking".tr(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    height: 1.2,
                                                    fontFamily: Setting.appFont,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(ColorTheme.c_ffffff),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 10, bottom: 0),

                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "withdrawal_password".tr(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.2,
                                                  fontFamily: Setting.appFont,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(ColorTheme.defaultText),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: isWithdrawal ? changeWithdrawPw :  showPassword,
                                              behavior: HitTestBehavior.opaque,
                                              child: Container(
                                                height: 28.0,
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(14),
                                                  color: const Color(ColorTheme.c_d1eadb),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  isWithdrawal ? "change".tr(): "setting".tr(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    height: 1.2,
                                                    fontFamily: Setting.appFont,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(ColorTheme.c_4b4b4b),
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

                                const SizedBox(height: 20),
                                Text("app_setting".tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.0,
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w500,
                                      color: Color(ColorTheme.c_767676),
                                    )),
                                const SizedBox(height: 13),
                                const Divider(
                                    thickness: 1,
                                    height: 1,
                                    color: Color(ColorTheme.c_ededed)),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 16, bottom: 14, left: 3),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text("app_version".tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.0,
                                              fontFamily: Setting.appFont,
                                              fontWeight: FontWeight.w500,
                                              color: Color(ColorTheme.defaultText),
                                            )),
                                      ),
                                      Text(_version,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            height: 1.0 ,
                                                            fontFamily: Setting.appFont,
                                                            fontWeight: FontWeight.w400,
                                                            letterSpacing: -0.2,
                                                            color: Color(ColorTheme.c_767676),
                                                          )
                                                        ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18 ,vertical: 20),
                                    child: Container(

                                      width: double.infinity,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(ColorTheme.c_f3f3f3),
                                      ),

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("customer_center".tr(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(

                                                fontSize: 12,
                                                height: 1.0,
                                                fontFamily: Setting.appFont,
                                                fontWeight: FontWeight.w400,
                                                color: Color(ColorTheme.defaultText),
                                              )
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          );
                        }),


                  ),
                ],
              ),
            )
                : const SizedBox(height: 0),
          ),
        ));
  }

  Future<void> goGiftBox() async {
    final result = await Navigator.of(context).pushNamed(Routes.webPage,
        arguments: {
          "url": _urlGiftBox,
          "title": "",
        });

    switch (int.parse(result.toString())) {
      case 0:
        widget.goHome();
        break;
      case 1:
        widget.goPoint();
        break;

      case 2:
        if(!Setting.isUseWallet) {
          widget.goGift();
        }
        break;
      case 3:
        if(Setting.isUseWallet) {
          widget.goGift();
        }
        break;
      default:
        loadData();
        break;
    }
  }

  void openWelcome() {
    Navigator.of(context).pushNamed(Routes.welcomePage);
  }

  Future<void> _onRefresh() async {
    await loadData();
  }

  void setOpt() async {
    if (_isOtp) {
      CommonFunction.showBottomSheet(
        context: context,
        isDismissible: true,
        child: OtpConfirmDialog(
          isRemoveOtp: true,
          onRemove: () async {
            _isOtp = await CommonFunction.getPreferencesBoolean(PreferenceKey.isOtp) ?? false;
            setState(() {});
          },
        ),
      );
    } else {
      var result = await Navigator.pushNamed(context, Routes.otpAuthPage);
      if (result != null && result is bool) {
        if (result) {
          _isOtp = await CommonFunction.getPreferencesBoolean(PreferenceKey.isOtp) ?? false;
          setState(() {});
        }
      }
    }
  }

  void changeWithdrawPw() {
    Navigator.of(context).pushNamed(Routes.withdrawalPasswordPage, arguments: {'type': 3}).whenComplete(() async{

      await loadData();
    });
  }

  Future<void> setWithdrawPw() async {

  }

  void showPassword() {
    CommonFunction.showBottomSheet(
        context: context,
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

                                   int type;
                                   if(result == 1) {
                                      type = 3;
                                   }else if(result == 0){
                                     type = 1;
                                   }else {
                                     type = -1;
                                   }

                                   if(type == -1) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }
                                      return;
                                   }else {
                                     if (mounted) {
                                       Navigator.of(context).pop();
                                       Navigator.of(context).pushNamed(
                                           Routes.withdrawalPasswordPage, arguments: {"type": type})
                                           .whenComplete(() async {
                                         loadData();
                                       });
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


}
