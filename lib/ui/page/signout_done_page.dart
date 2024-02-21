import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/util/common_function.dart';


class SignOutDonePage extends StatefulWidget {
  const SignOutDonePage({Key? key}) : super(key: key);

  @override
  State<SignOutDonePage> createState() => _SignOutDonePageState();
}

class _SignOutDonePageState extends State<SignOutDonePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body : SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 23.9),
                    SvgPicture.asset("images/logo.svg",
                        width:127,
                        height: 20),
                  ],
                )
                ,
              ),

              const SizedBox(height: 84,),
              Text("sign_out_done_title".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.0 ,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w700,
                                    color: Color(ColorTheme.defaultText),
                                  )
                                ),
              const SizedBox(height: 8),
              Text("sign_out_done_subtitle".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0 ,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  )
                                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                child: BtnFill(
                  isEnable: true,
                  text: "confirm".tr(),
                  onTap: confirm,
                ),
              )


            ],
          )

        )
    );
  }

  void confirm() {
      logout();
  }

  void logout() async {
    String loginType = await CommonFunction.getPreferencesString(PreferenceKey.loginType) ?? "";

    switch (loginType) {
      case "apple":
        break;
      case "naver":
      // print("naver logout");
        await FlutterNaverLogin.logOut();
        break;
      case "google":
        await GoogleSignIn().signOut();
        break;
      default:
        break;
    }

    await CommonFunction.setPreferencesString(PreferenceKey.loginType, "");
    await CommonFunction.setPreferencesString(PreferenceKey.sessionCode, "");
    await CommonFunction.setPreferencesString(PreferenceKey.email, "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginId, "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginName, "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginPhone, "");
    await CommonFunction.setPreferencesString(PreferenceKey.snsEmail, "");
    await CommonFunction.setPreferencesString(PreferenceKey.snsIdentifier, "");

    Navigator.of(context).pushNamedAndRemoveUntil(Routes.loginPage, (route) => false);
  }
}
