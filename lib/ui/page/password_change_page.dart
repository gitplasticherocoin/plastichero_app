import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/api/api_manager_sms.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/validate.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({Key? key}) : super(key: key);

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final gkPassChange = GlobalKey<FormState>();

  late final TextEditingController _pass1TextController;
  late final TextEditingController _pass2TextController;
  late FocusNode _pass2Focus;
  late FocusNode _pass1Focus;
  CertChangeType _certChangeType = CertChangeType.undefined;

  bool _isEnableConfirm = false;
  String _password = '';

  String _passwordConfirm = '';
  String _param = "";
  String _from = "";
  String _certUserInfo = "";

  @override
  void initState() {
    super.initState();
    _pass1TextController = TextEditingController();
    _pass2TextController = TextEditingController();
    _pass1Focus = FocusNode();
    _pass2Focus = FocusNode();
  }

  @override
  void dispose() {
    _pass1TextController.dispose();
    _pass1TextController.dispose();
    _pass1Focus.dispose();
    _pass2Focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    _param = arguments["param"] ?? "";
    _certChangeType = arguments["certChangeType"] ?? CertChangeType.undefined;
    _from = arguments["from"] ?? "";
    _certUserInfo = arguments["cert_user_info"] ?? "";
    return Scaffold(
        appBar: DefaultToolbar(
          titleText: "change_password".tr(),
          isBackButton: true,
          onBackPressed: goBack,
          centerTitle: false,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: unFocus,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: gkPassChange,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Text("change_password_title".tr(),
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
                      height: 15,
                    ),
                    Text("password".tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w700,
                          color: Color(ColorTheme.defaultText),
                        )),
                    const SizedBox(
                      height: 6,
                    ),
                    NewPasswordTextField(
                      hint: "change_password_title".tr(),
                      validator: (value) {
                        return Validate.validatePassword(value);
                      },
                      onChange: (value) {
                        _password = value.trim();

                        checkValidate();
                        checkValidatePass();
                      },
                      onSaved: (value) {
                        _password = value ?? "";
                        _password = _password.trim();
                        checkValidatePass();
                      },
                      onFieldSubmitted: (value) {
                        _password = value;
                        _password = _password.trim();
                        checkValidatePass();
                        _pass2Focus.requestFocus();
                      },
                      focusNode: _pass1Focus,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text("password2".tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w700,
                          color: Color(ColorTheme.defaultText),
                        )),
                    const SizedBox(
                      height: 6,
                    ),
                    PasswordTextField(
                      focusNode: _pass2Focus,
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
                        checkValidatePass();
                      },
                      onFieldSubmitted: (value) {
                        checkValidate();
                        checkValidatePass();
                        unFocus();
                      },
                      validator: (value) {
                        if (_passwordConfirm.isNotEmpty &&
                            _passwordConfirm != _password) {
                          return "msg_error_not_match_password".tr();
                        }
                        return Validate.validatePassword(_password);
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
                        text: "change".tr(),
                        onTap: confirm,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void confirm() async {
    changeAccount();
  }

  void changeAccount() async {
    final code =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";

    if (!mounted) {
      return;
    }
    if (code != "") {}
    unFocus();
    var manager = ApiManagerSMS();
    dynamic json;

    try {
      json = await manager.changeAccount(
          type: CertChangeType.pass.type,
          param: _param,
          sessionCode: code,
          pw: _password);

      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        if(code == "") {
          if(mounted) {
            final msg = json[ApiParamKey.result] ?? "";
            CommonFunction.showToast(context, msg);
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.loginPage, (route) => false);
            });

          }
        }else {
          final msg = json[ApiParamKey.result] ?? "";
          if (msg != "" && mounted) {
            CommonFunction.showToast(context, msg);
            Future.delayed(const Duration(milliseconds: 500), () {
              goBack();
            });
          } else {
            goBack();
          }
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

  void goBack() {
    Navigator.of(context).pop();
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  void checkValidate() {
    bool isEnable = false;
    if (_password == "" || _passwordConfirm == "") {
      setState(() {
        _isEnableConfirm = false;
      });
      return;
    }
    if (gkPassChange.currentState!.validate()) {
      isEnable = true;
    }

    if (Validate.validatePassword(_password) != null) {
      setState(() {
        _isEnableConfirm = false;
      });
      return;
    }

    bool isPw =
        (Validate.validatePwCompare(_password, _passwordConfirm) ?? '').isEmpty;

    setState(() {
      _isEnableConfirm = isPw;
    });
  }

  void checkValidatePass() {
    if (_password == "" || _passwordConfirm == "") {
      setState(() {
        _isEnableConfirm = false;
      });
      return;
    } else {
      bool isPw =
          (Validate.validatePwCompare(_password, _passwordConfirm) ?? '')
              .isEmpty;
      debugPrint("isPw : $isPw");
      setState(() {
        _isEnableConfirm = isPw;
      });
    }
  }
}
