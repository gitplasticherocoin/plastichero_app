import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';


class SignUpDonePage extends StatefulWidget {
  const SignUpDonePage({Key? key}) : super(key: key);

  @override
  State<SignUpDonePage> createState() => _SignUpDonePageState();
}

class _SignUpDonePageState extends State<SignUpDonePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: DefaultToolbar(
        //   isBackButton: false,
        //   centerTitle: false,
        //   titleText: "signup_done".tr(),
        // ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text("signup_done".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        height: 1.0 ,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w700,
                                        color: Color(ColorTheme.defaultText),
                                      )
                                    ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Text("signup_done_title".tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 30 / 22,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w700,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(
                  height: 6,
                ),
                Text("signup_done_subtitle".tr(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      letterSpacing: -0.21,
                      fontSize: 14,
                      height: 18 / 14,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    top: 24,
                  ),
                  child: BtnFill(
                    text: "signup_done_confirm_button".tr(),
                    onTap: confirm,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void confirm() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
  }
}
