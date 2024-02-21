import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/util/validate.dart';

class SwapPasswordWidget extends StatefulWidget {
  final Function(String pass) onNext;
  const SwapPasswordWidget({super.key, required this.onNext});

  @override
  State<SwapPasswordWidget> createState() => _SwapPasswordWidgetState();
}

class _SwapPasswordWidgetState extends State<SwapPasswordWidget> {
  final gkSwapPass = GlobalKey<FormState>();
  bool _isEnableConfirm = false;
  String _pass = "";

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
                  height: 1.0 ,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w500,
                  color: Color(ColorTheme.defaultText),
                )
            ),
            const SizedBox(height: 18,),
            Text("swap.password_subtitle".tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.0 ,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w400,
                  color: Color(ColorTheme.defaultText),
                )
            ),
            const SizedBox(height:17),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("pass".tr(),
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
                Form(
                  key: gkSwapPass,
                  child: NewPasswordTextField(
                    hint: "password_placeholder".tr(),
                    onChange: (value) {
                      _pass = value.trim();
                        if(gkSwapPass.currentState!.validate()) {
                          setState(() {
                            _isEnableConfirm = true;
                          });
                        }else {
                          setState(() {
                            _isEnableConfirm = false;
                          });
                        }
                    },
                    validator: (value) {
                      return Validate.validatePassword(value);
                    },
                    onFieldSubmitted: (value) {
                      if(gkSwapPass.currentState!.validate()) {
                        setState(() {
                          _isEnableConfirm = true;
                        });
                      }else {
                        setState(() {
                          _isEnableConfirm = false;
                        });
                      }
                    },
                  ),
                )

              ],
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

                const SizedBox(width:12),

                Expanded(
                  flex: 2,
                  child: BtnFill(
                    isEnable: _isEnableConfirm,
                    onTap: () {
                      widget.onNext(_pass);
                    },
                    text: "swap.change".tr(),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
          ],
        )
    );
  }
}
