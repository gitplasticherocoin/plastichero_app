import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/api_param_key.dart';
import '../../api/member/check_response.dart';
import '../../api/wallet/wallet_otp.dart';
import '../../constants/color_theme.dart';
import '../../constants/preference_key.dart';
import '../../constants/setting.dart';
import '../../util/common_function.dart';
import '../widget/button_widget.dart';
import '../widget/text_widget.dart';
import 'loading_dialog.dart';

class OtpConfirmDialog extends StatefulWidget {
  final bool isRemoveOtp;
  final VoidCallback? onConfirm;
  final VoidCallback? onRemove;
  const OtpConfirmDialog({
    Key? key,
    this.isRemoveOtp = false,
    this.onConfirm,
    this.onRemove,
  }) : super(key: key);

  @override
  State<OtpConfirmDialog> createState() => _OtpConfirmDialogState();
}

class _OtpConfirmDialogState extends State<OtpConfirmDialog> {
  late final LoadingDialog loadingDialog;
  late final ValueNotifier<bool> btnNotifier;
  late TextEditingController otpController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadingDialog = LoadingDialog(context: context);
    btnNotifier = ValueNotifier<bool>(false);
    otpController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    btnNotifier.dispose();
    otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 14.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 14.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'otp_confirm'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      'images/popup_close.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Text(
              'enter_auth_code_otp_guide'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: Setting.appFont,
                fontWeight: FontWeight.w400,
                color: Color(ColorTheme.c_4b4b4b),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: InputTextField(
              controller: otpController,
              hintText: 'enter_auth_code_placeholder'.tr(),
              keyboardType: TextInputType.number,
              denySpace: true,
              maxLength: 6,
              onChanged: (value) {
                btnNotifier.value = value.trim().length == 6;
              },
            ),
          ),
          const SizedBox(height: 24.0),
          ValueListenableBuilder<bool>(
            valueListenable: btnNotifier,
            builder: (_, isEnable, __) {
              return BtnFill(
                margin: const EdgeInsets.fromLTRB(24, 5, 24, 24),
                onTap: () {
                  CommonFunction.hideKeyboard(context);
                  if (widget.isRemoveOtp) {
                    removeOtpHandler();
                  } else {
                    checkOtpHandler();
                  }
                },
                isEnable: isEnable,
                text: "complete".tr(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> checkOtpHandler() async {
    String token = otpController.text.trim();
    if (token.length < 6) {
      CommonFunction.showToast(context, 'enter_auth_code_placeholder'.tr());
      return false;
    }

    var manager = ApiManagerWalletOtp();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.checkOtp(token: token);
      loadingDialog.hide();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result];
        if (mounted) {
          Navigator.pop(context);
        }
        if (widget.onConfirm != null) {
          widget.onConfirm!.call();
        }
        return true;
      } else {
        if (context.mounted) {
          CommonFunction.showInfoDialog(context, json[ApiParamKey.msg]);
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
        return false;
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> removeOtpHandler() async {
    String token = otpController.text.trim();
    if (token.length < 6) {
      CommonFunction.showToast(context, 'enter_auth_code_placeholder'.tr());
      return false;
    }

    var manager = ApiManagerWalletOtp();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.removeOtp(token: token);
      loadingDialog.hide();

      String status = json[ApiParamKey.status];

      if (status == ApiParamKey.success) {
        dynamic result = json[ApiParamKey.result];
        await CommonFunction.setPreferencesBoolean(PreferenceKey.isOtp, false);

        if (mounted) {
          CommonFunction.showToast(context, 'msg_otp_auth_release'.tr());
          Navigator.pop(context);
        }
        if (widget.onRemove != null) {
          widget.onRemove!.call();
        }
        return true;
      } else {
        if (context.mounted) {
          CommonFunction.showInfoDialog(context, json[ApiParamKey.msg]);
          await CheckResponse.checkErrorResponse(context, json, isToast: false);
        }
        return false;
      }
    } catch (e) {
      loadingDialog.hide();
      debugPrint(e.toString());
    }
    return false;
  }
}
