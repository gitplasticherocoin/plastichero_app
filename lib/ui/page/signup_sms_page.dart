import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero/api/api_manager_common.dart';
import 'package:plastichero_app/api/api_manager_sms.dart';
import 'package:plastichero/constants/preference_key.dart';
import 'package:plastichero/data/verify_type.dart';

import 'dart:ui' as ui;

import 'package:plastichero/plastichero.dart';
import 'package:plastichero/ui/widget/button_widget.dart';
import 'package:plastichero/util/countdown_timer.dart';
import 'package:plastichero/util/debug.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero/util/validate.dart';

enum SignupSmsPageMode { input, send }

enum SignupSmsPageType { join, login, edit }

class SignupSmsPage extends StatefulWidget {
  const SignupSmsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SignupSmsPage> createState() => _SignupSmsPageState();
}

class _SignupSmsPageState extends State<SignupSmsPage> {
  final gkSms = GlobalKey<FormState>();
  FocusNode focusPhoneNumber = FocusNode();
  FocusNode focusAuthNumber = FocusNode();
  late TextEditingController textEditingController;
  late TextEditingController authTextEditingController;

  CertType _certType = CertType.undefined;
  CertChangeType _certChangeType = CertChangeType.undefined;

  // String _snsInfo = "";
  // String _param = "";
  String _findType = "";

  // String? _sessionCode ;
  // String _from = "";

  String _region = "US";

  String _contryCode = "";
  String _phoneNumber = "";
  String _phoneFromServer = "";

  bool _isButtonEnable = false;
  bool _isNextButtonEnable = false;
  SignupSmsPageMode _mode = SignupSmsPageMode.input;

  int secondsRemaining = 5 * 60;
  String remainTime = "";
  bool isRunning = false;
  bool isCompleted = false;

  CountdownTimer? timer;

  bool _isLoad = false;
  late final LoadingDialog loadingDialog;
  String _goto = "";

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog(context: context);
    timer = CountdownTimer(
        seconds: secondsRemaining, onTick: onTick, onFinished: onFinished);

