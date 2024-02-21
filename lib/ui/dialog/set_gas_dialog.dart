import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/common.dart';

import '../../constants/color_theme.dart';
import '../../constants/setting.dart';
import '../../util/common_function.dart';
import '../widget/button_widget.dart';
import '../widget/text_widget.dart';

class SetGasDialog extends StatefulWidget {
  final TextEditingController gasPriceController;
  final TextEditingController gasAmountController;

  final VoidCallback onComplete;

  const SetGasDialog({
    Key? key,
    required this.gasPriceController,
    required this.gasAmountController,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<SetGasDialog> createState() => _SetGasDialogState();
}

class _SetGasDialogState extends State<SetGasDialog> {
  late final FocusNode gasAmountFocus;
  late final ValueNotifier<bool> btnNotifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    gasAmountFocus = FocusNode();
    btnNotifier = ValueNotifier<bool>(false);

    setEnableBtn();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    gasAmountFocus.dispose();
    btnNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 34.0, bottom: 24.0 + MediaQuery.of(context).padding.bottom, left: 24.0, right: 24.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              'gas_fee'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: Setting.appFont,
                fontWeight: FontWeight.w500,
                color: Color(ColorTheme.defaultText),
              ),
            ),
          ),

          AmountTextFiled(
            controller: widget.gasPriceController,
            hintText: 'gas_fee_placeholder'.tr(),
            maxDecimal: 18,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              setEnableBtn();
            },
            onFieldSubmitted: (value) {
              gasAmountFocus.requestFocus();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 12.0, bottom: 6.0),
            child: Text(
              'max_amount_of_gas'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: Setting.appFont,
                fontWeight: FontWeight.w500,
                color: Color(ColorTheme.defaultText),
              ),
            ),
          ),

          AmountTextFiled(
            focusNode: gasAmountFocus,
            controller: widget.gasAmountController,
            hintText: "gas_amount_placeholder".tr(),
            isDecimal: false,
            onChanged: (value) {
              setEnableBtn();
            },
          ),

          // TODO: Button
          ValueListenableBuilder<bool>(
            valueListenable: btnNotifier,
            builder: (_, isEnable, __) {
              return BtnFill(
                margin: const EdgeInsets.only(top: 24.0),
                onTap: () {
                  CommonFunction.hideKeyboard(context);

                  String gasPrice = widget.gasPriceController.text.trim();
                  String gasAmount = widget.gasAmountController.text.trim();
                  if (gasPrice.isEmpty) {
                    CommonFunction.showInfoDialog(context, 'gas_fee_placeholder'.tr());
                    return;
                  }
                  if (gasAmount.isEmpty) {
                    CommonFunction.showInfoDialog(context, 'gas_amount_placeholder'.tr());
                    return;
                  }

                  Navigator.pop(context);
                  widget.onComplete();
                },
                isEnable: isEnable,
                text: "confirm".tr(),
              );
            },
          ),
        ],
      ),
    );
  }

  // TODO: setEnableBtn()
  void setEnableBtn() {
    // Decimal dGasFee = CommonFunction.getDecimalFromStr(gasFeeController.text.trim()) ?? Decimal.zero;
    // Decimal dGasAmount = CommonFunction.getDecimalFromStr(gasAmountController.text.trim()) ?? Decimal.zero;
    btnNotifier.value = widget.gasPriceController.text.trim().isNotEmpty && widget.gasAmountController.text.trim().isNotEmpty;
  }
}
