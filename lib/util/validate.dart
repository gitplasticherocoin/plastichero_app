import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:sprintf/sprintf.dart';

class Validate {
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'name_placeholder'.tr();
    } else if (name.contains(' ')) {
      return 'msg_error_name_not_space'.tr();
    } else if (name.length < 2) {
      return 'name_placeholder'.tr();
    }
    return null;
  }


  static String? validateId(String? id) {
    if (id == null || id.isEmpty) {
      return 'id_placeholder'.tr();
    } else if (id.contains(' ')) {
      return 'msg_error_id_not_space'.tr();
    }
    return null;
  }

  static String? validatePassword(String? password) {


    const String patternNumber = '^.*[0-9]';
    const String patternSpecialChar = r'^.*[~!@#$%^&*()_+\-=\[\]{}\\|;:,.<>/?]';
    final RegExp regexNumber = RegExp(patternNumber);
    final RegExp regexSpecial = RegExp(patternSpecialChar);
    String pwPattern =
        r"^[a-z|A-Z|0-9|~!@#$%^&*()_+\-=\[\]{}\\|;:,.<>/?]{8,32}$";
    final RegExp regexPass = RegExp(pwPattern);
      if (password == null || password.isEmpty) {
      return "msg_error_empty_password".tr();
    } else if (password.length < 8 || password.length > 32) {
      return "msg_error_valid_password_format".tr();
    } else if (!regexNumber.hasMatch(password)) {
      return "msg_error_valid_password_format".tr();
    } else if (!regexSpecial.hasMatch(password)) {
      return "msg_error_valid_password_format".tr();
    } else if (!regexPass.hasMatch(password)) {
        return 'msg_error_valid_password_format'.tr();
      }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'msg_error_empty_email'.tr();
    } else if (email.contains(' ')) {
      return 'msg_error_email_not_spaces'.tr();
    }

    String pattern = r"^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,})+$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email)) {
      return 'msg_error_valid_email_format'.tr();
    }
    return null;
  }

  static String? validatePwCompare(String password, String passwordConfirm) {
    if (password.isEmpty || passwordConfirm.isEmpty) {
      return 'msg_error_empty_password'.tr();
    } else if (password != passwordConfirm) {
      return 'msg_error_not_match_password'.tr();
    }

    // String pwPattern =
    //     r"^(?=.*[a-zA-Z]+)(?=.*[0-9]+)(?=.*[~!@#$%^&*()_+\-=\[\]{}\\|;:,.<>/?]+).{8,32}$";
    String pwPattern =
        r"^[a-z|A-Z|0-9|~!@#$%^&*()_+\-=\[\]{}\\|;:,.<>/?]{8,32}$";
    RegExp regex = RegExp(pwPattern);
    if (!regex.hasMatch(passwordConfirm)) {
      return 'msg_error_valid_password_format'.tr();
    }
    return null;
  }

  static String? validateNick(String? nickname) {
    String pattern =
        r"^[ㄱ-ㅎ|가-힣|a-z|A-Z|0-9|กขฃคฅฆงจฉชซฌญฎฏฐฑฒณดตถทธนบปผฝพฟภมยรฤลฦวศษสหฬอฮฯะัาำิีึืฺุู฿เแโใไๅๆ็่้๊๋์ํ๎๏๐๑๒๓๔๕๖๗๘๙๚๛]{2,10}$";
    RegExp regex = RegExp(pattern);

    if (nickname == null || nickname.isEmpty) {
      return 'msg_error_empty_nickname'.tr();
    } else if (nickname.characters.length < 2 ||
        nickname.characters.length > Setting.nickMaxLength) {
      return sprintf('msg_error_nickname_length'.tr(), [Setting.nickMaxLength]);
    } else if (!regex.hasMatch(nickname)) {
      return 'msg_error_cannot_be_used'.tr();
    }

    return null;
  }

  static String? validateAmount(
      String totalAmount, String amount, String? fee) {
    print('validateAmount');
    if (amount.isEmpty) {
      return 'msg_send_amount_empty'.tr();
    }

    if (fee == null || fee.isEmpty) {
      fee = '0';
    }

    try {
      Decimal dTotalAmount = Decimal.parse(totalAmount.replaceAll(',', ''));
      Decimal dAmount = Decimal.parse(amount.replaceAll(',', ''));
      Decimal dFee = Decimal.parse(fee.replaceAll(',', ''));

      print(
          '## dTotalAmount = ${dTotalAmount.toString()}, _amount =${dAmount.toString()}, _fee = ${dFee.toString()} ');

      var split = amount.split('.');

      String pattern = r"^[0-9\.]*$";
      RegExp regex = RegExp(pattern);
      if (!regex.hasMatch(dAmount.toString())) {
        return 'msg_send_amount_format_error'.tr();
      } else if (dAmount <= Decimal.zero) {
        return 'msg_send_amount_empty'.tr();
      } else if (split.length > 1 && split[1].length > Setting.scaleNum) {
        return 'msg_send_amount_format_error'.tr();
      } else if (dTotalAmount < (dAmount + dFee)) {
        return 'msg_send_not_enough_balance'.tr();
      }
    } catch (e) {
      return 'msg_send_amount_format_error'.tr();
    }

    return null;
  }

  static bool validateUrlFormat(String urlPath) {
    String pattern =
        r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-zA-Z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)";
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(urlPath);
  }

  static String? validateHashtag(
    String hashtag, {
    int maxNum = Setting.hashtagMaxNum,
    int maxLength = Setting.hashtagMaxLength,
  }) {
    RegExp regHash = RegExp(Common.regHashtag);
    if (hashtag.contains(' ')) {
      return 'msg_error_hashtag_space_char'.tr();
    } else if (!regHash.hasMatch(hashtag)) {
      return 'msg_error_cannot_be_used_hashtag'.tr();
    } else if (hashtag.characters.length > maxLength + 1) {
      return sprintf('msg_error_hashtag_max_length'.tr(), [maxLength]);
    }

    return null;
  }
}
