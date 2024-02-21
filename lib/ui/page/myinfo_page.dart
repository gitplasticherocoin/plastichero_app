import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/confirm_dialog.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:provider/provider.dart';

class MyInfoPage extends StatefulWidget {
  const MyInfoPage({Key? key}) : super(key: key);

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  String _email = "";
  String _name = "";
  String _id = "";
  String _phone = "";
  String _loginType = "";

  MyinfoProvider? myinfoProvider;

  String _snsIsJoin = "N";
  late final LoadingDialog loadingDialog;
  bool _isLoad = false;
  @override
  void initState() {
    super.initState();
    myinfoProvider = Provider.of<MyinfoProvider>(context, listen: false)
      ..addListener(loadData);
    loadingDialog = LoadingDialog(context: context);


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadData();
    });

  }

  @override
  void dispose() {
    if (myinfoProvider != null) {
      myinfoProvider?.removeListener(loadData);
    }
    super.dispose();
  }

  void loadData() async {
    String code =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";
    String loginType =
        await CommonFunction.getPreferencesString(PreferenceKey.loginType) ??
            "";

    var manager = ApiManagerMember();
    dynamic json;

    try {
      loadingDialog.show();
      json = await manager.getSettingInfo(code: code);

      final status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        final result = json[ApiParamKey.result];

        final memberInfo = MemberInfo.fromJson(result);
        setState(() {
          _email = memberInfo.mbEmail;
          _id = memberInfo.mbId;
          _phone = memberInfo.mbHp;
          _name = memberInfo.mbName;
          _snsIsJoin = memberInfo.isJoin ?? "N";
          _loginType = loginType;
          _isLoad = true;
        });
      } else {
        String email =
            await CommonFunction.getPreferencesString(PreferenceKey.email) ??
                "";
        String id =
            await CommonFunction.getPreferencesString(PreferenceKey.loginId) ??
                "";
        String name = await CommonFunction.getPreferencesString(
                PreferenceKey.loginName) ??
            "";
        String phone = await CommonFunction.getPreferencesString(
                PreferenceKey.loginPhone) ??
            "";

        String isJoin = await CommonFunction.getPreferencesString(
                PreferenceKey.snsIsJoin) ??
            "";

        setState(() {
          _email = email;
          _id = id;
          _phone = phone;
          _name = name;
          _loginType = loginType;
          _snsIsJoin = isJoin;
          _isLoad = true;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadingDialog.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DefaultToolbar(
          onBackPressed: () {
            //Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
            Navigator.of(context).pop();
          },
          isBackButton: true,
          titleText: "my_info1".tr(),
          centerTitle: false,
        ),
        body: SafeArea(
          child:

          Visibility(
            visible: _isLoad,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("my_profile_info".tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w700,
                          color: Color(ColorTheme.c_767676),
                        )),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(ColorTheme.c_ededed),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16, bottom: 15),
                    child: Row(
                      children: [
                        Text("name".tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.0,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w700,
                              color: Color(ColorTheme.defaultText),
                            )),
                        const Spacer(),
                        Text(_name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.0,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w500,
                              color: Color(ColorTheme.defaultText),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16, bottom: 15),
                    child: Row(
                      children: [
                        Text("phone".tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.0,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w700,
                              color: Color(ColorTheme.defaultText),
                            )),
                        const Spacer(),
                        Text(_phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.0,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w500,
                              color: Color(ColorTheme.defaultText),
                            )),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: changePhone,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(ColorTheme.c_d1eadb)),
                            child: Text("change".tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.0,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w500,
                                  color: Color(ColorTheme.c_4b4b4b),
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _loginType == "plastichero",
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 15),
                          child: Row(
                            children: [
                              Text("id".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w700,
                                    color: Color(ColorTheme.defaultText),
                                  )),
                              const Spacer(),
                              Text(_id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 15),
                          child: Row(
                            children: [
                              Text("password".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w700,
                                    color: Color(ColorTheme.defaultText),
                                  )),
                              const Spacer(),
                              const Text("******",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  )),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: changePassword,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: const Color(ColorTheme.c_d1eadb)),
                                  child: Text("change".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.0,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.c_4b4b4b),
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 15),
                          child: Row(
                            children: [
                              Text("email".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w700,
                                    color: Color(ColorTheme.defaultText),
                                  )),
                              const Spacer(),
                              Text(_email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  )),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(Routes.changeEmailPage)
                                      .whenComplete(() {
                                    loadData();
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: const Color(ColorTheme.c_d1eadb)),
                                  child: Text("change".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.0,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.c_4b4b4b),
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Visibility(
                  //     visible: _loginType != "plastichero",
                  //     child: Column(children: [
                  //       Container(
                  //         width: double.infinity,
                  //         padding: const EdgeInsets.symmetric(vertical: 8),
                  //         child: Text("asset_protection".tr(),
                  //             maxLines: 1,
                  //             overflow: TextOverflow.ellipsis,
                  //             textAlign: TextAlign.start,
                  //             style: const TextStyle(
                  //               fontSize: 13,
                  //               height: 1.0,
                  //               fontFamily: Setting.appFont,
                  //               fontWeight: FontWeight.w700,
                  //               color: Color(ColorTheme.c_767676),
                  //             )),
                  //       ),
                  //
                  //
                  //       const Divider(
                  //         height: 1,
                  //         thickness: 1,
                  //         color: Color(ColorTheme.c_ededed),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 22, bottom: 21),
                  //         child: Row(
                  //           children: [
                  //             Text("easy_login".tr(),
                  //                 maxLines: 1,
                  //                 overflow: TextOverflow.ellipsis,
                  //                 style: const TextStyle(
                  //                   fontSize: 14,
                  //                   height: 1.0,
                  //                   fontFamily: Setting.appFont,
                  //                   fontWeight: FontWeight.w700,
                  //                   color: Color(ColorTheme.defaultText),
                  //                 )),
                  //             const Spacer(),
                  //
                  //             // LoginPlatform.naver
                  //             SnsLoginSmallImage(loginType: getLoginPlatform()),
                  //             const SizedBox(width: 5),
                  //             Text(
                  //               _loginType.tr(),
                  //               maxLines: 1,
                  //               overflow: TextOverflow.ellipsis,
                  //               style: const TextStyle(
                  //                 fontSize: 14,
                  //                 height: 1.0,
                  //                 fontFamily: Setting.appFont,
                  //                 fontWeight: FontWeight.w500,
                  //                 color: Color(ColorTheme.defaultText),
                  //               ),
                  //             ),
                  //             Text("account_linking".tr(),
                  //                 maxLines: 1,
                  //                 overflow: TextOverflow.ellipsis,
                  //                 style: const TextStyle(
                  //                   fontSize: 14,
                  //                   height: 1.0,
                  //                   fontFamily: Setting.appFont,
                  //                   fontWeight: FontWeight.w500,
                  //                   color: Color(ColorTheme.defaultText),
                  //                 )),
                  //           ],
                  //         ),
                  //       ),
                  //       Visibility(
                  //         visible: _snsIsJoin != "Y",
                  //         child: Container(
                  //           width: double.infinity,
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 16, vertical: 13),
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: const Color(ColorTheme.c_f3f3f3),
                  //           ),
                  //           child: Column(
                  //             children: [
                  //               Text("account_link_description".tr(),
                  //                   maxLines: 3,
                  //                   overflow: TextOverflow.ellipsis,
                  //                   style: const TextStyle(
                  //                     fontSize: 12,
                  //                     height: 1.5,
                  //                     fontFamily: Setting.appFont,
                  //                     fontWeight: FontWeight.w500,
                  //                     color: Color(ColorTheme.defaultText),
                  //                   )),
                  //               Row(
                  //                 children: [
                  //                   const Spacer(),
                  //                   GestureDetector(
                  //                     onTap: () {
                  //                       Navigator.of(context).pushNamed(
                  //                           Routes.signupIdPage,
                  //                           arguments: {
                  //                             'joinType': 'snsLoginCreate'
                  //                           }).whenComplete(() {
                  //                         loadData();
                  //                       });
                  //                     },
                  //                     child: Container(
                  //                       padding: const EdgeInsets.symmetric(
                  //                           horizontal: 14, vertical: 9),
                  //                       decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.circular(17),
                  //                         color: const Color(ColorTheme.c_666666),
                  //                       ),
                  //                       child: Text("account_link1".tr(),
                  //                           maxLines: 1,
                  //                           overflow: TextOverflow.ellipsis,
                  //                           style: const TextStyle(
                  //                             fontSize: 12,
                  //                             height: 1.0,
                  //                             fontFamily: Setting.appFont,
                  //                             fontWeight: FontWeight.w500,
                  //                             color: Colors.white,
                  //                           )),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       )
                  //     ])),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              logout();
                            },
                            child: Text("logout".tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.0,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w500,
                                  color: Color(ColorTheme.c_767676),
                                )),
                          ),
                          const SizedBox(width: 16),
                          const VerticalDivider(
                            thickness: 1,
                            width: 1,
                            color: Color(ColorTheme.c_ededed),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () async {
                              await showSignOut();
                            },
                            child: Text("sign_out".tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.0,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w500,
                                  color: Color(ColorTheme.c_767676),
                                )),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),


        ));
  }

  void logout() async {
    String loginType =
        await CommonFunction.getPreferencesString(PreferenceKey.loginType) ??
            "";

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

    await CommonFunction.removePreferences(PreferenceKey.loginType);
    await CommonFunction.removePreferences(PreferenceKey.sessionCode);
    await CommonFunction.removePreferences(PreferenceKey.email);
    await CommonFunction.removePreferences(PreferenceKey.loginId);
    await CommonFunction.removePreferences(PreferenceKey.loginName);
    await CommonFunction.removePreferences(PreferenceKey.loginPhone);
    await CommonFunction.removePreferences(PreferenceKey.snsEmail);
    await CommonFunction.removePreferences(PreferenceKey.snsIdentifier);
    
    await CommonFunction.removePreferences(PreferenceKey.isOtp);
    await CommonFunction.removePreferences(PreferenceKey.withdrawalPass);
    await CommonFunction.removePreferences(PreferenceKey.withdrawalPassTs);


    // final sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode);
    // print(sessionCode);

    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.loginPage, (route) => false);
    }
  }

  void changePhone() {
    Navigator.of(context).pushNamed(Routes.signupSmsPage, arguments: {
      'certType': CertType.changePhone,
      'type': CertChangeType.phone
    }).whenComplete(() {
      loadData();
    });
    //Navigator.of(context).pushNamed(Routes.changePhonePage);
  }

  void changePassword() {
    Navigator.of(context).pushNamed(Routes.signupSmsPage, arguments: {
      'certType': CertType.changePaass,
      'type': CertChangeType.pass,
      'from': "AccountCert",
    }).whenComplete(() {
      loadData();
    });
    // Navigator.of(context).pushNamed(Routes.passwordChangePage);
  }

  void changeEmail() {
    Navigator.of(context).pushNamed(Routes.changeEmailPage).whenComplete(() {
      loadData();
    });
  }

  Future<void> showSignOut() async {
    await showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) => ConfirmDialog(
              title: "signout_title".tr(),
              body: "signout_subtitle".tr(),
              btnCancelText: "cancel".tr(),
              btnConfirmText: "confirm".tr(),
              onCancel: () {},
              onConfirm: () async {
                await signOut();
              },
            ));
  }

  Future<void> signOut() async {
    final String sessionCode =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";
    if (sessionCode == "") {
      return;
    }
    if (!mounted) {
      return;
    }

    var manager = ApiManagerMember();
    dynamic json;
    try {
      json = await manager.outMember(code: sessionCode);
      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        if (mounted) {
          Navigator.of(context).pushNamed(Routes.signOutDonePage);
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  LoginPlatform getLoginPlatform() {
    switch (_loginType) {
      case "naver":
        return LoginPlatform.naver;
      case "apple":
        return LoginPlatform.apple;
      case "google":
        return LoginPlatform.google;
      case "plastichero":
        return LoginPlatform.plastichero;
      default:
        return LoginPlatform.none;
    }
  }
}

class SnsLoginSmallImage extends StatelessWidget {
  final LoginPlatform loginType;

  const SnsLoginSmallImage({super.key, this.loginType = LoginPlatform.none});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: getBackground()),
        ),
        if (getImageName() != "")
          SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: SizedBox(
                width: 8,
                child: SvgPicture.asset(getImageName(), fit: BoxFit.scaleDown),
              ),
            ),
          ),
      ],
    );
  }

  Color getBackground() {
    switch (loginType) {
      case LoginPlatform.naver:
        return const Color(0xff3cab37);
      case LoginPlatform.google:
        return const Color(0xffe74133);
      case LoginPlatform.apple:
        return const Color(0xff121212);
      default:
        return Colors.white;
    }
  }

  String getImageName() {
    switch (loginType) {
      case LoginPlatform.naver:
        return "images/icon_naver.svg";
      case LoginPlatform.google:
        return "images/icon_google.svg";
      case LoginPlatform.apple:
        return "images/icon_apple.svg";
      default:
        return "";
    }
  }
}
