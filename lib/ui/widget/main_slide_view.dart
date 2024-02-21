import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/setting.dart';
import '../../routes.dart';
import '../../util/common_function.dart';

class MainSlideView extends StatefulWidget {
  final bool isPTH;
  final ValueChanged<int>? onSelectButton;

  const MainSlideView({
    Key? key,
    this.isPTH = true,
    this.onSelectButton,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainSlideViewState();
  }
}

class _MainSlideViewState extends State<MainSlideView> {
  final String tag = 'MainSlideView';
  String name = '';
  String id = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadData();
    });
  }

  Future<void> loadData() async {
    final loginName = await CommonFunction.getPreferencesString(PreferenceKey.loginName) ?? "";
    final loginId = await CommonFunction.getPreferencesString(PreferenceKey.loginId) ?? "";
    setState(() {
      name = loginName;
      id = loginId;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    CommonFunction.hideKeyboard(context);
                    Navigator.pop(context);
                    // 내 정보
                    Navigator.of(context).pushNamed(Routes.myInfoPage);
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 74,
                    padding: const EdgeInsets.only(left: 24, right: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              sprintf('hello_name'.tr(), [name]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 1.0,
                                fontSize: 18,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff121212),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 1.0,
                                fontSize: 13,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff767676),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset(
                          'images/200.svg',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 24, top: 10),
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    color: Color(0xff19984b),
                  ),
                  child: const Text(
                    'Wallet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.0,
                      fontSize: 16,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    CommonFunction.hideKeyboard(context);
                    Navigator.pop(context);
                    if (!widget.isPTH) {
                      widget.onSelectButton?.call(0);
                    }
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 24),
                    padding: const EdgeInsets.only(left: 18, right: 18),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: Text(
                      WalletType.pth.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.0,
                        fontSize: 15,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w400,
                        color: widget.isPTH ? const Color(0xff19984b) : const Color(0xff121212),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 36),
                  color: const Color(0xffededed),
                ),
                InkWell(
                  onTap: () {
                    CommonFunction.hideKeyboard(context);
                    Navigator.pop(context);
                    widget.onSelectButton?.call(1);
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 24),
                    padding: const EdgeInsets.only(left: 18, right: 18),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: Text(
                      'bPTH',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.0,
                        fontSize: 15,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w400,
                        color: !widget.isPTH ? const Color(0xff19984b) : const Color(0xff121212),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 36),
                  color: const Color(0xffededed),
                ),
                InkWell(
                  onTap: () async {
                    CommonFunction.hideKeyboard(context);
                    await launchUrl(Uri.parse(Setting.EXPLORER_LINK), mode: LaunchMode.externalApplication);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 24),
                    padding: const EdgeInsets.only(left: 18, right: 18),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: const Text(
                      'Explorer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.0,
                        fontSize: 15,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff121212),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 24),
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    color: Color(0xff19984b),
                  ),
                  child: const Text(
                    'Point',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.0,
                      fontSize: 16,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 42, right: 20, top: 8, bottom: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'msg_point'.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.4,
                      fontSize: 14,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff121212),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    CommonFunction.hideKeyboard(context);
                    await launchUrl(Uri.parse(Setting.APP_MARKET_LINK_IOS), mode: LaunchMode.externalApplication);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 42, right: 38),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1.0,
                        color: const Color(0xffdbdbdb),
                      ),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                      SvgPicture.asset(
                        'images/icon_ios.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'App Store',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.0,
                          fontSize: 15,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff121212),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () async {
                    CommonFunction.hideKeyboard(context);
                    await launchUrl(Uri.parse(Setting.APP_MARKET_LINK_ANDROID), mode: LaunchMode.externalApplication);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 42, right: 38),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1.0,
                        color: const Color(0xffdbdbdb),
                      ),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                      SvgPicture.asset(
                        'images/icon_google.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'Google Play',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.0,
                          fontSize: 15,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff121212),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
