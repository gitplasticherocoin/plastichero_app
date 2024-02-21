import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plastichero/constants/setting.dart';
import 'package:plastichero/ui/widget/button_widget.dart';
import 'package:plastichero/ui/widget/toolbar_widget.dart';
import 'package:plastichero/util/common_function.dart';
import 'package:plastichero_app/constants/color_theme.dart';

class MasterKeyPage extends StatelessWidget {
  const MasterKeyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title;
    String masterKey;

    if (ModalRoute.of(context)?.settings.arguments != null) {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic> ??
              {};
      title = arguments["title"] ?? "master_key_title".tr();
      masterKey = arguments["masterkey"] ?? "";
    } else {
      title = "master_key_title".tr();
      masterKey = "";
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ButtonStyle1(
                radius: 15.0,
                btnColor: const Color(ColorTheme.appColor),
                textColor: Colors.white,
                text: 'confirm'.tr(),
                onTap: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
            appBar: DefaultToolbar(
              titleText: title,
              centerTitle: false,
              onBackPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            body: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24.0, 12, 24.0, 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("master_key_title_desc".tr(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff121212),
                        )),
                    const SizedBox(height: 8),
                    Text("master_key_subtitle_desc".tr(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff121212),
                        )),
                    const SizedBox(
                      height: 14,
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(ColorTheme.c_ededed),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              masterKey,
                              style: const TextStyle(
                                height: 1.5,
                                fontSize: 15,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff121212),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              CommonFunction.copyData(context, masterKey);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: SvgPicture.asset("images/icon_copy.svg",
                                  height: 14, width: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      color: const Color(ColorTheme.c_ededed),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'notice'.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: Setting.appFont,
                          fontSize: 15,
                          color: Color(0xff121212)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,

                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff4b4b4b),
                            ),
                            width: 3,
                            height: 3,

                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Expanded(
                          child: Text(
                            'master_key_explain_item_1'.tr(),
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.c_4b4b4b)),
                          ),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff4b4b4b),
                            ),
                            width: 3,
                            height: 3,
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Expanded(
                          child: Text(
                            'master_key_explain_item_2'.tr(),
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.c_4b4b4b)),
                          ),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8),
                          child: Container(

                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff4b4b4b),
                            ),
                            width: 3,
                            height: 3,
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Expanded(
                          child: Text(
                            'master_key_explain_item_3'.tr(),
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(ColorTheme.c_4b4b4b)),
                          ),
                        )
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
