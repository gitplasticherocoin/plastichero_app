import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';

import 'package:plastichero/ui/widget/text_widget.dart';
import 'package:plastichero/util/countdown_timer.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
//import 'package:plastichero_app/ui/page/signup_sms_page.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
// import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
//import 'package:plastichero_app/util/validate.dart';
import 'package:plastichero/util/validate.dart';
import '../dialog/loading_dialog.dart';

enum WalletCreatePageMode {
  input, send, done
}

class WalletCreatePage extends StatefulWidget {
  const WalletCreatePage({super.key});

  @override
  State<WalletCreatePage> createState() => _WalletCreatePageState();
}

class _WalletCreatePageState extends State<WalletCreatePage> {
  final gkWalletCreate = GlobalKey<FormState>();

  late final LoadingDialog loadingDialog;
  late final TextEditingController _emailTextController;
  late final TextEditingController _pass1TextController;
  late final TextEditingController _pass2TextController;
  FocusNode focusAuthNumber = FocusNode();
  late TextEditingController authTextEditingController;
  bool _isButtonEnable = false;
  bool _isNextButtonEnable = false;
  int secondsRemaining = 3 * 60;
  String remainTime = "";
  bool isRunning = false;
  bool isCompleted = false;
  CountdownTimer? timer;
  WalletCreatePageMode _mode = WalletCreatePageMode.input;


  late final FocusNode pass1Focus;
  late final FocusNode pass2Focus;
  late final FocusNode emailFocus;
  bool _isEnableConfirm = false;
  String _password = '';
  String _passwordConfirm = '';
  String _email = "";
  String _auth = "";

