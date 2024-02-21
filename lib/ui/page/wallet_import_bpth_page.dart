import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/validate.dart';

import '../../api/wallet/wallet_bpth.dart';
import '../dialog/loading_dialog.dart';

class WalletImportBPTHPage extends StatefulWidget {
  const WalletImportBPTHPage({super.key});

  @override
  State<WalletImportBPTHPage> createState() => WalletImportBPTHPageState();
}

class WalletImportBPTHPageState extends State<WalletImportBPTHPage> {
  late final LoadingDialog loadingDialog;
  late final TextEditingController _privateKeyTextController;
  late final FocusNode privateKeyFocus;
  bool _isEnableConfirm = false;
  String _privateKey = '';

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog(context: context);
    _privateKeyTextController = TextEditingController();
    privateKeyFocus = FocusNode();
  }

  @override
  void dispose() {
    _privateKeyTextController.dispose();
    privateKeyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text("private_key".tr(),
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
                    controller: _privateKeyTextController,
                    hintText: "private_key_placeholder".tr(),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      _privateKey = value;
                      _privateKey = _privateKey.trim();

                      if (_privateKey.isNotEmpty && _privateKey.length == 32 &&  !_isEnableConfirm) {
                        setState(() {
                          _isEnableConfirm = true;
                        });
                      } else if ((_privateKey.isEmpty && _isEnableConfirm) || _privateKey.length < 32) {
                        setState(() {
                          _isEnableConfirm = false;
                        });
                      }
                    },
                    onFieldSubmitted: (value) {
                      _privateKey = _privateKeyTextController.text;
                      privateKeyFocus.requestFocus();
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
        ));
  }

  void goBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> importWallet() async {
    if (mounted) {
      CommonFunction.hideKeyboard(context);
    }
    var manager = ApiManagerBPTHWallet();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.import(wif: _privateKey);
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
