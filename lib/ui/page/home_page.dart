import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _name = "홍길동";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              height: 56,
              child: Row(
                children: [
                  SvgPicture.asset("images/logo.svg", width: 127, height: 20),
                  const Spacer(),
                  SvgPicture.asset(
                    "images/navi_icon_sidemenu.svg",
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 6, bottom: 16, left: 24, right: 24),
              child: ShadowWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          top: 16, bottom: 12, left: 18, right: 18),
                      child: Row(
                        children: [
                          Text(_name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w800,
                                color: Color(ColorTheme.defaultText),
                              )),
                          Text("member_points".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w500,
                                color: Color(ColorTheme.c_767676),
                              )),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                        right: 18,
                        left: 18,
                      ),
                      child: Row(
                        children: const [
                          Spacer(),
                          Text("2,000 P",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w900,
                                color: Color(0xff19984b),
                              )),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(ColorTheme.c_ededed),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 16, bottom: 15),
                      child: Text("point_history".tr(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.0,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w700,
                            color: Color(ColorTheme.c_767676),
                          )),
                    ),
                  ],
                ),
              )
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("plastichero_news".tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.0,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w700,
                        color: Color(ColorTheme.defaultText),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  ShadowWidget(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 19, bottom: 14),
                      child: Column(
                        children: [

                          Row(
                            children: [
                              SvgPicture.asset('images/img_bear.svg',
                                  width: 84, height: 84),
                              Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                        "main_news_desc".tr(),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 18 / 13,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w500,
                                          color: Color(ColorTheme.defaultText),
                                        )),
                                  ))
                            ],
                          ),
                          const SizedBox(height: 15,),
                          Row(
                            children: [
                              BtnFill(
                                width: (MediaQuery.of(context).size.width - ( 38* 2) - 8)  / 2 ,
                                height: 48,
                                text: "buy_giftcon".tr(),
                              ),
                              const SizedBox(width: 8),
                              BtnFill(
                                width: (MediaQuery.of(context).size.width - (38 * 2) - 8 )  / 2 ,
                                height: 48,
                                text: "find_kiosk".tr(),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ),

                ],
              ),
            ),

            const SizedBox(height: 16,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              child: Text("plastichero_magazine".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.0 ,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w700,
                                    color: Color(ColorTheme.defaultText),
                                  )
                                ),
            ),
            const SizedBox(height: 16,),
            SizedBox(
              width: double.infinity,
              height: 120,
              child:
              ListView.separated(
                padding: const EdgeInsets.only(left: 24),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 14);
                },
                scrollDirection: Axis.horizontal,
                itemCount:  6,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: 120,
                      height: 120,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius:BorderRadius.circular(15),
                        color: Colors.green,
                      ),
                      child: Container(

                      ),
                    );
                  }

              ),
            )
          ],
        ),
      ),
    );
  }
}

class ShadowWidget extends StatelessWidget {
  final Widget child;
  const ShadowWidget({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: Offset(0.0, 0.0))
            ]),
        child: Container(

          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: Colors.white,
          ),
          child: child,
        )
    );
  }
}
