import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';

class SwapConfirmWidget extends StatefulWidget {
  final VoidCallback onNext;
  final double convertPTH;
  final WalletInfo walletInfo;
  final int convertRate;

  const SwapConfirmWidget({
    super.key,
    required this.convertPTH,
    required this.walletInfo,
    required this.convertRate,
    required this.onNext,
  });

  @override
  State<SwapConfirmWidget> createState() => _SwapConfirmWidgetState();
}

class _SwapConfirmWidgetState extends State<SwapConfirmWidget> {
  late TextEditingController _pointController;
  late TextEditingController _pthController;
  late TextEditingController _ratioController;

  bool _isAgree = false;

  @override
  void initState() {
    super.initState();
    _pointController = TextEditingController();
    _pthController = TextEditingController();
    _ratioController = TextEditingController();
    final double rate = widget.convertRate.toDouble();

    _pointController.text = "${widget.convertPTH} ${Setting.appSymbol}";
    _pthController.text =
        "${(widget.convertPTH * rate).toInt()}${Setting.appCoin}";
    _ratioController.text = "1:${widget.convertRate}";
  }

  @override
  void dispose() {
    _pointController.dispose();
    _pthController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text("swap.title".tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.0,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w500,
                  color: Color(ColorTheme.defaultText),
                )),
            const SizedBox(
              height: 18,
            ),
            Text("swap.confirm_subtitle".tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.0,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w400,
                  color: Color(ColorTheme.defaultText),
                )),
            const SizedBox(
              height: 18,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("swap.change_count".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(height: 5),
                InputTextField(
                  controller: _pointController,
                  enabled: false,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                )
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("swap.expect_price".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(height: 5),
                InputTextField(
                  controller: _pthController,
                  enabled: false,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                )
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("swap.swap_ratio".tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w500,
                      color: Color(ColorTheme.defaultText),
                    )),
                const SizedBox(height: 5),
                InputTextField(
                  controller: _ratioController,
                  enabled: false,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                )
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAgree = _isAgree ? false : true;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAgree
                          ? const Color(ColorTheme.appColor)
                          : const Color(ColorTheme.c_dbdbdb),
                    ),
                    child: Center(
                        child: SvgPicture.asset("images/icon_check_g_m.svg",
                            width: 11.7, height: 8.4, color: Colors.white)),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text("swap.service_description".tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w400,
                          color: Color(ColorTheme.c_1e1e1e),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: BtnBorderAppColor(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    text: "close".tr(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BtnFill(
                    isEnable: _isAgree ? true : false,
                    onTap: widget.onNext,
                    text: "next".tr(),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
          ],
        ));
  }
}
