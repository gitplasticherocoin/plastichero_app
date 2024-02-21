import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../constants/color_theme.dart';
import '../../constants/setting.dart';
import '../../util/common_function.dart';
import '../widget/button_widget.dart';
import '../widget/text_widget.dart';

class OtpQrDialog extends StatefulWidget {
  final String qrCode;

  const OtpQrDialog({
    Key? key,
    required this.qrCode,
  }) : super(key: key);

  @override
  State<OtpQrDialog> createState() => _OtpQrDialogState();
}

class _OtpQrDialogState extends State<OtpQrDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              'qr_code'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontFamily: Setting.appFont,
                fontWeight: FontWeight.w500,
                color: Color(ColorTheme.defaultText),
              ),
            ),
          ),
          Container(
            width: 84.0,
            height: 84.0,
            margin: const EdgeInsets.only(top: 30.0, bottom: 14.0),
            child: QrImageView(
              padding: EdgeInsets.zero,
              data: widget.qrCode,
            ),
          ),
          Text(
            'otp_qr_scan_guide'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: Setting.appFont,
              fontWeight: FontWeight.w400,
              color: Color(ColorTheme.c_4b4b4b),
            ),
          ),
          const SizedBox(height: 24.0),
          BtnBorderAppColor(
            onTap: () {
              Navigator.pop(context);
            },
            text: 'close'.tr(),
          ),
        ],
      ),
    );
  }
}
