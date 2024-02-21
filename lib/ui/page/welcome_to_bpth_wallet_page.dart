import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';

import '../widget/button_widget.dart';

class WelcomeTobPTHWalletPage extends StatefulWidget {
  const WelcomeTobPTHWalletPage({Key? key}) : super(key: key);

  @override
  State<WelcomeTobPTHWalletPage> createState() => _WelcomeTobPTHWalletPageState();
}

class _WelcomeTobPTHWalletPageState extends State<WelcomeTobPTHWalletPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          body: Column(children: [
            Container(
              margin: const EdgeInsets.only(left: 24, right: 24, top: 80),
              child: Text(
                'title_welcome_bPTH'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 24,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff121212),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 24, right: 24, top: 13),
              child: Text(
                'msg_welcome_bPTH'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.4,
                  fontSize: 15,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff121212),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 52),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'images/img_bpth_wallet.svg',
                width: 90,
                height: 131,
              ),
            ),
            const SizedBox(
              height: 56,
            ),
            BtnBorderAppColor(
              margin: const EdgeInsets.only(left: 24, right: 24),
              img: 'images/icon_wallet_green.svg',
              pressedImg: 'images/icon_wallet_w.svg',
              text: 'create_wallet'.tr(),
              onTap: () {
                // bPTH 지갑 생성
                Navigator.pushNamed(context, Routes.safeUseGuidePage);
              },
            ),
            const SizedBox(
              height: 12,
            ),
            BtnBorderAppColor(
              margin: const EdgeInsets.only(left: 24, right: 24),
              img: 'images/icon_import_green.svg',
              pressedImg: 'images/icon_import_w.svg',
              text: 'get_wallet'.tr(),
              onTap: () {
                // bPTH 지갑 가져오기
                Navigator.pushNamed(context, Routes.getWalletPage);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
