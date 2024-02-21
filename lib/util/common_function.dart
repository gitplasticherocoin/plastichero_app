import 'dart:io';
import 'dart:ui' as ui;

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/dialog/confirm_dialog.dart';
import 'package:plastichero_app/ui/dialog/info_dialog.dart';
import 'package:plastichero_app/ui/widget/custom_toast_view.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/dialog/bottom_dialog.dart';

class CommonFunction {
  static const String tag = 'CommonFunction';

  CommonFunction._();

  static void copyData(BuildContext context, String data, {String? toastMsg}) async {
    Clipboard.setData(ClipboardData(text: data));

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt > 32) {
        return;
      }
    }

    // ignore: use_build_context_synchronously
    CommonFunction.showToast(context, toastMsg ?? 'copied'.tr());
  }

  static Future<String?> pasteData() async {
    ClipboardData? clipData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipData != null) {
      return clipData.text;
    } else {
      return null;
    }
  }

  static Future<void> removePreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future<void> setPreferencesStringList(String key, List<String> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, data);
  }

  static Future<void> setPreferencesString(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  static Future<List<String>?> getPreferencesStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future<String?> getPreferencesString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setPreferencesInt(String key, int data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, data);
  }

  static Future<int?> getPreferencesInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> setPreferencesDouble(String key, double data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, data);
  }

  static Future<double?> getPreferencesDouble(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> setPreferencesBoolean(String key, bool data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, data);
  }

  static Future<bool?> getPreferencesBoolean(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static void showBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isDismissible = false,
    bool enableDrag = false,
    bool isScrollControlled = true,
  }) {
    showModalBottomSheet<void>(
      context: context,
      barrierColor: const Color(ColorTheme.dim),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          child: SafeArea(
            top: false,
            child: BottomDialog(child: child),
          ),
        );
      },
    );
  }

  static Future<void> showConfirmDialog(
      {required BuildContext context, required String? msg, required VoidCallback onConfirm, String? btnCancelText, String? btnConfirmText, bool isAwait = false}) async {
    if (isAwait) {
      await showDialog(
        context: context,
        barrierColor: const Color(ColorTheme.dim),
        barrierDismissible: false,
        builder: (BuildContext context) => ConfirmDialog(
          body: msg ?? '',
          onConfirm: onConfirm,
          btnConfirmText: btnConfirmText,
          btnCancelText: btnCancelText,
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierColor: const Color(ColorTheme.dim),
        barrierDismissible: false,
        builder: (BuildContext context) => ConfirmDialog(
          body: msg ?? '',
          onConfirm: onConfirm,
          btnConfirmText: btnConfirmText,
          btnCancelText: btnCancelText,
        ),
      );
    }
  }

  static Future<void> showCancelConfirmDialog(
      {required BuildContext context, required String? msg, required VoidCallback onCancel, required VoidCallback onConfirm, String? btnCancelText, String? btnConfirmText, bool isAwait = false,}) async {
    if (isAwait) {
      await showDialog(
        context: context,
        barrierColor: const Color(ColorTheme.dim),
        barrierDismissible: false,
        builder: (BuildContext context) => ConfirmDialog(
          body: msg ?? '',
          onConfirm: onConfirm,
          onCancel: onCancel,
          btnConfirmText: btnConfirmText,
          btnCancelText: btnCancelText,
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierColor: const Color(ColorTheme.dim),
        barrierDismissible: false,
        builder: (BuildContext context) => ConfirmDialog(
          body: msg ?? '',
          onConfirm: onConfirm,
          onCancel: onCancel,
          btnConfirmText: btnConfirmText,
          btnCancelText: btnCancelText,
        ),
      );
    }
  }


  static void showInfoDialog(BuildContext context, String? msg, {String? title, String? btnText, VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      barrierColor: const Color(ColorTheme.dim),
      barrierDismissible: false,
      builder: (BuildContext context) => InfoDialog(
        title: title,
        body: msg ?? '',
        btnText: btnText ?? 'confirm'.tr(),
        onConfirm: onConfirm,
      ),
    );
  }

  static void showToast(BuildContext? context, String msg, {double bottom = 30.0}) {
    if (context != null) {
      FToast fToast = FToast();
      fToast.removeCustomToast();
      fToast.init(context);
      fToast.showToast(
          child: CustomToastView(msg: msg),
          toastDuration: const Duration(seconds: 3),
          gravity: ToastGravity.BOTTOM,
          positionedToastBuilder: (context, child) {
            return Positioned(
              bottom: bottom,
              right: 0,
              left: 0,
              child: child,
            );
          });
    } else {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "linear-gradient(to right, #ccff3835, #ccff3835)",
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color(ColorTheme.defaultText).withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 15.0,
      );
    }
  }

  static void showConnectErrorDialog(BuildContext context, dynamic json) {
    String? msg = 'connect_error'.tr();
    try {
      if (json != null) {
        msg = json["msg"];
        if (msg == null || msg.isEmpty) {
          msg = 'connect_error'.tr();
        }
      }
    } catch (e) {
      Debug.log(tag, 'showConnectErrorDialog e = ${e.toString()}');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => InfoDialog(
        body: msg ?? 'connect_error'.tr(),
        btnText: 'confirm'.tr(),
      ),
    );
  }

  static void showConnectErrorToast(BuildContext? context, dynamic json) {
    String? msg = 'connect_error'.tr();
    try {
      if (json != null) {
        msg = json["msg"];
        if (msg == null || msg.isEmpty) {
          msg = 'connect_error'.tr();
        }
      }
    } catch (e) {
      Debug.log(tag, 'showConnectErrorDialog e = ${e.toString()}');
    }

    showToast(context, msg ?? 'connect_error'.tr());
  }

  // static Future<String> createDynamicPostLink({String? query}) async {
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: Platform.isAndroid ? 'https://plastichero.page.link/' : 'https://plastichero.page.link',
  //     link: Uri.parse('https://com.plastichero.wallet/?$query'),
  //     androidParameters: const AndroidParameters(
  //       packageName: "com.plastichero.wallet",
  //       minimumVersion: 0,
  //     ),
  //     iosParameters: const IOSParameters(
  //       bundleId: "com.plastichero.wallet",
  //       minimumVersion: '0',
  //     ),
  //   );
  //   final Uri url = await FirebaseDynamicLinks.instance.buildLink(parameters);
  //   return url.toString();
  // }

  static String getConnectErrorText(dynamic json) {
    String? msg = 'connect_error'.tr();
    try {
      if (json != null) {
        msg = json["msg"];
        if (msg == null || msg.isEmpty) {
          msg = 'connect_error'.tr();
        }
      }
    } catch (e) {
      Debug.log(tag, 'showConnectErrorDialog e = ${e.toString()}');
    }

    return msg ?? 'connect_error'.tr();
  }

  static String getVideoTime(int duration) {
    int hour = duration ~/ (60 * 60);
    int rest = duration - (hour * 60 * 60);
    int min = rest ~/ (60);
    rest = rest - (min * 60);

    StringBuffer time = StringBuffer();
    if (hour > 0) {
      time.write(getVideoTimeFormat(hour, format: '0'));
      time.write(":");
      time.write(getVideoTimeFormat(min));
    } else {
      time.write(getVideoTimeFormat(min, format: '0'));
    }
    time.write(":");
    time.write(getVideoTimeFormat(rest));

    return time.toString();
  }

  static String getVideoTimeFormat(int value, {String format = '00'}) {
    var formatter = NumberFormat(format);
    return formatter.format(value);
  }

  // TODO: getFolderPath()
  static Future<String> getFolderPath(String folderPath) async {
    Directory? appDirectory;
    if (Platform.isIOS) {
      appDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDirectory = await getExternalStorageDirectory();
    }

    final Directory tempDirectory = Directory('${appDirectory!.path}$folderPath');
    bool isExists = await tempDirectory.exists();
    if (!isExists) {
      await tempDirectory.create(recursive: true);
      Debug.log(tag, '## folder create path = ${tempDirectory.path}');
    }
    return tempDirectory.path;
  }

  // TODO: saveCropImage()
  static Future<File> saveCropImage(ui.Image img, String folderPath) async {
    Debug.log(tag, '## width = ${img.width}, height = ${img.height}');
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();
    // final result = await ImageGallerySaver.saveImage(buffer);

    final Directory saveDirectory = Directory(folderPath);
    if (!(await saveDirectory.exists())) {
      await saveDirectory.create(recursive: true);
      Debug.log(tag, '## create folder = ${saveDirectory.path}');
    }

    String fileName = 'temp_${DateTime.now().millisecondsSinceEpoch.toString()}.png';

    final imgFile = File('$folderPath/$fileName');
    await imgFile.writeAsBytes(pngBytes);

    Debug.log(tag, '## cropImage imgFile = $imgFile');
    return imgFile;
  }

  static String getDecimalFormat(Decimal? value, {int decimalDigits = -1}) {
    String result = '';
    if (value != null) {
      try {
        var formatter = NumberFormat(Setting.decimalFormat);
        String decimalValue = '';
        if (decimalDigits > -1) {
          decimalValue = cutDecimalPoint(value.toString(), decimalDigits);
        } else {
          decimalValue = value.toString();
        }

        result = formatter.format(DecimalIntl(Decimal.parse(decimalValue)));
      } catch (e) {
        Debug.log(tag, '## getDecimalFormat error : $e');
      }
    }
    return result;
  }

  static String getDecimalFormatFormString(String? value, {int decimalDigits = -1, String format = Setting.decimalFormat}) {
    String result = '';
    if (value != null && value.isNotEmpty) {
      try {
        Decimal decimalValue;
        if (decimalDigits > -1) {
          decimalValue = Decimal.parse(cutDecimalPoint(value.replaceAll(',', ''), decimalDigits));
        } else {
          decimalValue = Decimal.parse(value.replaceAll(',', ''));
        }
        var formatter = NumberFormat(format);
        result = formatter.format(DecimalIntl(decimalValue));
      } catch (e) {
        Debug.log(tag, '## getDecimalFormatFormString error : $e');
      }
    }
    return result;
  }

  static Decimal? getDecimalFromStr(String value) {
    if (value.isNotEmpty) {
      try {
        return Decimal.parse(value.replaceAll(',', ''));
      } catch (e) {
        Debug.log(tag, '## getDecimalFromStr error : $e');
      }
    }
    return null;
  }

  static String cutDecimalPoint(String value, int decimalDigits) {
    String result = value;
    var split = value.split('.');

    if (split.length > 1) {
      int length = split[1].length;
      if (length > decimalDigits) {
        result = value.substring(0, value.length - (length - decimalDigits));
      }
    }
    return result;
  }

  // TODO: deleteFolderPath()
  static Future<void> deleteFolderPath(String? folderPath) async {
    if (folderPath != null && folderPath.isNotEmpty) {
      final targetFile = Directory(folderPath);
      if (targetFile.existsSync()) {
        targetFile.deleteSync(recursive: true);
      }
    }
  }

  // TODO: deleteFolderName()
  static Future<void> deleteFolderName(String? folderName) async {
    if (folderName != null && folderName.isNotEmpty) {
      Directory? appDirectory;
      if (Platform.isIOS) {
        appDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDirectory = await getExternalStorageDirectory();
      }
      final targetFile = Directory('${appDirectory!.path}$folderName');
      if (targetFile.existsSync()) {
        targetFile.deleteSync(recursive: true);
      }
    }
  }

  // TODO: getRotationType()
  static String getRotationType(int degree) {
    switch (degree) {
      case 0:
        return Common.rotation_0;
      case 90:
        return Common.rotation_90;
      case 180:
        return Common.rotation_180;
      case 270:
        return Common.rotation_270;
      default:
        return Common.rotation_0;
    }
  }

  // TODO: getRotationDegree()
  static int getRotationDegree(String rotationType) {
    int rotation = int.parse(rotationType);
    if (rotation >= 360) {
      rotation = rotation % 360;
    }

    if (rotation < 0) {
      rotation = rotation * -1;
    }
    return rotation;
  }

  // TODO: getTimeFormat()
  static String getTimeFormat(String dateFormat, int timestamp) {
    String time = '';
    try {
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

      time = DateFormat(dateFormat).format(date);
    } catch (e) {
      Debug.log(tag, '## getTimeFormat error = $e');
    }

    return time;
  }

  static String getTimeFormatStr(String dateFormat, String? strTimestamp) {
    String time = '';
    if (strTimestamp != null) {
      try {
        int? timestamp = int.tryParse(strTimestamp);
        if (timestamp != null) {
          var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);

          time = DateFormat(dateFormat).format(date);
        }
      } catch (e) {
        Debug.log(tag, '## getTimeFormat error = $e');
      }
    }
    return time;
  }

  static int getDateTimestamp(String date) {
    var dateTime = DateTime.tryParse(date);
    if (dateTime != null) {
      return dateTime.microsecondsSinceEpoch + dateTime.timeZoneOffset.inMicroseconds;
    } else {
      return 0;
    }
  }

  // TODO: getSpansText()
  static List<TextSpan> getSpansText({
    required String text,
    required String matchWord,
    required TextStyle style,
  }) {
    List<TextSpan> spans = [];
    int spanBoundary = 0;

    if (text.isEmpty || matchWord.isEmpty) {
      spans.add(TextSpan(text: text));
      return spans;
    }

    do {
      final startIndex = text.indexOf(matchWord, spanBoundary);

      if (startIndex == -1) {
        spans.add(TextSpan(text: text.substring(spanBoundary)));
        return spans;
      }

      if (startIndex > spanBoundary) {
        // print(text.substring(spanBoundary, startIndex));
        spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));
      }

      final endIndex = startIndex + matchWord.length;
      final spanText = text.substring(startIndex, endIndex);
      spans.add(TextSpan(text: spanText, style: style));

      // mark the boundary to start the next search from
      spanBoundary = endIndex;

      // continue until there are no more matches
    } while (spanBoundary < text.length);

    return spans;
  }

  static String getDateTimeDetail(String date) {
    var now = DateTime.now();
    var dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(date));

    int differenceHour = int.parse(now.difference(dateTime).inHours.toString());
    int differenceDay = int.parse(now.difference(dateTime).inDays.toString());
    int differenceMinutes = int.parse(now.difference(dateTime).inMinutes.toString());

    if (differenceDay >= 1) {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    } else {
      if (differenceHour == 0) {
        return '${differenceMinutes} ${'before_minutes'.tr()}';
      } else {
        return '${differenceHour} ${'before_hours'.tr()}';
      }
    }
  }

  static String getHashtagFromList(List<String>? hashtagList) {
    String result = '';

    if (hashtagList != null && hashtagList.isNotEmpty) {
      for (String tag in hashtagList) {
        result += ' $tag';
      }
    }

    return result.trim();
  }
}
