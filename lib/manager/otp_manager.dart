import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:plastichero/constants/setting.dart';
import 'package:plastichero/ui/widget/text_widget.dart';
import 'package:plastichero_app/util/common_function.dart';

import '../api/api_param_key.dart';
import '../api/member/check_response.dart';
import '../api/wallet/wallet_otp.dart';
import '../constants/preference_key.dart';
import '../routes.dart';
import '../ui/dialog/otp_confirm_dialog.dart';
import '../util/debug.dart';

class OtpManager {
  BuildContext? context;

  OtpManager({
    required this.context,
  });


  Future<void> checkWithdrawl({bool isOtpCheck  = true,required VoidCallback onSuccess, required VoidCallback onFail}) async  {
    Debug.log("OtpManager", " checkWithdrawl start");
    final  withdrawalPass = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? "";
    final withdrawalPassTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? "";
    if(withdrawalPassTs.isNotEmpty && withdrawalPass.isNotEmpty) {
      Debug.log("OtpManager", "checkWithdrawl onSuccess");
      if(isOtpCheck) {
        checkOtp(onSuccess: onSuccess);
      }else {
        onSuccess.call();
      }
    }else {
      Debug.log("OtpManager", "checkWithdrawl onFail");
      onFail.call();
    }
  }

  Future<void> checkOtp({required VoidCallback onSuccess}) async {
    Debug.log("OtpManager", " checkOtp start");
    //수행
    try {
      bool isOtp = await CommonFunction.getPreferencesBoolean(PreferenceKey.isOtp) ?? false;
      if (context == null || !context!.mounted) {
        return;
      }
      if (isOtp) {
        Debug.log("OtpManager", " checkOtp onSuccess");
        // CommonFunction.showBottomSheet(
        //   context: context!,
        //   isDismissible: true,
        //   child: OtpConfirmDialog(
        //     onConfirm: () {
        //       onSuccess.call();
        //     },
        //   ),
        // );
        onSuccess.call();
      } else {
        Debug.log("OtpManager", " checkOtp onFail");
        var result = await Navigator.pushNamed(context!, Routes.otpAuthPage);
        if (result != null && result is bool) {
          if (result) {
            onSuccess.call();
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }


}
