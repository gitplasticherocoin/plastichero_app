import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Container(
      width: MediaQuery.of(context).size.width,
      color: const Color(ColorTheme.appColor),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Container(
                  color: Colors.white,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
                        color: Color(ColorTheme.appColor)),
                    padding: const EdgeInsets.only(//top: 78 + 44,
                       left: 30, right: 20, top: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              InkWell(child: Icon(Icons.close_sharp , size: 35),
                                onTap: () {
                                Navigator.of(context).pop(false);
                                },
                              ),
                            ],
                          ),

                          const Spacer(),
                      Text("welcome_title".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 35,
                            height: 1.0,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.53,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        height: 8,
                      ),
                      Text("welcome_app_name".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 35,
                            height: 1.0,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.53,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        height: 8,
                      ),
                      Text("welcome_subtitle".tr(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          )),
                          const SizedBox(height: 78),
                    ]),
                  ),
                )),
            Expanded(
                child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                  color: Colors.white),
              padding: const EdgeInsets.only(top: 34, left: 30, right: 30),
              child: Column(
                children: [
                  BtnBorderBlack(
                    width: MediaQuery.of(context).size.width - 60,
                    height: 54,
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.walletCreatePage).then((result) {
                        if (result is bool && result) {
                          refreshData();
                        }
                      });

                    },
                    text: "wallet_create".tr(),
                    icon: Padding(
                      padding: const EdgeInsets.only(right:5),
                      child: SvgPicture.asset("images/icon_plus.svg", width: 16, height:16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BtnBorderBlack(
                    width: MediaQuery.of(context).size.width - 60,
                    height: 54,
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.walletImportPage).then((result) {
                        if (result is bool && result) {
                          refreshData();
                        }
                      });
                    },
                    text: "wallet_import".tr(),
                    icon: Padding(
                      padding: const EdgeInsets.only(right:5),
                      child: SvgPicture.asset("images/icon_arrow_r.svg", width: 16, height:16),
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }

  void refreshData() {
    Navigator.of(context).pop(true);

  }
}
