import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';

class AccountLinkStart extends StatefulWidget {
  const AccountLinkStart({Key? key}) : super(key: key);

  @override
  State<AccountLinkStart> createState() => _AccountLinkStartState();
}

class _AccountLinkStartState extends State<AccountLinkStart> {

  late final TextEditingController _idTextController;

  String _id = "";
  String _joinType = "";
  String _from = "";
  Map<String, dynamic>? _arguments;


  @override
  void initState() {

    super.initState();
    _idTextController = TextEditingController();
    _idTextController.text = "";

  }
  @override
  void dispose() {
    _idTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
     _from = arguments["from"] ?? "";
    _joinType = arguments["joinType"] ?? "" ;
    _id = arguments["id"] ?? "" ;
    if(_id != "") {
      _idTextController.text = _id;
      _arguments = arguments;
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text("wait".tr(),
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
                Text( _joinType == "existId" ? "account_link_start_subtitle1".tr(): "account_link_start_subtitle".tr(),
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

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text("id".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.0 ,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w700,
                                        color: Color(ColorTheme.defaultText),
                                      )
                                    ),
                ),
                const SizedBox(height: 6),
                InputTextField(
                  enabled: false,
                  controller: _idTextController,
                ),

                const Spacer(),
              BtnBorderAppColor(
                onTap: create,
                text: "create_account".tr(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: BtnFill(
                  onTap: next,
                  text: _joinType == "existId" ? "login".tr() : "next".tr(),
          ),
              )

              ],
            ),
          ),
        )
    );
  }
  void create() {
    if(mounted) {
      if(_from == "snsJoinCertDone") {
        dynamic argument;
        argument = _arguments;
        argument?.addAll({"joinType": "snsJoinCertDone"});
        Navigator.of(context).pushNamed(
            Routes.signupIdPage, arguments: argument);
      }else {
        Navigator.of(context).pushNamed(
            Routes.signupIdPage, arguments: _arguments);
      }
    }
  }

  void next() {
    if(!mounted) {
      return;
    }
    if(_joinType == "existId") {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.loginPage,
              (route) => false,
              arguments: {"id": _id}
      );
    }else {
      Navigator.of(context).pushNamed(Routes.accountLinkSelect, arguments: _arguments);
    }


  }
}
