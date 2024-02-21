import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';

class SwapDoneWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onNext;
  final double convertPTH;
  final int convertRate;
  final WalletInfo walletInfo;

  const SwapDoneWidget(
      {super.key,
      required this.convertPTH,
      required this.walletInfo,
      required this.convertRate,
      required this.onCancel,
      required this.onNext});

  @override
  State<SwapDoneWidget> createState() => _SwapDoneWidgetState();
}

class _SwapDoneWidgetState extends State<SwapDoneWidget> {
  late TextEditingController _pointController;
  late TextEditingController _pthController;
  late TextEditingController _ratioController;

  @override
  void initState() {
    super.initState();
    _pointController = TextEditingController();
    _pthController = TextEditingController();
    _ratioController = TextEditingController();

    final double rate = widget.convertRate.toDouble();

    _pointController.text = "${widget.convertPTH} ${Setting.appSymbol}";
    _pthController.text =
        "${(widget.convertPTH * rate).toInt()} ${Setting.appCoin}";
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
            Text("swap.done_subtitle".tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.0,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w400,
                  color: Color(ColorTheme.defaultText),
                )),
            const SizedBox(height: 20),
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
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: BtnBorderAppColor(
                    onTap: widget.onCancel,
                    text: "swap.change_list".tr(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BtnFill(
                    onTap: widget.onNext,
                    text: "confirm".tr(),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
          ],
        ));
  }
}
