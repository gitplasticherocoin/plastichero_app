import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/util/common_function.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      nextPage();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(ColorTheme.appColor),
      body: Center(
        child: SvgPicture.asset("images/logo_w.svg", width: 218.6, height: 33),
      ),
    );
  }

  void nextPage() async {
    final sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode);
    if(sessionCode != null && sessionCode.isNotEmpty && sessionCode != "") {
        await loginHandler(sessionCode);
       goMainPage();
    }else {
      goLoginPage();
    }

  }

  void goMainPage() {
    Navigator.pushReplacementNamed(context, Routes.mainPage);
    return;
  }

  void goLoginPage() {
    Navigator.pushReplacementNamed(context, Routes.loginPage);
    return;
  }

  Future<void> loginHandler(String sessionCode) async {
    final fcmKey = await CommonFunction.getPreferencesString(PreferenceKey.fcmKey) ?? "";
    var manager = ApiManagerMember();
    dynamic json;
    try {
      json = await manager.simpleLogin(code: sessionCode, fcmKey: fcmKey);
      final status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {

        final memberInfo = json[ApiParamKey.result];
        await CommonFunction.setPreferencesString(
            PreferenceKey.sessionCode, memberInfo.code ?? "");
        await CommonFunction.setPreferencesString(
            PreferenceKey.email, memberInfo.mbEmail ?? "");
        await CommonFunction.setPreferencesString(
            PreferenceKey.loginId, memberInfo.mbId ?? "");
        await CommonFunction.setPreferencesString(
            PreferenceKey.loginName, memberInfo.mbName ?? "");
        await CommonFunction.setPreferencesString(
            PreferenceKey.loginPhone, memberInfo.mbHp ?? "");
        await CommonFunction.setPreferencesString(
            PreferenceKey.snsIsJoin, memberInfo.isJoin ?? "");

      }else {
        if(context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }





    }catch(e) {
      debugPrint(e.toString());
    }
  }
}
