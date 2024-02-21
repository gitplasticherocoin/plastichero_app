import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:plastichero/constants/setting.dart';
import 'package:plastichero/ui/dialog/loading_dialog.dart';
import 'package:plastichero/ui/widget/button_widget.dart';
import 'package:plastichero/ui/widget/text_widget.dart';
import 'package:plastichero/ui/widget/toolbar_widget.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/routes.dart';

import '../../constants/color_theme.dart';

class InputPasswordPage extends StatefulWidget {
  const InputPasswordPage({super.key});

  @override
  State<InputPasswordPage> createState() => _InputPasswordPageState();
}

class _InputPasswordPageState extends State<InputPasswordPage> {
  late final LoadingDialog loadingDialog;
  String _password = "";

  WalletInfo?  _walletInfo;

  FocusNode passFocus = FocusNode();
  bool _isEnableConfirm = false;

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog(context: context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (ModalRoute.of(context)?.settings.arguments != null) {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic> ??
              {};
     _walletInfo = arguments["walletInfo"];
    } else {

    }
    return Scaffold(
      appBar: DefaultToolbar(
        titleText: "master_key_title".tr(),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          height: 1.5,
          fontSize: 20,
          fontFamily: Setting.appFont,
          fontWeight: FontWeight.w500,
          color: Color(0xff121212),
        ),
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ButtonStyle1(
          isEnable: _isEnableConfirm,
          radius: 10.0,
          btnColor: const Color(ColorTheme.appColor),
          disableColor: const Color(0xffdbdbdb),
          textColor: Colors.white,
          text: 'confirm'.tr(),
          onTap: requestPassword,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Text("master_key_input_password_desc".tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.0 ,
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff121212),
                                    )
                                  ),
                const SizedBox(height:20),
                Text("pass".tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.0 ,
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.2,
                                      color: Color(0xff121212),
                                    )
                                  ),
                const SizedBox(height:6),
                NewPasswordTextField(
                  focusNode: passFocus,
                  hint: "input_password".tr(),
                  // keyboardType: TextInputType.visiblePassword,
                  // textInputAction: TextInputAction.next,
                  onChange: (value) {
                    _password = value;
                    _password = _password.trim();
                    checkValidatePass();

                  },

                  onFieldSubmitted: (value) {
                    _password = value;
                    _password = _password.trim();
                    checkValidatePass();
                  },
                ),


              ],
            ),
          ),
        ),
      )
    );
  }
  void checkValidatePass() {

    bool isEnable = false;

      if(_password.length >= 8  ) {
            isEnable = true;
      }else {
        isEnable = false;
      }

    setState(() {
      _isEnableConfirm = isEnable;
    });
  }


  void  requestPassword() async  {
    final idx = _walletInfo?.idx ?? 0 ;
    if(idx == 0) {
      return;
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.getMasterKey(idx: idx , pass: _password);
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
    } catch(e) {
      debugPrint(e.toString());
      loadingDialog.hide();
    }
  }

}
