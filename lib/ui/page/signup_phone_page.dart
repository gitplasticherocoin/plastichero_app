import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';

import '../../constants/color_theme.dart';
/// 소설 로그인 했을 경우에 이름 휴대폰 번호 확인 하고 끝
class SignUpPhonePage extends StatefulWidget {
  const SignUpPhonePage({Key? key}) : super(key: key);

  @override
  State<SignUpPhonePage> createState() => _SignUpPhonePageState();
}

class _SignUpPhonePageState extends State<SignUpPhonePage> {
  late final TextEditingController _idTextController;
  late final TextEditingController _phoneController;

  String _username = "";
  String _userPhone = "";
  late Map<String, dynamic> _argument;

  @override
  void initState() {
    super.initState();
    _idTextController = TextEditingController();
    _phoneController = TextEditingController();

    _idTextController.text = "이름";
    _phoneController.text = "휴대폰 번호";
  }

  @override
  void dispose() {
    _idTextController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    _username = arguments["user_name"] ?? "";
    _userPhone = arguments["phone_no"] ?? "" ;
    _argument = arguments;

    if(_username.isNotEmpty && _userPhone.isNotEmpty ) {
      _idTextController.text = _username;
      _phoneController.text = _userPhone;
    }


    return Scaffold(
        appBar: DefaultToolbar(
          isBackButton: true,
          onBackPressed: () {
            Navigator.of(context).pop();
          },
          centerTitle: false,
          titleText: "member_join".tr(),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text("signup_phone_title".tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 30 / 22,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(
                  height: 6,
                ),
                Text("signup_phone_subtitle".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 18 / 14,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.c_666666),
                    )),
                const SizedBox(
                  height: 24,
                ),
                Text("name".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(
                  height: 6,
                ),
                InputTextField(
                  enabled: false,
                  controller: _idTextController,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text("phone".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(
                  height: 6,
                ),
                InputTextField(
                  enabled: false,
                  controller: _phoneController,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    top: 24,
                  ),
                  child: BtnFill(
                    text: "next".tr(),
                    onTap: confirm,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void confirm() {
    if(mounted) {
      Navigator.of(context).pushNamed(
          Routes.signupIdPage, arguments: _argument);
    }
  }
}
