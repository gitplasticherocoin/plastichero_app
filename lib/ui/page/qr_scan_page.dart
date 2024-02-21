import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scan/scan.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../constants/common.dart';
import '../../constants/setting.dart';
import '../../util/debug.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({Key? key}) : super(key: key);

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final String tag = "ScanQRPage";

  final GlobalKey gkQR = GlobalKey(debugLabel: 'QR');

  late QRViewController controller;

  final double overlayBottom = 30;

  bool isScanComplete = false;

  String qrcode = '';

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double statusBar = mediaQueryData.padding.top;
    double bPadding = mediaQueryData.padding.bottom;

    bool isFolding = (mediaQueryData.size.shortestSide < Common.foldingSize);

    double scanArea = isFolding ? 242.0 : 342.0;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            QRView(
              key: gkQR,
              onQRViewCreated: onQRViewCreated,
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.srcOut),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, backgroundBlendMode: BlendMode.dstOut), // This one will handle background + difference out
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(bottom: overlayBottom),
                      height: scanArea - (scanArea * 0.037),
                      width: scanArea - (scanArea * 0.037),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(scanArea * 0.19),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(top: 42.5 - overlayBottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'images/img_qrscan.svg',
                      width: scanArea,
                      height: scanArea,
                    ),
                    Container(
                      height: 42.5,
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'qr_scan_guide'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.02,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: statusBar,
              left: 0,
              right: 0,
              child: Container(
                height: Common.appBar,
                padding: const EdgeInsets.only(left: 24.0),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      flex: 1,
                      child: Text(
                        'QR SCAN',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: SvgPicture.asset(
                          'images/nav_icon_close_w.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  getQrcodeFromAlbum();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                  margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: bPadding + 24.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    color: Colors.black.withOpacity(0.51),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'images/icon_499.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'album'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.02,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onQRViewCreated(QRViewController controller) async {
    await Permission.camera.request();
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera().whenComplete(() async {
        String code = scanData.code ?? '';
        // if (!await canLaunchUrlString(code)) {
        if (mounted && !isScanComplete) {
          isScanComplete = true;
          Debug.log(tag, 'Barcode Type: ${describeEnum(scanData.format)}');

          qrcode = code;

          Navigator.of(context).pop(qrcode);
        }
        // } else {
        //   await launchUrlString(code);
        //   controller.resumeCamera();
        // }
      });
    });
  }

  Future<void> getQrcodeFromAlbum() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file == null) {
      return;
    }

    if (file.path.isEmpty) {
      if (mounted) {
        CommonFunction.showToast(context, 'qr_scan_error'.tr());
      }
      return;
    }

    String? result = await Scan.parse(file.path);
    if (result == null || result.isEmpty) {
      if (mounted) {
        CommonFunction.showToast(context, 'qr_scan_error'.tr());
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context, result);
    }
  }
}
