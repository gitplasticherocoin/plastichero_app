import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/validate.dart';
import 'package:provider/provider.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final gkChangeEmail = GlobalKey<FormState>();
  late final TextEditingController _emailTextController;
  bool _isEnableConfirm = false;
  MyinfoProvider? myInfoPovider;
  @override
  void initState() {
    super.initState();
    _emailTextController = TextEditingController();
    myInfoPovider = Provider.of<MyinfoProvider>(context, listen: false);

  }

  @override
  void dispose() {
    _emailTextController.dispose();
    myInfoPovider = null;
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DefaultToolbar(
          titleText: "change_email".tr(),
          isBackButton: true,
          onBackPressed: () {
            unFocus();
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
                key: gkChangeEmail,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Text("change_email_title".tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Color(ColorTheme.defaultText),
                        )),
                    const SizedBox(height: 24),
                    Text("email".tr(),
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
                    InputTextField(
                      controller: _emailTextController,
                      isOutline: false,
                      hintText: "email_placeholder".tr(),
                      validator: (value) {
                        return Validate.validateEmail(value);
                      },
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        checkIsEnableConfirm();
                      },
                      onFieldSubmitted: (value) {
                        checkIsEnableConfirm();
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

  void confirm() {
    unFocus();

    changeEmail();
  }

  Future<void> changeEmail() async {
    final String code = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    final String email = _emailTextController.text;

    var manager = ApiManagerMember();
    dynamic json;
    try {
        json = await manager.changeEmail(code: code, email: email);
        final String status = json[ApiParamKey.status];
        if(status == ApiParamKey.success) {

          if(mounted) {
            save(email);
            myInfoPovider?.callRefresh();
            Navigator.of(context).pop();
          }
        }else {
          if(context.mounted) {
            await CheckResponse.checkErrorResponse(context, json);
          }
        }
    }catch(e)  {
      debugPrint(e.toString());
    }
  }
  Future<void> save(String email) async {
    if(email != "" && email.isNotEmpty) {
      await CommonFunction.setPreferencesString(PreferenceKey.email, email);
    }
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  void checkIsEnableConfirm() {
    bool isEnable = false;
    if (gkChangeEmail.currentState!.validate()) {
      isEnable = true;
    }
    setState(() {
      _isEnableConfirm = isEnable;
    });
  }
}
