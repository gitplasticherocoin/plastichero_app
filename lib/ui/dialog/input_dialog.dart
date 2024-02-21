import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';

class InputDialog extends StatefulWidget {
  final String? title;
  final String? body;
  final String? hint;
  final String? btnConfirmText;
  final ValueChanged<String?>? onConfirm;
  final String? btnCancelText;
  final Function()? onCancel;

  const InputDialog({
    Key? key,
    this.title,
    this.body,
    this.hint,
    this.btnConfirmText,
    this.onConfirm,
    this.btnCancelText,
    this.onCancel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InputDialogState();
  }
}

class _InputDialogState extends State<InputDialog> {
  String inputText = '';

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 54.0;
    if (width > 306.0) {
      width = 306.0;
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 2.0,
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.white,
      shadowColor: const Color(ColorTheme.shodows),
      content: SingleChildScrollView(
        child: Container(
          width: width,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: widget.title != null && widget.title!.isNotEmpty,
                      child: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        alignment: Alignment.center,
                        child: Text(
                          widget.title != null && widget.title!.isNotEmpty ? widget.title! : '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.0,
                            fontSize: 16,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w600,
                            color: Color(ColorTheme.defaultText),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.body != null && widget.body!.isNotEmpty,
                      child: Container(
                        margin: EdgeInsets.only(top: widget.title != null && widget.title!.isNotEmpty ? 12 : 0),
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.body != null && widget.body!.isNotEmpty ? widget.body! : '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.4,
                            fontSize: 14,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w400,
                            color: Color(ColorTheme.defaultText),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InputTextField(
                      hintText: widget.hint,
                      onChanged: (value) {
                        setState(() {
                          inputText = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: BtnBorderAppColor(
                      height: 48,
                      text: widget.btnCancelText ?? '',
                      onTap: () {
                        Navigator.of(context).pop();
                        if (widget.onCancel != null) {
                          widget.onCancel!.call();
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    flex: 2,
                    child: BtnFill(
                      height: 48,
                      text: widget.btnConfirmText ?? '',
                      isEnable: inputText.trim().isNotEmpty,
                      onTap: () {
                        Navigator.of(context).pop(true);
                        if (widget.onConfirm != null) {
                          widget.onConfirm?.call(inputText.trim());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
