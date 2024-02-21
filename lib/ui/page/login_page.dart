import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_common.dart';
import 'package:plastichero_app/api/wallet/wallet_otp.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/validate.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final gkLogin = GlobalKey<FormState>();
  final _idFormKey = GlobalKey<FormState>();
  late final TextEditingController _idTextEditingController;
  late final TextEditingController _passTextEditingController;
  LoginPlatform _loginPlatform = LoginPlatform.none;
  String _loginIdentifier = "";
  late final FocusNode passwordFocus;
  bool _isClickLogin = false;
  DateTime? backBtnPressedTime;
  late final LoadingDialog loadingDialog;
  @override
  void initState() {
    super.initState();
    passwordFocus = FocusNode();
    _idTextEditingController = TextEditingController();
    _passTextEditingController = TextEditingController();
    loadingDialog = LoadingDialog(context: context);
  }

  @override
  void dispose() {
    _idTextEditingController.dispose();
    _passTextEditingController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String? id = arguments?["id"];
    if (id != null && id.isNotEmpty && id != "") {
      _idTextEditingController.text = id;
    }
    return WillPopScope(
      onWillPop: () async{
        return await backButtonAction();
      },
      child: Scaffold(
          body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: unFocus,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: gkLogin,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      SvgPicture.asset("images/logo.svg",
                          width: 206, height: 32),
                      const SizedBox(height: 71),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("id".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.0,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w500,
                                  color: Color(ColorTheme.defaultText))),
                          const SizedBox(height: 6),
                          Form(
                            key: _idFormKey,
                            child: InputTextField(
                              controller: _idTextEditingController,
                              onChanged: (value) {

                                _idFormKey.currentState?.validate();

                              },
                              validator: (value) {
                                return Validate.validateId(value);
                              },
                              hintText: "id_placeholder".tr(),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                passwordFocus.requestFocus();
                              },
                              keyboardType: TextInputType.emailAddress,
                              fixedLineColor: null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text("pass".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w500,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(height: 6),
                          PasswordTextField(
                            controller: _passTextEditingController,
                            hintText: "password_placeholder".tr(),
                            focusNode: passwordFocus,
                            keyboardType: TextInputType.visiblePassword,
                            isOutline: false,
                            onChanged: (value) {
                                gkLogin.currentState!.validate();

                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'msg_error_empty_password'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                      Row(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: goFindId,
                                  child: Text("find_id".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.0,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.c_666666),
                                      )),
                                ),
                                const SizedBox(width: 10),
                                const VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Color(ColorTheme.c_666666),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: goChangePassword,
                                  child: Text("change_password".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.0,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.c_666666),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      BtnFill(
                        text: "login".tr(),
                        onTap: login,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      BtnBorderAppColor(
                          text: "member_join".tr(),
                          onTap: () {
                            Navigator.of(context).pushNamed(Routes.signupPage);
                          }),

                      Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    height: 1,
                                    color: Color(ColorTheme.c_ededed),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text("simple_login".tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.0,
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w500,
                                      color: Color(ColorTheme.c_767676),
                                    )),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    height: 1,
                                    color: Color(ColorTheme.c_ededed),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Spacer(),
                                SimpleLoginButtonWidget(
                                  backgroundColor: const Color(0xff3cab37),
                                  onTap: signWithNaver,
                                  imageName: "icon_naver",
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                SimpleLoginButtonWidget(
                                  backgroundColor: const Color(0xff121212),
                                  onTap: signWithApple,
                                  imageName: "icon_apple_white",
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                SimpleLoginButtonWidget(
                                  backgroundColor: const Color(0xffe74133),
                                  onTap: signWithGoogle,
                                  imageName: "icon_google",
                                ),
                                const Spacer(),
                              ],
                            )
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Future<void> signWithApple() async {
    if (_isClickLogin) {
      return;
    }
    _isClickLogin = true;
    try {
      final scopes = <AppleIDAuthorizationScopes>[
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ];
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
              scopes: scopes,
              webAuthenticationOptions: WebAuthenticationOptions(
                  clientId: "app.plastichero.com",
                  redirectUri: Uri.parse(
                      "https://airy-frill-waterlily.glitch.me/callbacks/sign_in_with_apple")));

      List<String> jwt = credential.identityToken?.split('.') ?? [];
      String payload = jwt[1];
      payload = base64.normalize(payload);

      final List<int> jsonData = base64.decode(payload);
      final userInfo = jsonDecode(utf8.decode(jsonData));
      String email = userInfo['email'];

      _loginIdentifier = email;
      //I/flutter (23743): {iss: https://appleid.apple.com, aud: app.plastichero.com, exp: 1689050872, iat: 1688964472, sub: 001828.55f36599f52741e6ba6bca0092908720.0229, c_hash: 7pY3Qcah7hmRdpwDOJZh5A, email: rjnbbmfpcr@privaterelay.appleid.com, email_verified: true, is_private_email: true, auth_time: 1688964472, nonce_supported: true}

      // print('credential.state = ${credential.state}');
      // print('credential.email = ${credential.email}');
      // print('credential.userIdentifier = ${credential.userIdentifier}');
      // print('credential.givenName = ${credential.givenName}');
      // print('credential.familyName = ${credential.familyName}');

      await CommonFunction.setPreferencesString(PreferenceKey.snsEmail, _loginIdentifier);
      await CommonFunction.setPreferencesString(PreferenceKey.snsIdentifier, _loginIdentifier);


      setState(() {
        _loginPlatform = LoginPlatform.apple;
      });
      singInHandler(email: email);
    } catch (error) {
      _isClickLogin = false;
      debugPrint("error = $error");
    }
  }

  Future<void> signWithNaver() async {
    if (_isClickLogin) {
      return;
    }
    _isClickLogin = true;
    final NaverLoginResult result = await FlutterNaverLogin.logIn();
    if (result.status == NaverLoginStatus.loggedIn) {
      // print("accessToken : ${result.accessToken}");
      // print("id : ${result.account.id}");
      // print("email : ${result.account.email}");
      // print("name : ${result.account.name}");

      _loginIdentifier = result.account.id;
      setState(() {
        _loginPlatform = LoginPlatform.naver;
      });
      await CommonFunction.setPreferencesString(PreferenceKey.snsEmail, result.account.email);
      await CommonFunction.setPreferencesString(PreferenceKey.snsIdentifier, _loginIdentifier);

      singInHandler(email: result.account.email);
    }else {
      _isClickLogin = false;
    }
  }

  Future<void> signWithGoogle() async {
    if (_isClickLogin) {
      return;
    }
    _isClickLogin = true;
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      // print('name = ${googleUser.displayName}');
      // print('email = ${googleUser.email}');
      // print('id = ${googleUser.id}');

      _loginIdentifier = googleUser.id;
      setState(() {
        _loginPlatform = LoginPlatform.google;
      });

      await CommonFunction.setPreferencesString(PreferenceKey.snsEmail, googleUser.email);
      await CommonFunction.setPreferencesString(PreferenceKey.snsIdentifier, _loginIdentifier);

      singInHandler(email: googleUser.email);
    }else {
      _isClickLogin = false;
    }
  }

  Future<void> signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.apple:
        break;
      case LoginPlatform.naver:
        await FlutterNaverLogin.logOut();
        break;
      case LoginPlatform.google:
        await GoogleSignIn().signOut();
        break;
      default:
        break;
    }
    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  String getLoginTypeFromLoginPlatform() {
    switch (_loginPlatform) {
      case LoginPlatform.naver:
        return "naver";
      case LoginPlatform.apple:
        return "apple";
      case LoginPlatform.google:
        return "google";
      case LoginPlatform.plastichero:
        return "plastichero";
      default:
        return "";
    }
  }

  Future<void> singInHandler({String? email}) async {
    await CommonFunction.setPreferencesString(
        PreferenceKey.loginType, getLoginTypeFromLoginPlatform());
    final String fcmKey =
        await CommonFunction.getPreferencesString(PreferenceKey.fcmKey) ?? "";
    var manager = ApiManagerMember();
    dynamic json;

    if (_loginPlatform == LoginPlatform.plastichero) {
      try {
        loadingDialog.show();
        json = await manager.login(
            id: _idTextEditingController.text,
            pw: _passTextEditingController.text,
            fcmKey: fcmKey);
        String status = json[ApiParamKey.status];
        _isClickLogin = false;
        if (status == ApiParamKey.success) {
          dynamic result = json[ApiParamKey.result];

          final String msg = result["msg"] ?? "";
          final String code = result["code"] ?? "";

          await CommonFunction.setPreferencesString(PreferenceKey.sessionCode , code) ;


          // TODO 세션 코드 저장하기
          // print("json: $json");
          if ( msg.isNotEmpty) {
            //본인인증 다시하기
            if (mounted) {
              //세션코드 가지고 오기

              if(code != "") {
               // CommonFunction.showToast(context, msg);
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.of(context).pushNamed(Routes.signupSmsPage,
                      arguments: {
                        "certType": CertType.changePhone,
                        "type": CertChangeType.phone,
                        "goto": "main"
                      });
                });
              }else {
                PlasticheroMember.logout();

              }

            }
          } else {
            dynamic result = json[ApiParamKey.result];
            final memberInfo = MemberInfo.fromJson(result);

            await checkOtp();
            await checkWithDrawPass( _passTextEditingController.text);

            loginHandler(memberInfo);
          }
        } else {
          if(context.mounted) {
            await CheckResponse.checkErrorResponse(context, json);
          }

        }


      } catch (e) {
        _isClickLogin = false;
        debugPrint(e.toString());
      } finally {
        loadingDialog.hide();
      }
      return;
    } else if (_loginPlatform != LoginPlatform.none) {
      try {
        //loadingDialog.show();
        json = await manager.snsLogin(
            identifier: _loginIdentifier,
            provider: getLoginTypeFromLoginPlatform(),
            fcmKey: fcmKey,
            email: email );
        dynamic result = json[ApiParamKey.result];
        String? snsInfo = result["sns_info"];
        final String param = result["param"] ?? "";
        if (snsInfo != null && snsInfo.isNotEmpty) {
          //TODO: 회원가입을 시키자
          if (mounted) {
            Navigator.of(context).pushNamed(Routes.signupSmsPage, arguments: {
              "certType": CertType.sns,
              "snsInfo": snsInfo,
              "param": param
            });
          }
          _isClickLogin = false;
          return;
        } else {
          /// 로그인
          ///
          final memberInfo = MemberInfo.fromJson(result);
          loginHandler(memberInfo);
          _isClickLogin = false;
          //  print("memberInfo : $memberInfo");
          // print("code : ${memberInfo.code}");
        }
      } catch (e) {
        debugPrint(e.toString());
        _isClickLogin = false;
      } finally {
        //loadingDialog.hide();
      }
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
    // await CommonFunction.setPreferencesString(
    //     PreferenceKey.email, memberInfo.mbEmail ?? "");
    // await CommonFunction.setPreferencesString(
    //     PreferenceKey.loginId, memberInfo.mbId ?? "");
    // await CommonFunction.setPreferencesString(
    //     PreferenceKey.loginName, memberInfo.mbName ?? "");
    // await CommonFunction.setPreferencesString(
    //     PreferenceKey.loginPhone, memberInfo.mbHp ?? "");
    // await CommonFunction.setPreferencesString(
    //     PreferenceKey.snsIsJoin, memberInfo.isJoin ?? "");


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

  void login() async {
    if (_isClickLogin) {
      _isClickLogin = false;
      return;
    }
    _isClickLogin = true;
    unFocus();
    if (gkLogin.currentState!.validate()) {
      _loginPlatform = LoginPlatform.plastichero;
      singInHandler();
    }
  }

  void goFindId() {
    Navigator.of(context).pushNamed(Routes.signupSmsPage,
        arguments: {"certType": CertType.find, 'findType': 'id'});
  }

  void goChangePassword() {
    Navigator.of(context).pushNamed(Routes.signupSmsPage,
        arguments: {"certType": CertType.find, 'findType': 'pass'});
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }
  Future<bool> backButtonAction() async {
    DateTime currentTime = DateTime.now();

    bool backBtn = false;

    if (backBtnPressedTime == null) {
      backBtn = true;
    } else if (currentTime.difference(backBtnPressedTime!) >
        const Duration(seconds: 2)) {
      backBtn = true;
    }

    if (backBtn) {
      backBtnPressedTime = currentTime;
      CommonFunction.showToast(context, 'back_button_msg'.tr());
      return false;
    }

    await FlutterExitApp.exitApp(iosForceExit: Platform.isIOS);
    return true;
  }

  Future<void> checkWithDrawPass(String pass) async {
    var manager = ApiManageHWalletCommon();
    dynamic json;
    try {
      json = await manager.getPass(pw: pass);
      final status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        final pw = json[ApiParamKey.pw];
        if(pw != "") {
          final timestamp = json[ApiParamKey.timestamp];
          final depass = AESHelper().decrypt(pw, timestamp);
          if (depass == "") {
            return;
          } else {
            await CommonFunction.setPreferencesString(PreferenceKey.withdrawalPass, pw);
            await CommonFunction.setPreferencesString(PreferenceKey.withdrawalPassTs, timestamp);
            return ;
          }
        }else {
          return;
        }

      }
    } catch (e) {
      debugPrint(e.toString());
    }

  }

  Future<void> checkOtp() async {
    var manager =  ApiManagerWalletOtp();
    dynamic json;
    try {
      json = await manager.getOtp();
      final status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {
        final isOtp = json["otp_exist"];
        if(isOtp) {
          await CommonFunction.setPreferencesBoolean(PreferenceKey.isOtp, isOtp);
        }else {
          await CommonFunction.setPreferencesBoolean(PreferenceKey.isOtp, isOtp);
        }

      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class SimpleLoginButtonWidget extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback onTap;
  final String imageName;

  const SimpleLoginButtonWidget(
      {super.key,
      required this.onTap,
      required this.backgroundColor,
      required this.imageName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: backgroundColor,
            ),
            width: 48,
            height: 48,
          ),
          Visibility(
              visible: imageName != "icon_apple_white",
              replacement: Container(
                width: 48,
                height: 48,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SvgPicture.asset(
                  "images/$imageName.svg",
                ),
              ),
              child: Container(
                  width: 48,
                  height: 48,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: SvgPicture.asset("images/$imageName.svg",
                        width: 15, height: 15),
                  )))
        ],
      ),
    );
  }


}
