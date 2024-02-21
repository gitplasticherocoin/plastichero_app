import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';

class FindIdPage extends StatefulWidget {
  const FindIdPage({Key? key}) : super(key: key);

  @override
  State<FindIdPage> createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
   String _finedId = "";
   String _param = "";

  @override
  Widget build(BuildContext context) {
        final Map<String, dynamic> arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        _finedId = arguments["id"] ?? "";
        _param = arguments["param"] ?? "";
    return Scaffold(
        appBar: DefaultToolbar(
          titleText: "find_id".tr(),
          isBackButton: true,
          onBackPressed: () {
            Navigator.of(context).pop();
          },
          centerTitle: false,
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text("find_id_description".tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  height: 48,
                  padding: const EdgeInsets.only(top: 15, bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(ColorTheme.c_ededed),
                  ),
                  child: Text(_finedId,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.0,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w700,
                        color: Color(ColorTheme.defaultText),
                      )),
                ),
                const SizedBox(
                  height: 24,
                ),
                BtnFill(
                  isEnable: true,
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.loginPage,
                            (route) => false , arguments: {"id": _finedId});
                  },
                  text: "login".tr(),
                ),
                const SizedBox(
                  height: 12,
                ),
                BtnBorderAppColor(
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.passwordChangePage ,
                      ModalRoute.withName(Routes.loginPage),
                      arguments: {"param": _param}
                    );
                  },
                  text: "change_password".tr(),
                )
              ],
            ),
          ),
        ));
  }
}