  bool _isRequest = false;

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog(context: context);
    timer = CountdownTimer(
        seconds: secondsRemaining, onTick: onTick, onFinished: onFinished);
    authTextEditingController = TextEditingController();
    _emailTextController = TextEditingController();
    _pass1TextController = TextEditingController();
    _pass2TextController = TextEditingController();
    pass1Focus = FocusNode();
    pass2Focus = FocusNode();
    emailFocus = FocusNode();
  }

  @override
  void dispose() {
    _pass2TextController.dispose();
    _pass1TextController.dispose();
    _emailTextController.dispose();
    pass2Focus.dispose();
    pass1Focus.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unFocus,
      child: Scaffold(
          appBar: DefaultToolbar(
            onBackPressed: goBack,
            titleText: "wallet_create".tr(),
            centerTitle: false,
          ),
          body: Container(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: gkWalletCreate,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text("email".tr(),
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
                              InputTextField(
                                enabled: _mode == WalletCreatePageMode.done ? false: true ,
                                controller: _emailTextController,
                                hintText: "email_placeholder1".tr(),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  return Validate.validateEmail(value);
                                },
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {
                                  _email = value;
                                  _email = _email.trim();
                                  checkValidate();
                                },
                                onFieldSubmitted: (value) {
                                  _email = _emailTextController.text;
                                  //pass1Focus.requestFocus();
                                  checkValidate();
                                },
                              ),
                              const SizedBox(height: 10),
                              Visibility(
                                visible: _mode == WalletCreatePageMode.input ,
                                replacement:
                                Visibility(
                                  visible: _mode == WalletCreatePageMode.send,
                                  replacement: Column(
                                    children: [
                                      ButtonStyle4(
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Icon(Icons.check, color: const Color(ColorTheme.c_9e9e9f)),
                                          ),
                                          isEnable: false,
                                          radius: 16,
                                          borderColor:  const Color(ColorTheme.c_d6d6dc),
                                          text: "valid_done".tr(),
                                          textColor: const Color(ColorTheme.c_9e9e9f),
                                          onTap: requestCode),
                                    ],
                                  ),
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
                                          _auth = value.trim();
                                          checkAuthNumber();
                                        },
                                        onEditingComplete: () {
                                          CommonFunction.hideKeyboard(context);
                                          _auth = authTextEditingController.text;

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
                                      // const Spacer(),
                                      ButtonStyle4(
                                        radius: 16,
                                        borderColor: _isNextButtonEnable ? const Color(ColorTheme.appColor) : const Color(ColorTheme.c_d6d6dc),
                                        isEnable: _isNextButtonEnable,
                                        btnColor: const Color(ColorTheme.appColor),
                                        disableColor:
                                        const Color(ColorTheme.c_d6d6dc),
                                        text: "confirm".tr(),
                                        textColor: Colors.white,
                                        onTap: validateAuthNumber,
                                      ),
                                      // const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
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
                                        onTap: requestCode),

                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text("password".tr(),
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
                              NewPasswordTextField(
                                focusNode: pass1Focus,
                                hint: "msg_error_empty_password".tr(),
                                // keyboardType: TextInputType.visiblePassword,
                                // textInputAction: TextInputAction.next,
                                onChange: (value) {
                                  _password = value;
                                  _password = _password.trim();
                                  checkValidatePass();
                                  checkValidate();
                                },

                                onFieldSubmitted: (value) {
                                  _password = value;
                                  _password = _password.trim();
                                  checkValidatePass();
                                  checkValidate();
                                },
                              ),
                              const SizedBox(height: 10),
                              Text("password2".tr(),
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
                                validator: (value) {
                                  if (_passwordConfirm.isNotEmpty && _passwordConfirm != _password) {
                                    return "msg_error_not_match_password".tr();
                                  }
                                  return null;
                                },
                                hintText: "msg_fail_withdrawal_password".tr(),
                                onChanged: (value) {
                                  _passwordConfirm = value;
                                  _passwordConfirm = _passwordConfirm.trim();
                                  checkValidatePass();
                                  checkValidate();
                                },
                                onEditingComplete: () {},
                                onFieldSubmitted: (value) {
                                  _passwordConfirm = value;
                                  _passwordConfirm = _passwordConfirm.trim();
                                  checkValidate();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _mode == WalletCreatePageMode.done,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 24),
                          child: BtnFill(
                            onTap: createWallet,
                            isEnable: _isRequest ? false : _isEnableConfirm,
                            text: "create".tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void goBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void checkValidate() {
    if(_mode == WalletCreatePageMode.input) {
      final checkMail  = Validate.validateEmail(_email);

      if(checkMail == null) {
        setState(() {
          _isButtonEnable = true;
        });
      }else {
        setState(() {
          _isButtonEnable = false;
        });
      }



    }else {
      debugPrint("checkValidate start");
      bool isEnable = false;
      bool isPw = (Validate.validatePwCompare(_password, _passwordConfirm) ??
          '').isEmpty;
      print("isPw : $isPw");

      if (gkWalletCreate.currentState!.validate() && isPw) {
        isEnable = true;
      }
      setState(() {
        _isEnableConfirm = isEnable;
      });
    }
  }

  void checkValidatePass() {
    bool isPw = (Validate.validatePwCompare(_password, _passwordConfirm) ?? '').isEmpty;
    setState(() {
      _isEnableConfirm = isPw;
    });
  }

  Future<void> createWallet() async {
    if (_isRequest) {
      setState(() {
        _isRequest = true;
      });
    }
    if (mounted) {
      CommonFunction.hideKeyboard(context);
    }
    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.create(email: _email, pw: _password , code: _auth);
      loadingDialog.hide();
      final status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        setState(() {
          _isRequest = false;
        });
        final masterKey = json[ApiParamKey.masterkey];
        final timestamp = json[ApiParamKey.timestamp];
        final deMasterKey = AESHelper().decrypt(masterKey, timestamp) ;
        //TODO:
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.masterKeyPage, result: true,
              arguments: {"masterkey": deMasterKey});
        }
      } else {
        final msg = json['msg'] ?? "";
        if (msg != "" && mounted) {
          CommonFunction.showToast(context, msg);
        }
        if (mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }

        setState(() {
          _isRequest = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      loadingDialog.hide();
      setState(() {
        _isRequest = false;
      });
    }
  }

  void checkAuthNumber() {
    bool isEnable = false;
    if (gkWalletCreate.currentState!.validate()) {
      isEnable = true;
    }
    setState(() {
      _isNextButtonEnable = isEnable;
    });
  }
  void startTimer() {
    if (!isRunning) {
      setState(() {
        _mode = WalletCreatePageMode.send;
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
  void requestCode() async {
    if(mounted) {
      CommonFunction.hideKeyboard(context);
    }

    var manager = ApiManagerPTHWallet(); 
    dynamic json; 
    try {
      loadingDialog.show();
      json = await manager.sendValidateCode(email: _email);

      final status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {

        final authCode = json[ApiParamKey.code];
        if(authCode != null && authCode.toString().isNotEmpty) {
          authTextEditingController.text = authCode.toString();
          _auth =  authTextEditingController.text;
          checkAuthNumber();
          setState(() {

          });
        }

        
        
        loadingDialog.hide();
        startTimer();
        setState(() {
          _mode = WalletCreatePageMode.send;
        });
        focusAuthNumber.requestFocus();
      }else {
          final msg = json[ApiParamKey.msg];

        loadingDialog.hide();
        if(msg != "") {
          CommonFunction.showToast(context, msg);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      loadingDialog.hide();
    }

  }
  /// 코드 확인 api 호출
  void validateAuthNumber() async {
    CommonFunction.hideKeyboard(context);

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.checkValidateCode(email: _email, code: _auth);
      final status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {
        loadingDialog.hide();
        timer?.cancel();
        setState(() {
          _mode = WalletCreatePageMode.done;
        });
        pass1Focus.requestFocus();
        if(mounted) {
          CommonFunction.showToast(context, "msg_validate_code".tr());
        }
      }else {
        loadingDialog.hide();
        if(mounted) {
          CommonFunction.showToast(context, "msg_fail_code".tr());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      loadingDialog.hide();
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
