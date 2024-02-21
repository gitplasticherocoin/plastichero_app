import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/validate.dart';

class WalletImportPage extends StatefulWidget {
  const WalletImportPage({super.key});

  @override
  State<WalletImportPage> createState() => _WalletImportPageState();
}

class _WalletImportPageState extends State<WalletImportPage> {
  late final LoadingDialog loadingDialog;
  final gkWalletImport = GlobalKey<FormState>();
  late final TextEditingController _emailTextController;
  late final TextEditingController _pass1TextController;
  late final FocusNode pass1Focus;
  late final FocusNode emailFocus;
  bool _isEnableConfirm = false;
  String _password = '';
  String _email = "";

  @override
  void initState() {
    super.initState();

    loadingDialog = LoadingDialog(context: context);
    _emailTextController = TextEditingController();
    _pass1TextController = TextEditingController();
    pass1Focus = FocusNode();
    emailFocus = FocusNode();
  }

  @override
  void dispose() {
    _pass1TextController.dispose();
    _emailTextController.dispose();
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
          titleText: "get_wallet".tr(),
          centerTitle: false,
        ),
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: gkWalletImport,
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
                        pass1Focus.requestFocus();
                        checkValidate();
                      },
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
                      validator: (value) {
                        return Validate.validatePassword(value);
                      },
                      onChange: (value) {
                        _password = value.trim();

                        checkValidate();
                      },
                      onSaved: (value) {
                        _password = value ?? "";
                        _password = _password.trim();
                        checkValidate();
                      },
                      onFieldSubmitted: (value) {
                        // _pass2Focus.requestFocus();
                        checkValidate();
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: BtnFill(
                        onTap: importWallet,
                        isEnable: _isEnableConfirm,
                        text: "get".tr(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void goBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void checkValidate() {
    debugPrint("checkValidate start");
    bool isEnable = false;

    if (gkWalletImport.currentState!.validate()) {
      isEnable = true;
    }
    setState(() {
      _isEnableConfirm = isEnable;
    });
  }

  Future<void> importWallet() async {
    if (mounted) {
      CommonFunction.hideKeyboard(context);
    }
    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();

      json = await manager.import(email: _email, pw: _password);
      loadingDialog.hide();

      final status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        //TODO:
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final msg = json['msg'] ?? "";
        if (msg != "" && mounted) {
          CommonFunction.showToast(context, msg);
        }
        if (mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }
  }
}