    textEditingController = TextEditingController();
    authTextEditingController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getRegion();
      // final nick =
      //     await CommonFunction.getPreferencesString(PreferenceKey.nickname) ??
      //         "";
      setState(() {
        // _nickname = nick;
        _isButtonEnable = false;
      });
    });
  }

  @override
  void dispose() {
    focusPhoneNumber.dispose();
    focusAuthNumber.dispose();
    textEditingController.dispose();
    authTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as Map<String, dynamic>;
    _certType = arguments['certType'] ?? CertType.undefined;
    _findType = arguments['findType'].toString().trim();
    _certChangeType = arguments['type'] ?? CertChangeType.undefined;
    final error = arguments["error"] ?? "";
    if (error == "untrust") {
      _goto = "main";
    } else {
      _goto = arguments["goto"] ?? "";
    }
    String title;
    switch (_certType) {
      case CertType.changePhone:
        title = "signup_edit_title".tr();
        break;
      case CertType.changePaass:
        title = "signup_edit_title".tr();
        break;
      case CertType.join:
        title = "sign_up".tr();
        break;
      case CertType.find:
        if (_findType == "id") {
          title = "find_id".tr();
        } else {
          title = "change_password".tr();
        }
        break;
      default:
        title = "";
        break;
    }

    return Scaffold(
        appBar: DefaultToolbar(
          onBackPressed: () {
            switch (_certType) {
              case CertType.join:
                Navigator.of(context).pop();
                break;
              case CertType.changePhone:
                Navigator.of(context).pop();
                break;
              case CertType.changePaass:
                Navigator.of(context).pop();
                break;
              default:
                Navigator.of(context).pop();
                break;
            }
          },
          isUnderLine: false,
          centerTitle: false,
          titleText: title,
        ),
        body: Visibility(
          visible: _isLoad,
          replacement: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: gkSms,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 16),
                    color: Colors.white,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getBodyTitle(),
                          //       Text(
                          // widget.type == SignupSmsPageType.edit
                          //     ? sprintf("signup_eidt_sms_auth_title".tr(), [Setting.appCoin])
                          //     : "signup_sms_auth_title".tr(),
                          //           maxLines: 2,
                          //           overflow: TextOverflow.ellipsis,
                          //           style: const TextStyle(
                          //             fontSize: 20,
                          //             height: 26 / 20,
                          //             fontFamily: Setting.appFont,
                          //             fontWeight: FontWeight.w500,
                          //             color: Color(ColorTheme.c_222222),
                          //           )),
                          const SizedBox(height: 6),
                          Text("signup_sms_auth_subtitle".tr(),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 16 / 12,
                                letterSpacing: -0.5,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w500,
                                color: Color(ColorTheme.c_222222),
                              )),
                          const SizedBox(height: 20),
                          Text("signup_sms_auth".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w500,
                                color: Color(ColorTheme.c_222222),
                              )),
                          const SizedBox(height: 8),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: _mode == SignupSmsPageMode.input
                                          ? Colors.white
                                          : const Color(ColorTheme.c_f7f7f7),
                                      border: Border.all(
                                        color: const Color(ColorTheme.c_dbdbdb),
                                        width: 1,
                                      )),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        CountryCodePicker(
                                          //barrierColor: Colors.blue,
                                          //backgroundColor: Colors.green,
                                          enabled:
                                          _mode == SignupSmsPageMode.input
                                              ? true
                                              : false,
                                          onInit: (code) {
                                            if (code != null) {
                                              _contryCode = code.dialCode ?? "";
                                            }
                                          },

                                          onChanged: (code) {
                                            _contryCode = code.dialCode!;
                                            focusPhoneNumber.requestFocus();
                                          },
                                          initialSelection: _region,
                                          favorite: [
                                            _region,
                                          ],
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            height: 1.0,
                                            fontFamily: Setting.appFont,
                                            fontWeight: FontWeight.w400,
                                            color: Color(ColorTheme.c_1e1e1e),
                                          ),
                                          flagWidth: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  flex: 5,
                                  child: InputTextField(
                                    enabled: _mode == SignupSmsPageMode.send
                                        ? false
                                        : true,
                                    controller: textEditingController,
                                    focusNode: focusPhoneNumber,
                                    hintText: "signup_sms_placeholder".tr(),
                                    hintColor: const Color(ColorTheme.c_9e9e9f),
                                    isHideErrorText: true,
                                    borderRadius: 16,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      // return Validate.validatePhone(value);
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _phoneNumber = value;
                                      _phoneNumber = _phoneNumber.trim();

                                      checkPhoneNumber();
                                    },
                                    onEditingComplete: () {
                                      _phoneNumber =
                                          textEditingController.text.trim();
                                      CommonFunction.hideKeyboard(context);
                                      checkPhoneNumber();
                                    },
                                  ))
                            ],
                          ),
                          Visibility(
                              visible: _mode == SignupSmsPageMode.input,
                              child: const SizedBox(height: 8)),

                          // Visibility(
                          //   visible: _isButtonEnable,
                          //     child:  const SizedBox(height: 5)),

                          // Visibility(
                          //   visible: _mode == SignupSmsPageMode.input,
                          //   child: Column(
                          //     children: [
                          //       SizedBox(height:  focusPhoneNumber.hasFocus  ?  0: 7),
                          //       SizedBox(height: _isButtonEnable ? 11  : 7),
                          //     ],
                          //   ),
                          // ),
                          Visibility(
                            visible: _mode == SignupSmsPageMode.input,
                            replacement: Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  InputAuthCodeTextField(
                                    // enabled: isCompleted ? false : true,
                                    controller: authTextEditingController,
                                    focusNode: focusAuthNumber,
                                    validator: (value) {
                                      return Validate.validateAuth(value);
                                    },
                                    maxLength: 6,
                                    hintText:
                                    "signup_authcode_placeholder".tr(),
                                    time: remainTime,
                                    borderRadius: 16,
                                    onChanged: (value) {
                                      checkAuthNumber();
                                    },
                                    onEditingComplete: () {
                                      CommonFunction.hideKeyboard(context);
                                      checkAuthNumber();
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                          isCompleted
                                              ? "signup_edit_authcode_expire"
                                              .tr()
                                              : "signup_authcode_guide".tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.0,
                                            fontFamily: Setting.appFont,
                                            fontWeight: FontWeight.w400,
                                            color: Color(ColorTheme.c_333333),
                                          )),
                                      const SizedBox(width: 7.7),
                                      GestureDetector(
                                        onTap: resend,
                                        behavior: HitTestBehavior.opaque,
                                        child: Text(
                                            "signup_authcode_resend".tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              height: 1.0,
                                              fontFamily: Setting.appFont,
                                              fontWeight: FontWeight.w500,
                                              color: Color(ColorTheme.c_333333),
                                              decoration:
                                              TextDecoration.underline,
                                            )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Visibility(
                                    visible: false,
                                    child: Container(
                                      padding: const EdgeInsets.all(17.3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: const Color(ColorTheme.c_ededed),
                                      ),
                                      child: Column(
                                        children: [
                                          Text("email_auth_description".tr(),
                                              textAlign: TextAlign.left,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.2,
                                                fontFamily: Setting.appFont,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                Color(ColorTheme.c_333333),
                                              )),
                                          const SizedBox(height: 10),
                                          ButtonStyle4(
                                            radius: 14,
                                            borderColor: const Color(
                                                ColorTheme.c_1e1e1e),
                                            text: "email_authentication".tr(),
                                            textColor: const Color(
                                                ColorTheme.c_1e1e1e),
                                            onTap: goEmail,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  ButtonStyle4(
                                    radius: 16,
                                    isEnable: _isNextButtonEnable,
                                    btnColor: const Color(ColorTheme.appColor),
                                    disableColor:
                                    const Color(ColorTheme.c_d6d6dc),
                                    text: "next".tr(),
                                    textColor: Colors.white,
                                    onTap: goNext,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                            child: Expanded(
                              child: Column(
                                children: [
                                  ButtonStyle4(
                                      isEnable: _isButtonEnable,
                                      radius: 16,
                                      borderColor: _isButtonEnable
                                          ? const Color(ColorTheme.c_1e1e1e)
                                          : const Color(ColorTheme.c_d6d6dc),
                                      text: "signup_authcode_request".tr(),
                                      textColor: _isButtonEnable
                                          ? const Color(ColorTheme.c_1e1e1e)
                                          : const Color(ColorTheme.c_9e9e9f),
                                      onTap: checkMemberPhoneNumber),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  void getRegion() async {
    var manager = ApiManagerCommon();
    dynamic json;
    loadingDialog.show();
    try {
      json = await manager.getIPRegion();
      print("json : ${json}");
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        String region;

        region = json["countryCode"] ?? "";

        if (region == "") {
          //언어로
          String deviceLocale = ui.window.locale.languageCode;
          String region = "KR";
          if (deviceLocale.isEmpty) {
            region = "JP";
          }
        }

        setState(() {
          _region = region;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoad = true;
      });
      loadingDialog.hide();
    }
  }

  Future<void> goJoin() async {}

  Future<void> goEdit() async {
    // CommonFunction.hideKeyboard(context);
    //
    // final phone = "${_contryCode.trim()}|${_phoneNumber.trim()}";
    // final code = authTextEditingController.text.trim();
    // if (code == "") {
    //   return;
    // }
    // var manager = ApiManagerSMS();
    // dynamic json;
    // loadingDialog.show();
    // try {
    //   json = await manager.setPhone(phone: phone, code: code);
    //   final status = json[ApiParamKey.status];
    //   if (status == ApiParamKey.success) {
    //     //저장
    //     var phone;
    //     await CommonFunction.setPreferencesString(PreferenceKey.loginPhone, phone);
    //     timer?.cancel();
    //     if (mounted) {
    //       if (widget.type == SignupSmsPageType.login) {

    // Navigator.of(context).pushNamedAndRemoveUntil("/mainPage", (route) {
    //   return false;
    // });
    //         widget.goLogin!();
    //         // Navigator.pushNamedAndRemoveUntil(
    //         //   context,
    //         //   MainPage.routeName,
    //         //       (route) {
    //         //     return false;
    //         //   },
    //        // );
    //       } else {
    //         Navigator.of(context).pop();
    //       }
    //     }
    //   } else {
    //     final msg = json[ApiParamKey.msg] ?? "";
    //     if (msg != "" && mounted) {
    //       CommonFunction.showToast(context, msg);
    //     }
    //   }
    // } catch (e) {
    //   debugPrint(e.toString());
    // } finally {
    //   loadingDialog.hide();
    // }
  }

  VerifyType getVerifyType() {
    switch (_certType) {
      case CertType.find:
        if (_findType == "id") {
          return VerifyType.findId;
        } else {
          return VerifyType.findPassword;
        }
      case CertType.join:
        return VerifyType.join;
      case CertType.changePhone:
        return VerifyType.changePhoneInfo;
      case CertType.changePaass:
        return VerifyType.changePassInfo;
      default:
        return VerifyType.undefined;
    }
  }

  void changePhone(BuildContext context, String param,
      String sessionCode) async {
    var manager = ApiManagerSMS();
    dynamic json;

    try {
      json = await manager.changeAccount(
          type: _certChangeType.type, param: param, sessionCode: sessionCode);
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        if (mounted) {
          if (_goto == "main") {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
          } else {
            Navigator.of(context).pop();
          }
        }
      } else {
        final msg = json[ApiParamKey.msg] ?? "";
        if (msg != "" && mounted) {
          CommonFunction.showToast(context, msg);
        }
      }
    } catch (e) {
      Debug.log("error", e.toString());
    }
  }

  void goNext() async {
    CommonFunction.hideKeyboard(context);
    loadingDialog.show();
    final sessionCode =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";

    //final phone = "${_contryCode.trim()}|${_phoneNumber.trim()}";
    final phone = _phoneFromServer.trim();
    final code = authTextEditingController.text.trim();
    final type = getVerifyType();
    if (code == "") {
      return;
    }
    var manager = ApiManagerSMS();
    dynamic json;

    try {
      json =
      await manager.validateSMS(phone: phone, code: code, type: type.code);
      final status = json[ApiParamKey.status];


      if (status == ApiParamKey.success) {
        loadingDialog.hide();
        timer?.cancel();

        final result = json[ApiParamKey.result];
        final param = result[ApiParamKey.param] ?? "";
        final id = result['id'] ?? "";

        if (mounted) {
          switch (_certType) {
            case CertType.changePaass:
              Navigator.of(context)
                  .pushReplacementNamed(Routes.passwordChangePage, arguments: {
                "param": param,
                "certChangeType": _certChangeType,
                "from": "AccountCert"
              });

              break;
            case CertType.changePhone:
              if (sessionCode != "") {
                changePhone(context, param, sessionCode);
              }

              break;
            case CertType.find:
              if (_findType == "id") {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.findIdPage, ModalRoute.withName(Routes.loginPage),
                    arguments: {"param": param, "id": id});
              } else {
                Navigator.of(context).pushReplacementNamed(
                    Routes.passwordChangePage,
                    arguments: {"param": param});
              }
              break;
            case CertType.join:
              Navigator.of(context)
                  .pushNamed(Routes.signupIdPage, arguments: {"param": param});
              break;
            case CertType.platform:
              Navigator.of(context).pop();
              break;

            default:
              Navigator.of(context)
                  .pushNamed(Routes.signupIdPage, arguments: {"param": param});

              Debug.log("doNavigator", "exec");
              break;
          }
        }
      } else {
        loadingDialog.hide();
        final result = json[ApiParamKey.result];
        final id = result['id'] ?? "";
        if (id != "") {
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.accountLinkStart, ModalRoute.withName(Routes.signupPage),
              arguments: id);
        } else {
          final msg = json[ApiParamKey.msg] ?? "";
          if (msg != "" && mounted) {
            CommonFunction.showToast(context, msg);
          }
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    } finally {}
  }

  void checkMemberPhoneNumber() async {
    if (_certType == CertType.changePhone ||
        _certType == CertType.changePaass || _findType == "pass") {
      requestCode();
      return;
    }
    CommonFunction.hideKeyboard(context);
    var manager = ApiManagerSMS();
    dynamic json;
    loadingDialog.show();
    final phone = "${_contryCode.trim()}|${_phoneNumber.trim()}";
    try {
      json = await manager.checkMember(phone: phone);
      loadingDialog.hide();
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        requestCode();
      } else {

        final msg = json[ApiParamKey.msg];
        if (msg != "") {
          if (mounted) {
            CommonFunction.showCancelConfirmDialog(context: context,
                msg: msg,
                btnCancelText: "login".tr(),
                btnConfirmText: "next".tr(),
                onCancel: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                onConfirm: () {
                  requestCode();
                });
          }
        } else {

        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    } finally {

    }
  }

  void requestCode() async {
    CommonFunction.hideKeyboard(context);
    var manager = ApiManagerSMS();
    dynamic json;
    loadingDialog.show();
    final phone = "${_contryCode.trim()}|${_phoneNumber.trim()}";
    try {
      if (_certType == CertType.changePaass) {
        final code = await CommonFunction.getPreferencesString(
            PreferenceKey.sessionCode) ??
            "";

        json = await manager.sendSms(
            phone: phone,
            type: VerifyType.changePassInfo.code,
            sessionCode: code);
      } else if (_findType == "pass") {
        json = await manager.sendSms(
            phone: phone, type: VerifyType.findPassword.code);
      } else {
        json = await manager.sendSms(phone: phone);
      }


      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        var result = json[ApiParamKey.result];
        startTimer();
        if (result != null) {
          final String code = result["code"] ?? "";
          _phoneFromServer = result["phone"] ?? "";
          authTextEditingController.text = code;
          setState(() {
            _isNextButtonEnable = true;
          });
        }
      } else {
        final msg = json[ApiParamKey.msg] ?? "";
        if (msg != "" && mounted) {
          CommonFunction.showToast(context, msg);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadingDialog.hide();
    }
  }

  void checkPhoneNumber() async {
    bool isEnable = false;

    final tel = textEditingController.text;
    if (Validate.validatePhone(tel) == null) {
      isEnable = true;
    }
    // if (gkSms.currentState!.validate()) {
    //   isEnable = true;
    // }
    setState(() {
      _isButtonEnable = isEnable;
    });
  }

  void checkAuthNumber() {
    bool isEnable = false;
    if (gkSms.currentState!.validate()) {
      isEnable = true;
    }
    setState(() {
      _isNextButtonEnable = isEnable;
    });
  }

  void startTimer() {
    if (!isRunning) {
      setState(() {
        _mode = SignupSmsPageMode.send;
        remainTime = "";
        isRunning = true;
        isCompleted = false;
      });

      timer?.start();
    }
  }

  void resend() {
    if (isRunning) {
      timer?.cancel();
      setState(() {
        isRunning = false;
        remainTime = "";
      });
      Future.delayed(const Duration(seconds: 1), () {
        requestCode();
      });
    } else {
      requestCode();
    }

    authTextEditingController.text = "";
  }

  void onTick(String str) {
    if (!isRunning) {
      return;
    }
    setState(() {
      remainTime = str;
    });
  }

  void onFinished() {
    setState(() {
      isRunning = false;
      isCompleted = true;
      _isNextButtonEnable = false;
    });
  }

  Widget getBodyTitle() {
    switch (_certType) {
      default:
        return Text("signup_sms_auth_title".tr(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              height: 26 / 20,
              fontFamily: Setting.appFont,
              fontWeight: FontWeight.w500,
              color: Color(ColorTheme.c_222222),
            ));
    }
  }

  Future<void> goEmail() async {
    // if (_isNeedEmailCheck) {
    //   final String phone = "${_contryCode.trim()}|${_phoneNumber.trim()}";
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => SignUpCheckPage(phone: phone)),
    //   );
    // }
  }
}
