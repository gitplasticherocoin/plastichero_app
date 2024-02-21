import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/confirm_dialog.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/validate.dart';

class AccountLinkSelect extends StatefulWidget {
  const AccountLinkSelect({Key? key}) : super(key: key);

  @override
  State<AccountLinkSelect> createState() => _AccountLinkSelectState();
}

class _AccountLinkSelectState extends State<AccountLinkSelect> {

  final gkAccountLink = GlobalKey<FormState>();
  late final TextEditingController _idTextEditingController;
  late final TextEditingController _passTextEditingController;


  late final FocusNode passwordFocus;
  bool _isEnableAccountLink = false;

  String _certUserInfo = "";
  String _snsInfo = "";
  String _param = "";
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
    final Map<String, dynamic> arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _certUserInfo = arguments["cert_user_info"] ?? "" ;
    _snsInfo = arguments["sns_info"] ?? "";
    _param = arguments["param"] ?? "";

    return Scaffold(
        appBar: DefaultToolbar(
          isBackButton: true,
          onBackPressed: () {
            Navigator.of(context).pop();
          },
          centerTitle: false,
          titleText: "account_link".tr(),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: GestureDetector(
                      onTap: unFocus,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Text("account_link_select_title".tr(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  height: 30 / 22,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w700,
                                  color: Color(ColorTheme.defaultText),
                                )),
                            const SizedBox(
                              height: 6,
                            ),
                            Text("account_link_select_subtitle".tr(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  letterSpacing: -0.21,
                                  fontSize: 14,
                                  height: 18 / 14,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w500,
                                  color: Color(ColorTheme.defaultText),
                                )),
                            const SizedBox(
                              height: 24,
                            ),
                            Form(
                              key: gkAccountLink,
                              child: Column(
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
                                  InputTextField(
                                    controller: _idTextEditingController,
                                    validator: (value) {
                                      return Validate.validateId(value);
                                    },
                                    hintText: "id_placeholder".tr(),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.emailAddress,
                                    onFieldSubmitted: (value) {
                                      passwordFocus.requestFocus();
                                    },
                                    isOutline: false,
                                    fixedLineColor: null,
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
                                      checkValidate();
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
                            ),
                            const Spacer(),

                            Visibility(
                              visible: MediaQuery.of(context).viewInsets.bottom <=0.0,
                              child: Column(
                                children: [
                                  BtnBorderAppColor(
                                    onTap: deny,
                                    text: "account_link_deny".tr(),
                                  ),
                                  const SizedBox(height: 12),
                                  BtnFill(
                                      isEnable: _isEnableAccountLink,
                                      onTap: snsLinkAccount,
                                      text: "account_link_accept".tr()),
                                  const SizedBox(height: 24),
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
            ),
          ),
        ));
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  Future<void> deny() async {
    await showDialog(
    context: context,
    builder:(BuildContext context) => ConfirmDialog(
        title:"wait".tr(),
        body: "account_link_dialog".tr(),
        btnCancelText: "cancel".tr(),
        btnConfirmText: "confirm".tr(),
        onCancel: () {

        },
      onConfirm: snsJoin,
    ));




  }

  Future<void> accept() async {

  }


  Future<void> snsJoin() async {


    Navigator.of(context).pushNamed(Routes.signupPage,
    arguments: {
    "cert_user_info" : _certUserInfo,
    "sns_info":_snsInfo,
    "param": _param,
    "from": "snsJoinCancel"
    });



    // if(_certUserInfo != "" && _snsInfo != "") {
    //   var manager = ApiManagerMember();
    //   dynamic json;
    //   try {
    //     json =  await manager.accountLinkCancel(certUserInfo: _certUserInfo, snsInfo: _snsInfo);
    //     print("json : $json");
    //     String status = json[ApiParamKey.status];
    //     if(status == ApiParamKey.success) {
    //       dynamic result = json[ApiParamKey.result];
    //
    //       print(result);
    //
    //     }else {
    //       dynamic result = json["result"];
    //       final String msg = result["msg"] ?? "";
    //
    //       if (msg != "") {
    //         CommonFunction.showToast(context, msg);
    //       }
    //     }
    //   }catch (e) {
    //
    //   }
    // }

  }

  Future<void> loginHander(MemberInfo memberInfo) async {

    //약관 동의 페이지로 이동

    if(memberInfo.code == null) {
      return;
    }
    //
    await CommonFunction.setPreferencesString(PreferenceKey.sessionCode, memberInfo.code ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.email, memberInfo.mbEmail ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginId,memberInfo.mbId ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginName, memberInfo.mbName ?? "");
    await CommonFunction.setPreferencesString(PreferenceKey.loginPhone, memberInfo.mbHp ?? "");
    await CommonFunction.setPreferencesString(
        PreferenceKey.snsIsJoin, memberInfo.isJoin ?? "");
    //
    // print("로그인 ==================");
    //
    // print(memberInfo.code);
    // print(memberInfo.mbEmail);
    // print(memberInfo.mbId);
    // print(memberInfo.mbName);
    // print(memberInfo.mbHp);
    // print("로그인 ==================");
    //
    // Navigator.of(context).pushNamedAndRemoveUntil(Routes.signupDonePage, (route) => false);
  }
  Future<void> snsLinkAccount() async {

    final String id = _idTextEditingController.text;
    final String pw = _passTextEditingController.text;

    if(id != "" && pw != "") {
      var manager = ApiManagerMember();
      dynamic json;
      try {
        loadingDialog.show();
        json = await manager.accountLinkConfirm(
            certUserInfo: _certUserInfo, snsInfo: _snsInfo, id: id, pw: pw , param: _param);
        String status = json[ApiParamKey.status];
        if (status == ApiParamKey.success) {
          dynamic result = json[ApiParamKey.result];
          MemberInfo memberInfo = MemberInfo.fromJson(result);
          await loginHander(memberInfo);
          goMainPage();
        } else {
           if(context.mounted) {
             await CheckResponse.checkErrorResponse(context, json);
          }
        }
      } catch (e){
       debugPrint(e.toString());
      }finally {
        loadingDialog.hide();
      }
    }
  }

  void goMainPage() {
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
  }

  void showToast(String msg) {
    CommonFunction.showToast(context, msg);
  }

  checkValidate() {
    bool isEnable = false;
    if(gkAccountLink.currentState!.validate()) {
      isEnable = true;
    }
    setState(() {
      _isEnableAccountLink = isEnable;
    });
  }
}

