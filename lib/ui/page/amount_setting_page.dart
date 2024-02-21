import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';

import '../../constants/color_theme.dart';
import '../../constants/common.dart';
import '../../constants/setting.dart';
import '../../util/common_function.dart';
import '../widget/button_widget.dart';
import '../widget/toolbar_widget.dart';

class AmountSettingPage extends StatefulWidget {
  const AmountSettingPage({Key? key}) : super(key: key);

  @override
  State<AmountSettingPage> createState() => _AmountSettingPageState();
}

class _AmountSettingPageState extends State<AmountSettingPage> {
  late final ValueNotifier<bool> btnNotifier;
  late final TextEditingController amountController;

  Map<String, dynamic>? args;

  String symbol = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    btnNotifier = ValueNotifier<bool>(false);
    amountController = TextEditingController();
  }

  @override
  void dispose() {
    btnNotifier.dispose();
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      symbol = args?['symbol'] ?? '';
    }

    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: unFocus,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: DefaultToolbar(
            isBackButton: true,
            onBackPressed: () {
              Navigator.of(context).pop();
            },
            centerTitle: false,
            titleText: "set_amount".tr(),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'amount_to_receive'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Color(ColorTheme.defaultText),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      AmountTextFiled(
                        controller: amountController,
                        hintText: 'amount_to_receive_placeholder'.tr(),
                        maxDecimal: symbol.toUpperCase() != BSCWalletType.bPth.symbol.toUpperCase() ? Setting.decimalDigits : Setting.bPthDecimalDigits,
                        onChanged: (value) {
                          Decimal? amount = CommonFunction.getDecimalFromStr(value);
                          btnNotifier.value = (amount != null && amount >= Decimal.zero);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // TODO: Button
              ValueListenableBuilder<bool>(
                valueListenable: btnNotifier,
                builder: (_, isEnable, __) {
                  return BtnFill(
                    margin: const EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 24.0),
                    onTap: () {
                      CommonFunction.hideKeyboard(context);
                      Navigator.pop(context, amountController.text.trim());
                    },
                    isEnable: isEnable,
                    text: "confirm".tr(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // TODO: unFocus()
  unFocus() {
    CommonFunction.hideKeyboard(context);
  }
}
