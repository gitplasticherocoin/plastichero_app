import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/validate.dart';

class SignOutPage extends StatefulWidget {
  const SignOutPage({Key? key}) : super(key: key);

  @override
  State<SignOutPage> createState() => _SignOutPageState();
}

class _SignOutPageState extends State<SignOutPage> {
  final gkSignOut = GlobalKey<FormState>();

  late final TextEditingController _idTextController;
  late final TextEditingController _passTextController;
  late final FocusNode _passFocus;

  bool _isEnableConfirm = false;
  late final LoadingDialog loadingDialog;
  @override
  void initState() {
    super.initState();
    _idTextController = TextEditingController();
    _passTextController = TextEditingController();
    _passFocus = FocusNode();
    loadingDialog = LoadingDialog(context: context);
  }

  @override
  void dispose() {
    super.dispose();
    _idTextController.dispose();
    _passTextController.dispose();
    _passFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DefaultToolbar(
          titleText: "sign_out".tr(),
          isBackButton: true,
          onBackPressed: () {
            Navigator.of(context).pop();
          },
          centerTitle: false,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: unFocus,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: gkSignOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Text("sign_out_title".tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Color(ColorTheme.defaultText),
                        )),
                    const SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text("id".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.0,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w700,
                            color: Color(ColorTheme.defaultText),
                          )),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    InputTextField(
                      controller: _idTextController,
                      hintText: "id_placeholder".tr(),
                      validator: (value) {
                        return Validate.validateId(value);
                      },
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        checkIsEnableConfirm();
                      },
                      onFieldSubmitted: (value) {
                        _passFocus.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text("password".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.0,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w700,
                            color: Color(ColorTheme.defaultText),
                          )),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    PasswordTextField(
                      focusNode: _passFocus,
                      validator: (value) {
                        return Validate.validatePassword(value);
                      },
                      hintText: "password_placeholder".tr(),
                      onChanged: (value) {
                        checkIsEnableConfirm();
                      },
                      onFieldSubmitted: (value) {
                        unFocus();
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
                        text: "sign_out_short".tr(),
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

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  void confirm() {
    unFocus();
    signOut();

  }

  Future<void> signOut() async {
    final String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if(sessionCode == "") {
      return;
    }

    var manager = ApiManagerMember();
    dynamic json;
    try {
      loadingDialog.show();
      json = manager.outMember(code: sessionCode);
      String status = json[ApiParamKey.status];
      if(status == ApiParamKey.success) {

        if(mounted) {
          Navigator.of(context).pushNamed(Routes.signOutDonePage);
        }

      }else {
        if(context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    }catch (e) {
      debugPrint(e.toString());
    }finally {
      loadingDialog.hide();
    }
  }

  void checkIsEnableConfirm() {
    bool isEnable = false;
    if (gkSignOut.currentState!.validate()) {
      isEnable = true;
    }
    setState(() {
      _isEnableConfirm = isEnable;
    });
  }
}
