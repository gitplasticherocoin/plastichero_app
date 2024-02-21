import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_common.dart';
import 'package:plastichero_app/api/wallet/wallet_otp.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';


import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';

import 'package:plastichero_app/util/validate.dart';
import 'package:provider/provider.dart';

class SignUpIdPage extends StatefulWidget {
  const SignUpIdPage({Key? key}) : super(key: key);

  @override
  State<SignUpIdPage> createState() => _SignUpIdPageState();
}

class _SignUpIdPageState extends State<SignUpIdPage> {
  final gkSignup = GlobalKey<FormState>();

  late final TextEditingController _idTextController;
  late final TextEditingController _nameTextController;
  late final TextEditingController _pass1TextController;
  late final TextEditingController _pass2TextController;
  late final TextEditingController _emailTextController;
  late final FocusNode pass1Focus;
  late final FocusNode pass2Focus;
  late final FocusNode emailFocus;

  bool _isEnableConfirm = false;
  String _password = '';
  String _name = '';
  String _param = '';

  String _passwordConfirm = '';
  bool _checkDuplicatedId = false;

  String _username = "";
  String _userPhone = "";
  String _certUserInfo = "";
  bool _isChecking = false;
  String _joinType = "";
  String _snsInfo = "";

  MyinfoProvider? myInfoPovider;
  late final LoadingDialog loadingDialog;
  @override
  void initState() {
    super.initState();
    _idTextController = TextEditingController();
    _nameTextController = TextEditingController();
    _pass1TextController = TextEditingController();
    _pass2TextController = TextEditingController();
    _emailTextController = TextEditingController();

    pass1Focus = FocusNode();
    pass2Focus = FocusNode();
    emailFocus = FocusNode();
    myInfoPovider = Provider.of<MyinfoProvider>(context, listen: false);
    loadingDialog = LoadingDialog(context: context);
  }

