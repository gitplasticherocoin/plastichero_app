import 'dart:io';
import 'dart:ui';

import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/color_theme.dart';
import '../../constants/common.dart';
import '../../constants/setting.dart';

import '../../routes.dart';
import '../widget/button_widget.dart';
import '../widget/toolbar_widget.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({Key? key}) : super(key: key);

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  late final ValueNotifier<bool> btnNotifier;

  Map<String, dynamic>? args;

  String qrCode = '';
  String address = '';
  String symbol = '';

  String amount = '';
  String qrcode = '';

  @override
  void initState() {
    super.initState();

    btnNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    btnNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      address = args?['address'] ?? '';
      symbol = args?['symbol'] ?? '';

      qrcode = address;
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: DefaultToolbar(
            isBackButton: true,
            onBackPressed: () {
              Navigator.of(context).pop();
            },
            centerTitle: false,
            titleText: "deposit".tr(),
          ),
          bottomSheet: Container(
            height: 54.0,
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 24.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      setOnPress(true, onTap: true);

                      String filePath = await getQrImage(qrcode);
                      if (filePath.isNotEmpty) {
                        await Share.shareXFiles([XFile(filePath)]);
                      }
                    },
                    onTapDown: (details) {
                      setOnPress(true);
                    },
                    onTapUp: (details) {
                      setOnPress(false);
                    },
                    onTapCancel: () {
                      setOnPress(false);
                    },
                    child: ValueListenableBuilder<bool>(
                      valueListenable: btnNotifier,
                      builder: (_, isOnPress, __) {
                        return Container(
                          width: double.infinity,
                          height: Common.buttonH,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1.0,
                              color: isOnPress ? const Color(ColorTheme.appColor) : const Color(ColorTheme.appColor),
                            ),
                            color: isOnPress ? const Color(ColorTheme.appColor) : Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "images/icon_share.svg",
                                width: 16.0,
                                height: 16.0,
                                colorFilter: isOnPress ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'share'.tr(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w500,
                                  color: isOnPress ? Colors.white : const Color(ColorTheme.appColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  flex: 1,
                  child: BtnFill(
                    onTap: () async {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const TestPage()));
                      var result = await Navigator.of(context).pushNamed(
                        Routes.amountSettingPage,
                        arguments: {'symbol': symbol},
                      );
                      if (result != null && result is String) {
                        Decimal? dAmount = CommonFunction.getDecimalFromStr(result);
                        qrcode = address;

                        if (dAmount == null || dAmount <= Decimal.zero) {
                          amount = '';
                        } else {
                          amount = dAmount.toString();
                          qrcode += '${Common.qrcodeSplit}$amount';
                        }

                        setState(() {});
                      }
                    },
                    text: "set_amount".tr(),
                  ),
                ),
              ],
            ),
          ),
          body: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24.0, 52.0, 24.0, 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 170.0,
                    height: 170.0,
                    child:  QrImageView(
                      padding: EdgeInsets.zero,
                      data: qrcode
                    ),

                    // QrImage(
                    //   padding: EdgeInsets.zero,
                    //   data: qrcode!,
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 22.0),
                    child: Text(
                      address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        height: 1.4,
                        fontSize: 14,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w700,
                        color: Color(ColorTheme.defaultText),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      CommonFunction.copyData(context, address);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      margin: const EdgeInsets.only(top: 18.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(ColorTheme.c_dbdbdb),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "images/icon_copy.svg",
                        width: 14.0,
                        height: 14.0,
                      ),
                    ),
                  ),
                  if (amount.isNotEmpty && amount != '0') ...[
                    Container(
                      margin: const EdgeInsets.only(top: 30.0),
                      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: const Color(ColorTheme.c_d1eadb),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '+ ',
                            style: TextStyle(
                              height: 1.1,
                              fontSize: 16,
                              fontFamily: Setting.appFont,
                              fontWeight: FontWeight.w400,
                              color: Color(ColorTheme.defaultText),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${CommonFunction.getDecimalFormatFormString(amount)} $symbol',
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 16,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.defaultText),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setOnPress(bool onPress, {bool onTap = false}) async {
    if (mounted) {
      btnNotifier.value = onPress;
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 50)).whenComplete(() => setOnPress(false));
      }
    }
  }

  Future<String> getQrImage(String data) async {
    final qrValidationResult = QrValidator.validate(data: data, version: QrVersions.auto, errorCorrectionLevel: QrErrorCorrectLevel.L);
    if (qrValidationResult.status == QrValidationStatus.valid) {
      // final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter(data: data, version: QrVersions.auto, gapless: false, color: Colors.black, emptyColor: Colors.white);

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      String path = '$tempPath/$ts.png';

      final picData = await painter.toImageData(2048, format: ImageByteFormat.png);
      final buffer = picData!.buffer;
      await File(path).writeAsBytes(buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes));

      return path;
    } else {
      CommonFunction.showToast(context, qrValidationResult.error.toString());
    }
    return '';
  }
}
