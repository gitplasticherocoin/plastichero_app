import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';


import '../../util/validate.dart';

class ChangeWalletPasswordArguments {
  final WalletInfo walletInfo;

  ChangeWalletPasswordArguments({required this.walletInfo});
}

class ChangeWalletPasswordPage extends StatefulWidget {
  const ChangeWalletPasswordPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChangeWalletPasswordPageState();
  }
}

class _ChangeWalletPasswordPageState extends State<ChangeWalletPasswordPage> {
  final String tag = 'ChangeWalletPasswordPage';

  final gkChangeWalletPassword = GlobalKey<FormState>();
  late final ValueNotifier<bool> btnNotifier;
  late final LoadingDialog loadingDialog;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController addressTextEditingController = TextEditingController();

  late WalletInfo walletInfo;
  String oldPw = '';
  String pw = '';
  String rePw = '';

  FocusNode oldPwFocusNode = FocusNode();
  FocusNode pwFocusNode = FocusNode();
  FocusNode rePwFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    btnNotifier = ValueNotifier<bool>(false);

    loadingDialog = LoadingDialog(context: context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    btnNotifier.dispose();
    emailTextEditingController.dispose();
    addressTextEditingController.dispose();
    oldPwFocusNode.dispose();
    pwFocusNode.dispose();
    rePwFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChangeWalletPasswordArguments arguments = ModalRoute.of(context)?.settings.arguments as ChangeWalletPasswordArguments;
    walletInfo = arguments.walletInfo;
    emailTextEditingController.text = walletInfo.email;
    addressTextEditingController.text = walletInfo.address;

    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: unFocus,
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: DefaultToolbar(
              titleText: 'change_wallet_password'.tr(),
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
                        child: Form(
                          key: gkChangeWalletPassword,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 2, bottom: 2),
                                constraints: const BoxConstraints(minHeight: 48),
                                child: Text(
                                  'change_password_title'.tr(),
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    height: 1.3,
                                    fontSize: 14,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w400,
                                    color: Color(ColorTheme.defaultText),
                                  ),
                                ),
                              ),
                              // Container(
                              //   margin: const EdgeInsets.only(bottom: 14),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       Container(
                              //         margin: const EdgeInsets.only(bottom: 4),
                              //         child: Text(
                              //           'email'.tr(),
                              //           textAlign: TextAlign.start,
                              //           style: const TextStyle(
                              //             height: 1.3,
                              //             fontSize: 15,
                              //             fontFamily: Setting.appFont,
                              //             fontWeight: FontWeight.w500,
                              //             color: Color(ColorTheme.defaultText),
                              //           ),
                              //         ),
                              //       ),
                              //       InputTextField(
                              //         enabled: false,
                              //         controller: emailTextEditingController,
                              //         textInputAction: TextInputAction.next,
                              //         keyboardType: TextInputType.emailAddress,
                              //         hintText: 'example@example.co.kr',
                              //         maxLines: 2,
                              //         onChanged: (value) {},
                              //         onEditingComplete: () {},
                              //         onFieldSubmitted: (value) {},
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'email'.tr(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          height: 1.3,
                                          fontSize: 15,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      alignment: Alignment.centerLeft,
                                      constraints: const BoxConstraints(minHeight: 50),
                                      decoration: BoxDecoration(
                                        color: const Color(ColorTheme.c_ededed),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        walletInfo.email,
                                        style: const TextStyle(
                                          height: 1.2,
                                          fontSize: 15,
                                          color: Color(ColorTheme.defaultText),
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'wallet_address'.tr(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          height: 1.3,
                                          fontSize: 15,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      alignment: Alignment.centerLeft,
                                      constraints: const BoxConstraints(minHeight: 50),
                                      decoration: BoxDecoration(
                                        color: const Color(ColorTheme.c_ededed),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        walletInfo.address,
                                        style: const TextStyle(
                                          height: 1.2,
                                          fontSize: 15,
                                          color: Color(ColorTheme.defaultText),
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'current_password'.tr(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          height: 1.3,
                                          fontSize: 15,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        ),
                                      ),
                                    ),
                                    FocusScope(
                                      child: PasswordTextField(
                                        focusNode: oldPwFocusNode,
                                        textInputAction: TextInputAction.next,
                                        hintText: 'password_placeholder'.tr(),
                                        onChanged: (value) {
                                          oldPw = value;
                                          setEnableBtn();
                                        },
                                        onEditingComplete: () {},
                                        onFieldSubmitted: (value) {
                                          oldPw = value;
                                          setEnableBtn();
                                        },
                                        validator: (value) {
                                          if (oldPw.isEmpty) {
                                            return "password_placeholder".tr();
                                          }else if (oldPw == pw) {
                                            return "is_old_password".tr();
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                margin: const EdgeInsets.only(top: 2, bottom: 14),
                                color: const Color(ColorTheme.c_ededed),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'change_password_1'.tr(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          height: 1.3,
                                          fontSize: 15,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        ),
                                      ),
                                    ),
                                    FocusScope(
                                      child: NewPasswordTextField(
                                        focusNode: pwFocusNode,
                                        hint: 'password1_placeholder'.tr(),
                                        onChange: (value) {
                                          pw = value;
                                          setEnableBtn();
                                        },
                                        onFieldSubmitted: (value) {
                                          pw = value;
                                          setEnableBtn();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'password2'.tr(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          height: 1.3,
                                          fontSize: 15,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        ),
                                      ),
                                    ),
                                    FocusScope(
                                      child: PasswordTextField(
                                        focusNode: rePwFocusNode,
                                        textInputAction: TextInputAction.next,
                                        hintText: 'pass2_placeholder'.tr(),
                                        onChanged: (value) {
                                          rePw = value;
                                          setEnableBtn();
                                        },
                                        onEditingComplete: () {},
                                        onFieldSubmitted: (value) {
                                          rePw = value;
                                          setEnableBtn();
                                        },
                                        validator: (value) {
                                          if (rePw.isEmpty || rePw != pw) {
                                            return "msg_error_not_match_password".tr();
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
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
                ValueListenableBuilder<bool>(
                  valueListenable: btnNotifier,
                  builder: (_, isEnable, __) {
                    return BtnFill(
                      text: 'change'.tr(),
                      margin: const EdgeInsets.only(left: 24, top: 12, right: 24, bottom: 24),
                      onTap: () {
                        CommonFunction.hideKeyboard(context);

                        pwModify();
                      },
                      isEnable: isEnable,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void unFocus() {
    CommonFunction.hideKeyboard(context);
  }

  void setEnableBtn() {
    btnNotifier.value = checkValidate();
  }

  bool checkValidate() {
    debugPrint("checkValidate start");

    if (!gkChangeWalletPassword.currentState!.validate()) {
      return false;
    }
    if(oldPw == pw) {
      return false;
    }

    if (Validate.validatePassword(pw) != null) {
      return false;
    }

    if (rePw.isEmpty || rePw != pw) {
      return false;
    }

    return true;
  }

  Future<void> pwModify() async {
    debugPrint('pwModify()');

    if (!gkChangeWalletPassword.currentState!.validate()) {
      return;
    }

    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      return;
    }

    if (walletInfo == null) {
      return;
    }

    if (oldPw.trim().isEmpty) {
      oldPwFocusNode.requestFocus();
      return;
    }

    if (pw.trim().isEmpty) {
      pwFocusNode.requestFocus();
      return;
    }

    if (rePw.trim().isEmpty) {
      rePwFocusNode.requestFocus();
      return;
    }

    if (pw != rePw) {
      rePwFocusNode.requestFocus();
      return;
    }

    if (mounted) {
      CommonFunction.hideKeyboard(context);
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.pwModify(
        walletIdx: walletInfo.idx,
        oldPw: oldPw,
        pw: pw,
      );
      loadingDialog.hide();

      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        if (mounted) {
          final masterKey = json[ApiParamKey.masterkey] ?? "";
          final timestamp = json[ApiParamKey.timestamp] ?? "";
          if(masterKey.isNotEmpty && timestamp.isNotEmpty) {
            final deMasterKey = AESHelper().decrypt(masterKey, timestamp);

            if (mounted) {
              Navigator.of(context).pushReplacementNamed(Routes.masterKeyPage, result: true,
                  arguments: {"masterkey": deMasterKey});
            }
          }
          // else {
          //   CommonFunction.showToast(context, 'msg_change_wallet_password'.tr());
          //   Navigator.of(context).pop(true);
          // }
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      loadingDialog.hide();
    }
  }
}
