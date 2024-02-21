import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/routes.dart';

import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:provider/provider.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({Key? key}) : super(key: key);

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  late final TextEditingController _nameTextController;
  late final TextEditingController _phoneTextController;
  bool _isEnableConfirm = false;
  String name = "";
  String phone = "";
  String _certUserInfo = "";
  String code = "";
  String from = "";
  MyinfoProvider? myInfoPovider;



  @override
  void initState() {
    super.initState();
    _nameTextController = TextEditingController();
    _phoneTextController = TextEditingController();
    myInfoPovider = Provider.of<MyinfoProvider>(context, listen: false);
    setState(() {
      _isEnableConfirm = true;
    });
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _phoneTextController.dispose();
    myInfoPovider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        final Map<String, dynamic> arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        name = arguments["name"] ?? "";
        phone = arguments["phone"] ?? "";
        from = arguments["from"] ?? "";

        _certUserInfo = arguments["cert_user_info"] ?? "";

        _nameTextController.text = name;
        _phoneTextController.text = phone;
    return Scaffold(
        appBar: DefaultToolbar(
          titleText: "change_phone".tr(),
          isBackButton: true,
          onBackPressed: goBack,
          centerTitle: false,
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 31,
                ),
                Text("change_phone_title".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w700,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(height: 6),
                Text("change_phone_subtitle".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(height: 24),
                Text("name".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w700,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(
                  height: 6,
                ),
                InputTextField(
                  enabled: false,
                  controller: _nameTextController,
                  hintText: "name_placeholder".tr(),
                  isOutline: false,
                ),
                const SizedBox(height: 16),
                Text("phone".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w700,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(
                  height: 6,
                ),
                InputTextField(
                  enabled: false,
                  controller: _phoneTextController,
                  hintText: "phone_placeholder".tr(),
                  isOutline: false,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    top: 24,
                  ),
                  child: BtnFill(
                    isEnable: _isEnableConfirm,
                    text: "change".tr(),
                    onTap: confirm,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void confirm() {
    changeAccount();

  }

  void goBack() {
    Navigator.of(context).pop();
  }

  void goMainPage() {
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainPage , (route) => false);
  }

  void checkIsEnableConfirm() {}

  Future<void> save() async {
    //await CommonFunction.setPreferencesString(PreferenceKey.loginName,name);
    await CommonFunction.setPreferencesString(PreferenceKey.loginPhone, phone);

  }

  void changeAccount() async {
    final code = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";

    if(!mounted) {
      return;
    }
    if (code == "") {
      return;
    }
    unFocus();
    var manager = ApiManagerMember();
    dynamic json;

    try {
      json = await manager.changeAccount(
          type: CertChangeType.phone.type,
          certUserInfo: _certUserInfo,
          code: code ,

      );
      String status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {
        if(mounted) {
          save();
          myInfoPovider?.callRefresh();
          if(from == "") {
            goBack();
          }else {
            goMainPage();
          }
        }
      }else {
        if(context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    }catch(e) {
      debugPrint(e.toString());
    }
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }
}
