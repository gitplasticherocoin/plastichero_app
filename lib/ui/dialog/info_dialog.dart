import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';

class InfoDialog extends StatefulWidget {
  final String? title;
  final String? body;
  final String? btnText;
  final VoidCallback? onConfirm;

  const InfoDialog({
    Key? key,
    this.title,
    this.body,
    this.btnText,
    this.onConfirm,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InfoDialogState();
  }
}

class _InfoDialogState extends State<InfoDialog> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 32.0;
    if (width > 328.0) {
      width = 328.0;
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
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
                            height: 1.3,
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
                        margin: EdgeInsets.only(top: widget.title != null && widget.title!.isNotEmpty ? 10 : 0),
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        alignment: Alignment.center,
                        child: Text(
                          widget.body != null && widget.body!.isNotEmpty ? widget.body! : '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.3,
                            fontSize: 14,
                            fontFamily: Setting.appFont,
                            fontWeight: FontWeight.w400,
                            color: Color(ColorTheme.defaultText),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: BtnFill(
                  height: 48,
                  text: widget.btnText ?? '',
                  onTap: () {
                    Navigator.of(context).pop(true);
                    if (widget.onConfirm != null) {
                      widget.onConfirm?.call();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
