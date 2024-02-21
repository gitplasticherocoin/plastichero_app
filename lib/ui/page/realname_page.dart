import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';



class RealnamePage extends StatefulWidget {
  const RealnamePage({Key? key}) : super(key: key);

  @override
  State<RealnamePage> createState() => _RealnamePageState();
}

class _RealnamePageState extends State<RealnamePage> {
  final GlobalKey webViewKey = GlobalKey();
  String sessionCode = '';
  InAppWebViewController? webViewController;
  bool _isFirstLoading = true;

  CertType _certType = CertType.undefined;
  CertChangeType _certChangeType = CertChangeType.undefined;
  String _snsInfo = "";
  String _param = "";
  String _findType = "";
  String? _sessionCode ;
  String _from = "";
  late final LoadingDialog loadingDialog;

  @override
  void initState() {

    print("initState realname Page");
    super.initState();
    loadingDialog = LoadingDialog(context: context);
    init();

    print("realname_page");
  }

  void init() async {
   _sessionCode =  await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
   Future.delayed(const Duration(milliseconds: 500), () {
     setState(() {
       _isFirstLoading = false;
     });
   });
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    // print(arguments);
    _certType = arguments['certType'] ?? CertType.undefined;
    _snsInfo = arguments['snsInfo'].toString().trim();
    _param = arguments['param'].toString().trim();
    _findType = arguments['findType'].toString().trim();
    _certChangeType = arguments['type'] ?? CertChangeType.undefined;
    _from = arguments['error'] ?? "";



    return Scaffold(
      appBar: DefaultToolbar(
        titleText: "realname".tr(),
        isBackButton: true,
        onBackPressed: () {
          Navigator.of(context).pop();
        },
        centerTitle: false,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: buildBody()
        ),
      )
    );
  }




  String makeUrl() {
   const String urlApiHeader = (Setting.isTest) ? Setting.connectUrlDev : Setting.connectUrl;
   if (_certType == CertType.platform){
     return "$urlApiHeader/cert/start.php?ret_url=${_certType
         .retUrl}&param=$_param";
   }else if(_certType == CertType.login) {
      return "$urlApiHeader/cert/start.php?ret_url=${_certType
          .retUrl}&session_code=$_sessionCode";
    } else if(_certType == CertType.sns) {
     return "$urlApiHeader/cert/start.php?ret_url=${_certType
         .retUrl}&sns_info=$_snsInfo&param=$_param";
    } else if (_certType == CertType.find) {
     return "$urlApiHeader/cert/start.php?ret_url=${_certType
         .retUrl}";
   } else if(_certType == CertType.changePhone) {
     return "$urlApiHeader/cert/start.php?ret_url=${_certType
         .retUrl}&code=$_sessionCode";
   } else if(_certType == CertType.changePaass) {
     return "$urlApiHeader/cert/start.php?ret_url=${_certType
         .retUrl}&code=$_sessionCode";
    }else {
      return "$urlApiHeader/cert/start.php?ret_url=${_certType
          .retUrl}";
    }

  }


  Widget buildBody() {
    final url =  makeUrl();
    // print("url : $url");

    if(_isFirstLoading) {
      return Container(
        color: Colors.white
      );
    }else {
      return InAppWebView(

        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          applicationNameForUserAgent: "PlasticheroApp", // 지갑앱에서도 동일하게 사용하면 됩니다.
        ),
        onLoadStop: (InAppWebViewController controller,_) {
          // Future.delayed(const Duration(milliseconds: 500) , () {
          //   loadingDialog.hide();
          // });
        },
        onLoadStart:  (InAppWebViewController controller,_) {

          // loadingDialog.show();
        },


        onWebViewCreated: (controller) {
          webViewController = controller;

          controller.addJavaScriptHandler(
              handlerName: "loading",
              callback: (args) {
                final result = args[0];
                final value = json.decode(result);
                if (value["status"] == "show") {
                  loadingDialog.show();
                } else if (value["status"] ==
                    "hide") {
                  loadingDialog.hide();
                }
              });


          controller.addJavaScriptHandler(
              handlerName: "success", callback: (args) {
            final result = args[0];
            final value = json.decode(result);
            // print("===success : $value");


            if(_certType == CertType.platform) {
              //로그인시 본인인증 안된 사람들일경우 바로 로그인 시킵니다.


              MemberInfo memberInfo = MemberInfo.fromJson(value);
              loginHandler(memberInfo);



              //Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
              return;
            } else if (_certType == CertType.sns) {
              // print("sns 본인인증");
              //SNS 본인인증 일경우
              //{cert_user_info: N1hDYXBhYlYxNUgrSi85SkFiZ0lENFhRU2Y0emMveTk3V09GWkZoc0RubnFnQUx6UUZkYlk4U294M0JlU2ZJMU9sbDdvNWV3M3JETnJSSm9McmZSM29KYlB2bHpDNVB6aEFXSGVmR1Z1YmNCdVh2ZUtXVEZvOS92SEJpeWlpajc3L1VVMjFUTVVJNmhJazdRQkdWQld3a2NYM09zcjZtd29YYkVrMGt6TlRZPTo6/SXjJhEUy/oBMemTTqBzig==, sns_info: eTNJc2FBWktxaFdtbHd2RGwzcTJiNlhYTG4vSUIxcE9YN1JaTTVlLzgxcTI4aElYTVlNMlZxL0pGd3RUMjVndU01d2Rya0E1QVltZ3grcGF6WFFWbWhuZVBuejRXZXhwdkMzREJ5RlhMSUU9OjpBYCfiLw4hbRbN2geyuWYf, id: dummy3, msg: 플랫폼 정보로 가입 계정(dummy3)이 존재함, type: cert_res_sns_login}
              final String id = value["id"] ?? "";
              final String certUserInfo = value["cert_user_info"] ?? "";
              final String snsInfo = value["sns_info"] ?? "";

              if (id != "" ) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.accountLinkStart,
                    ModalRoute.withName(Routes.loginPage),
                    arguments: {
                      "cert_user_info" : certUserInfo,
                      "id": id,
                      "sns_info":snsInfo,
                      "param": _param,
                      "from": "snsJoinCertDone"
                    });
                return;
              // }else if (code != "" ) {
              //   //로그인
              //   CommonFunction.setPreferencesString(PreferenceKey.sessionCode, code);
              //   Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
              //   return;

              }else {
                // //회원가입 시켜줘야 하는데.

                if(certUserInfo != "" && snsInfo != "" ) {
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.signupPage,
                          (route) => false,
                      arguments: {
                      "cert_user_info" : certUserInfo,
                      "sns_info":snsInfo,
                        "param": _param,
                      "from": "snsJoinCertDone"
                      }
                  );
                }
              }

            }else if(_certType == CertType.find) {

              if(_findType == "id") {


                 Navigator.of(context).pushNamedAndRemoveUntil(Routes.findIdPage,
                 ModalRoute.withName(Routes.loginPage),
                 arguments: value);

              }else if(_findType == "pass") {
                //TODO : 본인인증페이지에서 비밀번호 변경 페이지로
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.passwordChangePage ,
                    ModalRoute.withName(Routes.loginPage),
                arguments: value);

              }else {
                Navigator.of(context).pop();
              }





              return;
            }else if(_certType == CertType.join) {
              //{user_name: 김일곱, phone_no: 010-1234-7777, birth_day: 19801207, msg: 정상처리, type: cert_res_signup, cert_user_info: NVNROXVqWVhaVFNzVUZzdlc3SjRkOWFZSjBwenNoNE53dDZZZzdNa24yeUNjMkgzelFPT3JYZlBxdkYwTm1uVHVCbTRiUmtOS2Fnd2M2V2NIald6dlp4YkIza3JRczQ2RHExb2JjUk5KeGQ3SnhGa2s3VlBUSUgyVWxOeWpGUDB4WFZQc1ZQN0FudUxRS2Fjd1VHYXFibVNkcExwakppd2lRTkRjWWZDRnZ3PTo61AnUxGCp5hT43nbTmOnt6g==}

              final String id = value["id"] ?? "";

              value["joinType"] = "existId";

              if(id != "") {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.accountLinkStart,
                    ModalRoute.withName(Routes.signupPage),
                    arguments: value);

              }else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.signupPhonePage,
                    ModalRoute.withName(Routes.signupPage),
                    arguments: value);
              }



            }else if(_certType == CertType.changePhone) {

                  if (_from !="") {
                    value["from"] = _from;
                  }
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.changePhonePage,
                      ModalRoute.withName(Routes.mainPage),
                      arguments: value);



            }else if(_certType == CertType.changePaass) {


                  value["from"] = "AccountCert";

                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.passwordChangePage,
                      ModalRoute.withName(Routes.mainPage),
                      arguments: value);


            }


            // {user_name: 이름, phone_no: 010-1234-1234, msg: 정상처리}
            // {"user_name":"\ub0a8\uacbd\ud0dc","phone_no":"010-3444-3927","birth_day":"19731203","msg":"\uc815\uc0c1\ucc98\ub9ac","type":"cert_res_signup"}





          });

          controller.addJavaScriptHandler(
              handlerName: "fail", callback: (args) {
            final result = args[0];
            final msg = result['msg'] ?? "" ;

            if(msg != "" && mounted) {
              CommonFunction.showToast(context, msg);
            }

            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).pop();
            });
          });

          controller.addJavaScriptHandler(handlerName: "cancel", callback: (args) {
            Navigator.of(context).pop();
          });

        },
        // onLoadStop: (_, __) {
        //   setState(() {
        //     isFirstLoading = false;
        //   });
        // },
      );
    }
  }

  Future<void> snsJoin( String certUserInfo,  String snsInfo) async {
    var manager = ApiManagerMember();
    dynamic json;
    try {
       json =  await manager.accountLinkCancel(certUserInfo: certUserInfo, snsInfo: snsInfo);
        String status = json[ApiParamKey.status];
        if(status == ApiParamKey.success) {
          // 회원연동 안하고 가입
          if(mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.signupDonePage, (route) => false);
          }
        }else {
          if(context.mounted) {
            await CheckResponse.checkErrorResponse(context, json);
          }
        }
    }catch (e) {
        debugPrint(e.toString());
    }
  }

  /// 로그인
  // getLoginTypeFromLoginPlatform()
  Future<void> loginHandler(MemberInfo memberInfo) async {
    if (memberInfo.code == null) {
      return;
    }

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


    // print("로그인 ==================");
    //
    // print(memberInfo.code);
    // print(memberInfo.mbEmail);
    // print(memberInfo.mbId);
    // print(memberInfo.mbName);
    // print(memberInfo.mbHp);
    // print("로그인 ==================");

    //CommonFunction.setPreferencesString(PreferenceKey.loginType, loginType);
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
    }
  }
}
