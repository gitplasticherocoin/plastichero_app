import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/checkbox.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _checkAll = false ;
  bool _isNext = false;
  bool _checkService = false;
  bool _checkPrivacy = false;

  String _certUserInfo = "";
  String _snsInfo = "";
  String _from = "";
  String _param ="";

  @override
  Widget build(BuildContext context) {
        final Map<String, dynamic>? arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        if(arguments!= null) {
          _certUserInfo = arguments["cert_user_info"] ?? "";
          _snsInfo = arguments["sns_info"] ?? "";
          _param = arguments["param"] ?? "";
          _from = arguments["from"] ?? "";


        }
    return Scaffold(
      appBar: DefaultToolbar(
        isBackButton: true,
        onBackPressed: () {
          if( _from == "snsJoinCertDone") {
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.loginPage, (route) => false);
          }else if (_from == "snsJoinCancel"){
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.loginPage, (route) => false);

          }else {
            Navigator.of(context).pop();
          }
        },
        centerTitle: false,
        titleText: "member_join".tr(),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal:24 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40,),
              Text("signup_title".tr(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    height: 30 / 22 ,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w700,
                                    color: Color(ColorTheme.defaultText),
                                  )
                                ),
              const SizedBox(height: 10,),
              Text("signup_subtitle".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 18 /14 ,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  )
                                ),
              const SizedBox(height: 24,),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _checkAll = _checkAll == true ? false: true;
                    if(_checkAll) {
                      _checkPrivacy = true;
                      _checkService = true;
                      _isNext = true;
                    }else {
                      _checkPrivacy = false;
                      _checkService = false;
                      _isNext = false;
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CheckBox02(
                      value: _checkAll,
                      onChanged: (value) {
                        setState(() {
                          _checkAll = value;
                          if(_checkAll) {
                            _checkPrivacy = true;
                            _checkService = true;
                            _isNext = true;
                          }else {
                            _checkPrivacy = false;
                            _checkService = false;
                            _isNext = false;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text("artcle_all_agree".tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.0 ,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        )
                                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12,),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(ColorTheme.c_ededed),
              ),
              const SizedBox(height: 15,),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _checkService = _checkService == true ? false: true;
                        if(_checkService == false) {
                          _isNext = false;
                          _checkAll = false;
                        }else if(_checkPrivacy && _checkService) {
                          _checkAll = true;
                          _isNext = true;
                        }
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const SizedBox(width:5),
                        SvgPicture.asset("images/icon_check_g_m.svg", width: 11.7, height:8.4,
                        colorFilter: _checkService ?
                        const ColorFilter.mode(Color(ColorTheme.appColor), BlendMode.srcIn):
                        null),
                        const SizedBox(width:15),

                        Text(
                            "${"essential".tr()} ${"service_article".tr()}"
                            ,
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

                      ],
                    ),
                  ),
                  //56 //24 //32
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final result = await  Navigator.of(context).pushNamed(Routes.articlePage , arguments: {"tabIndex": 0});
                      final res = result  as String ;
                      if(res == "check1") {
                        setState(() {
                          _checkService = true;
                        });
                        checkIsCheckAll();
                      }

                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color(ColorTheme.c_f3f3f3),
                      ),
                      child: Text("view".tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.0 ,
                                            fontFamily: Setting.appFont,
                                            fontWeight: FontWeight.w500,
                                            color: Color(ColorTheme.defaultText),
                                          )
                                        ),
                    ),
                  )

                ],
              ),
              const SizedBox(height: 12,),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _checkPrivacy = _checkPrivacy == true ? false: true;
                        if(_checkPrivacy == false) {
                          _checkAll = false;
                          _isNext = false;
                        }else if(_checkPrivacy && _checkService) {
                          _checkAll = true;
                          _isNext = true;
                        }
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const SizedBox(width:5),
                        SvgPicture.asset("images/icon_check_g_m.svg", width: 11.7, height:8.4, colorFilter: _checkPrivacy ?
                        const ColorFilter.mode(Color(ColorTheme.appColor), BlendMode.srcIn):
                        null),
                        const SizedBox(width:15),

                        Text(
                            "${"essential".tr()} ${"privacy_article".tr()}"
                            ,
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

                      ],
                    ),
                  ),
                  //56 //24 //32
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.of(context).pushNamed(Routes.articlePage , arguments: {"tabIndex": 1});

                      final res = result ?? "";

                      if(res == "check2") {
                        setState(() {
                          _checkPrivacy = true;
                        });
                        checkIsCheckAll();
                      }



                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color(ColorTheme.c_f3f3f3),
                      ),
                      child: Text("view".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.0 ,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w500,
                            color: Color(ColorTheme.defaultText),
                          )
                      ),
                    ),
                  )

                ],
              ),

              const Spacer(),

              BtnFill(
                isEnable:  _isNext,
                onTap: next,
                width: double.infinity,
                height: 54,
                text: _from == "" ? "next".tr() : "complete".tr(),

              ),
              const SizedBox(height: 24,)

            ],

          ),
        ),
      )
    );
  }

  void checkIsCheckAll() {
    bool checkAll = false;
    if(_checkPrivacy && _checkService) {
      checkAll = true;
    }
    setState(() {
      _checkAll = checkAll;
      _isNext = _checkAll;
    });
  }
  void next()  {
    if( _from == "snsJoinCertDone") {
      snsSignDoneHandler();
    }else if (_from == "snsJoinCancel") {
      snsSignDoneHandler();
    }else {
      Navigator.of(context).pushNamed(
          Routes.signupSmsPage, arguments: {"certType": CertType.join});
    }
  }

  Future<void> snsSignDoneHandler() async {
    if(!mounted) {
      return;
    }

    var manager = ApiManagerMember();
    dynamic json;
    try {
      json = await manager.snsJoinDone(certUserInfo: _certUserInfo, snsInfo: _snsInfo, param:_param);

      String status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {


        dynamic result = json[ApiParamKey.result];
        // print("result : $result");
        dynamic data = result["data"];
        // print("data : $data");
        // print(data.runtimeType);

        final jsonData = jsonDecode(data);


        final String dataCode = jsonData["code"] ?? "";
        // print("dataCode : $dataCode");

        if ( dataCode.isNotEmpty && dataCode != "") {

          // print("jsonData : $jsonData");

          final memberInfo = MemberInfo.fromJson(jsonData);
          // print("memberInfo from data : $memberInfo");
          loginHandler(memberInfo);

          if(mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.signupDonePage, (route) => false);
          }

        }else {
          if(context.mounted) {
            await CheckResponse.checkErrorResponse(context, json);
          }
          //final memberInfo = MemberInfo.fromJson(result);
          // print("memberInfo from result : $memberInfo");
          // loginHandler(memberInfo);
          // if(mounted) {
          //   Navigator.of(context).pushNamedAndRemoveUntil(
          //       Routes.signupDonePage, (route) => false);
          // }

        }

        return;
      }

    } catch(e) {
        debugPrint(e.toString());
    }

  }

  // void loginHandler(String code) {
  //   CommonFunction.setPreferencesString(PreferenceKey.sessionCode, code);
  //   Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
  // }

  /// 로그인
  // getLoginTypeFromLoginPlatform()
  Future<void> loginHandler(MemberInfo memberInfo ) async{
    if(memberInfo.code == null) {
      return;
    }
    await CommonFunction.setPreferencesString(PreferenceKey.sessionCode, memberInfo.code ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.email, memberInfo.mbEmail ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginId,memberInfo.mbId ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginName, memberInfo.mbName ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginPhone, memberInfo.mbHp ?? "");
    await CommonFunction.setPreferencesString(
        PreferenceKey.snsIsJoin, memberInfo.isJoin ?? "");

  }

}