  @override
  void dispose() {
    _idTextController.dispose();
    _nameTextController.dispose();
    _pass2TextController.dispose();
    _pass1TextController.dispose();
    _emailTextController.dispose();
    pass2Focus.dispose();
    pass1Focus.dispose();
    emailFocus.dispose();
    myInfoPovider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    _username = arguments["user_name"] ?? "";
    _userPhone = arguments["phone_no"] ?? "";
    _certUserInfo = arguments["cert_user_info"] ?? "";
    _snsInfo = arguments["sns_info"] ?? "";
    _joinType = arguments["joinType"] ?? "";
    _param = arguments['param'] ?? "";



    return Scaffold(
        appBar: DefaultToolbar(
          isBackButton: true,
          onBackPressed: () {
            Navigator.of(context).pop();
          },
          titleText: "member_join".tr(),
          centerTitle: false,
        ),
        body: GestureDetector(
          onTap: () {
            unFocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height -
                      50 -
                      padding.top -
                      padding.bottom

                  ,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: gkSignup,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 12,
                          ),
                          Text("signup_id_title".tr(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                height: 30 / 22,
                                letterSpacing: -0.66,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w700,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(
                            height: 6,
                          ),
                          Text("signup_id_subtitle".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w500,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(
                            height: 24,
                          ),
                          Text("id".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w700,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(
                            height: 6,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InputTextField(
                                    controller: _idTextController,
                                    hintText: "id_placeholder".tr(),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      return Validate.validateId(value);
                                    },
                                    // onChanged: (value) {
                                    //   setState(() {
                                    //     _checkDuplicatedId = false;
                                    //   });
                                    //   checkDupliactedId();
                                    //
                                    // },
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (value) {
                                      checkDupliactedId();
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                SizedBox(
                                  width: 100,
                                  child: BtnBorderBlack(
                                      isEnable: true,
                                      onTap: () {
                                        checkDupliactedId();
                                      },
                                      text: "check_duplicate".tr()),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),

                          Text("name".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w700,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(
                            height: 6,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InputTextField(
                                    controller: _nameTextController,
                                    hintText: "name_placeholder".tr(),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      return Validate.validateName(value);
                                    },
                                    onChanged: (value) {

                                      _name = value.trim();
                                      checkValidate();
                                      checkValidatePass();

                                    },
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (value) {
                                      _name = value.trim();
                                      checkValidate();
                                      checkValidatePass();
                                    },
                                  ),
                                ),

                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),

                          Text("password".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w700,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(
                            height: 6,
                          ),
                          NewPasswordTextField(
                            focusNode: pass1Focus,
                            validator: (value) {
                              return Validate.validatePassword(value);
                            },
                            onChange: (value) {
                              _password = value.trim();

                              print(Validate.validatePassword(value));


                              if(Validate.validatePassword(value) == null) {
                                checkValidatePass();
                                checkValidate();
                              }else {
                                setState(() {
                                  _isEnableConfirm = false;
                                });
                              }
                            },
                            onSaved: (value) {
                              _password = value ?? "";
                              _password = _password.trim();
                              checkValidatePass();
                            },
                            onFieldSubmitted: (value) {
                              // _pass2Focus.requestFocus();
                              checkValidate();
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text("password2".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w700,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(
                            height: 6,
                          ),
                          PasswordTextField(
                            focusNode: pass2Focus,
                            controller: _pass2TextController,
                            hintText: "pass2_placeholder".tr(),
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (value) {
                              _passwordConfirm = value;
                              _passwordConfirm = _passwordConfirm.trim();
                              checkValidate();
                              checkValidatePass();

                            },
                            onSaved: (value) {
                              _passwordConfirm = value ?? "";
                              _passwordConfirm = _passwordConfirm.trim();
                              checkValidate();
                              checkValidatePass();
                            },
                            onFieldSubmitted: (value) {
                              // _emailFocus.requestFocus();
                              checkValidate();
                            },
                            validator: (value) {
                              if (_passwordConfirm.isNotEmpty &&
                                  _passwordConfirm != _password) {
                                return "msg_error_not_match_password".tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text("email".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w700,
                                color: Color(ColorTheme.defaultText),
                              )),
                          const SizedBox(
                            height: 6,
                          ),
                          InputTextField(
                            focusNode: emailFocus,
                            controller: _emailTextController,
                            hintText: "email_placeholder1".tr(),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              return Validate.validateEmail(value);
                            },
                            onChanged: (value) {
                              checkValidate();
                            },
                            onFieldSubmitted: (value) {
                              unFocus();
                              checkValidate();
                            },
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.only(
                              bottom: 24,
                              top: 24,
                            ),
                            child: BtnFill(
                              isEnable: _isEnableConfirm,
                              text: "complete".tr(),
                              onTap: confirm,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  void confirm() {
    unFocus();
    if (_checkDuplicatedId && gkSignup.currentState!.validate()) {

      signUpHandler();
    }
  }

  void checkValidate() {
    debugPrint("checkValidate start = $_checkDuplicatedId");
    bool isEnable = false;
    if (!_checkDuplicatedId) {
      setState(() {
        _isEnableConfirm = false;
      });
      return;
    }
    if(gkSignup.currentState!.validate()) {
      isEnable = true;
    }

    if(Validate.validatePassword(_password) != null) {
      setState(() {
        _isEnableConfirm = false;
      });
      return;
    }
    setState(() {
      _isEnableConfirm = isEnable;
    });
  }

  Future<void> checkDupliactedId() async {
    debugPrint("checkDuplicatedId");
    unFocus();
    if (!mounted) {
      return;
    }
    final id = _idTextController.text;
    if (id.isEmpty) {
      checkValidate();
      return;
    }

    if (_isChecking) {
      return;
    }
    _isChecking = true;
    var manager = ApiManagerMember();
    dynamic json;

    try {
      json = await manager.checkDuplicateId(id: id);
      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        setState(() {
          _checkDuplicatedId = true;
        });

        final msg = json[ApiParamKey.result];
        if (mounted) {
          CommonFunction.showToast(context, msg);
        }
        checkValidate();
        _isChecking = false;
      } else {
        if(context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
        setState(() {
          _checkDuplicatedId = false;
        });
        checkValidate();
        _isChecking = false;
      }
    } catch (e) {
      setState(() {
        _checkDuplicatedId = false;
      });
      checkValidate();
      _isChecking = false;
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

    if(_joinType == "snsLoginCreate") {
      myInfoPovider?.callRefresh();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }else if(_joinType =="snsJoinCertDone") {

      if(mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.signupDonePage, (routes) => false);
      }

    }else {
      await CommonFunction.setPreferencesString(
          PreferenceKey.loginType, "plastichero");
      if(mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.signupDonePage, (routes) => false);
      }
    }


  }

  Future<void> signUpHandler() async {
    String? pwErrorText =
        Validate.validatePwCompare(_password, _passwordConfirm);

    if (pwErrorText != null) {
      return;
    }

    final email = _emailTextController.text;
    final id = _idTextController.text;

    final String fcmKey = await CommonFunction.getPreferencesString(
        PreferenceKey.fcmKey) ?? "";






    var manager = ApiManagerMember();
    dynamic json;
    try {
      loadingDialog.show();
      // String fcmKey = await CommonFunction.getPreferencesString(PreferenceKey.fcmKey) ?? '';
      if(_joinType == "snsLoginCreate") {
        final code = await CommonFunction.getPreferencesString(
            PreferenceKey.sessionCode) ?? "";

        json = await manager.signup(
          pw: _password,
          email: email,
          id: id,
          name : _name,
          fcmKey: fcmKey,
          param : _param,
          // name: _username,
          // phone: _userPhone,
          code: code,
        );
      } else if(_snsInfo != "") {
        json = await manager.signup(
          pw: _password,
          email: email,
          name : _name,
          param : _param,
          id: id,

          fcmKey: fcmKey,
          // name: _username,
          // phone: _userPhone,
          certUserInfo: _certUserInfo,
          snsInfo: _snsInfo,
        );
      } else {
        json = await manager.signup(
            pw: _password,
            email: email,
            id: id,
          name : _name,
          param : _param,
          fcmKey: fcmKey,
            // name: _username,
            // phone: _userPhone,
            certUserInfo: _certUserInfo,
        );
      }


      /*
      {status: success, result: {mb_no: 19, mb_id: dummy1, mb_password: sha256:12000:N0uoveQKhXSWA7Y07DZiCpx2CumDoOsB:8Dyz3TnYIQ5KxR3cYuAIDNZK4RzpXld4, mb_password2: , mb_name: 남경태, mb_nick: , mb_nick_date: 2023-07-11 00:00:00, mb_email: namgt@aigmachain.net, mb_homepage: , mb_level: 2, mb_sex: , mb_birth: , mb_tel: , mb_hp: , mb_certify: , mb_adult: 0, mb_dupinfo: , mb_zip1: , mb_zip2: , mb_addr1: , mb_addr2: , mb_addr3: , mb_addr_jibeon: , mb_signature: , mb_recommend: , mb_point: 0, mb_today_login: 2023-07-11 11:44:17, mb_login_ip: 192.168.100.12, mb_datetime: 2023-07-11 11:44:17, mb_ip: 192.168.100.12, mb_leave_date: , mb_intercept_date: , mb_email_certify: 0000-00-00 00:00:00, mb_email_certify2: , mb_memo: , mb_lost_certify: , mb_mailling: 0, mb_sms: 0, mb_open: 0, mb_open_date: 2023-07-11, mb_profile: , mb_memo_call: , mb_memo_cnt: 0, mb_scrap_cnt: 0, mb_1: , mb_2: , mb_3: , mb_4: , mb_5: , mb_6: , mb_7: , mb_8: , mb_9: , mb_10: }}
*/
      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        dynamic result = json["result"];
        final memberInfo = MemberInfo.fromJson(result);
        await checkOtp();
        await checkWithDrawPass(_password);

        loginHandler(memberInfo);
      } else {
        if(context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadingDialog.hide();
    }
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
          if (depass == "" ) {
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
  void showToast(String msg) {
    CommonFunction.showToast(context, msg);
  }

  void checkValidatePass() {
    bool isPw =
        (Validate.validatePwCompare(_password, _passwordConfirm) ?? '').isEmpty;
    setState(() {
      _isEnableConfirm = isPw;
    });
  }
}
