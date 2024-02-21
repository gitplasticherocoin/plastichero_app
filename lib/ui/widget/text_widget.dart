import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/util/common_function.dart';

// TODO: InputTextField
class InputTextField extends StatefulWidget {
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLength;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final bool enabled;
  final Color? disableFillColor;
  final Color? fixedLineColor;
  final TextStyle style;
  final String? hintText;
  final bool isHideErrorText;
  final String? helperText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final bool denySpace;
  final bool onlyNumber;
  final bool autofocus;
  final bool hideSuffixIcon;
  final GestureTapCallback? onSuffixIconTap;
  final Widget? suffixIcon;
  final bool expands;
  final int? maxLines;
  final bool isOutline;
  final EdgeInsetsGeometry? contentPadding;
  final Color defaultFillColor;
  final double borderRadius;

  const InputTextField(
      {Key? key,
      this.keyboardType,
      this.textInputAction,
      this.obscureText = false,
      this.maxLength,
      this.textAlign = TextAlign.start,
      this.textAlignVertical = TextAlignVertical.center,
      this.enabled = true,
      this.disableFillColor = const Color(ColorTheme.c_ededed),
      this.fixedLineColor,
      this.style = const TextStyle(
        height: 1.2,
        fontSize: 15,
        color: Color(ColorTheme.defaultText),
        fontFamily: Setting.appFont,
        fontWeight: FontWeight.w400,
      ),
      this.hintText,
      this.isHideErrorText = false,
      this.helperText,
      this.controller,
      this.onChanged,
      this.onTap,
      this.focusNode,
      this.onEditingComplete,
      this.onFieldSubmitted,
      this.onSaved,
      this.validator,
      this.denySpace = false,
      this.onlyNumber = false,
      this.autofocus = false,
      this.hideSuffixIcon = false,
      this.onSuffixIconTap,
      this.suffixIcon,
      this.expands = false,
      this.maxLines = 1,
      this.isOutline = false,
      this.contentPadding,
      this.defaultFillColor = const Color(ColorTheme.c_ededed),
      this.borderRadius = 10})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InputTextFieldState();
  }
}

class InputTextFieldState extends State<InputTextField> {
  late final TextEditingController controller;
  Color? fixedLineColor;
  late FocusNode focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.focusNode != null) {
      focusNode = widget.focusNode!;
    } else {
      focusNode = FocusNode();
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
    if (widget.controller != null) {
      controller = widget.controller!;
    } else {
      controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    if (widget.controller == null) {
      controller.dispose();
    }
  }

  void updateLineColor() {
    if (widget.fixedLineColor != null) {
      setState(() {
        if (widget.fixedLineColor != null) {
          fixedLineColor = controller.text.isNotEmpty ? widget.fixedLineColor : null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int textLength = controller.text.length;

    if (widget.fixedLineColor != null) {
      fixedLineColor = controller.text.isNotEmpty ? widget.fixedLineColor : null;
    }

    return TextFormField(
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      enabled: widget.enabled,
      style: widget.style,
      autofocus: widget.autofocus,
      expands: widget.expands,
      maxLines: widget.maxLines,
      cursorColor: const Color(ColorTheme.appColor),
      decoration: InputDecoration(
        contentPadding: widget.contentPadding ??
            ((widget.enabled && !widget.hideSuffixIcon && widget.suffixIcon != null)
                ? const EdgeInsets.only(left: 16, top: 16, right: 0, bottom: 16)
                : const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16)),
        // ((widget.enabled && textLength > 0 && !widget.hideSuffixIcon) ? const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0) : const EdgeInsets.fromLTRB(17.0, 16.0, 17.0, 16.0)),
        isCollapsed: true,
        filled: true,
        fillColor: widget.enabled ? (focusNode.hasFocus ? const Color(ColorTheme.c_e7f5ec) : widget.defaultFillColor) : widget.disableFillColor,
        hintText: widget.hintText,
        counterText: '',
        errorStyle: widget.isHideErrorText
            ? const TextStyle(
                height: 0,
                fontSize: 0,
                color: Colors.transparent,
              )
            : const TextStyle(
                height: 1.2,
                fontSize: 15.0,
                color: Color(ColorTheme.errorText),
                fontFamily: Setting.appFont,
                fontWeight: FontWeight.w400,
              ),
        hintStyle: const TextStyle(
          fontSize: 15.0,
          color: Color(ColorTheme.c_767676),
          fontFamily: Setting.appFont,
          fontWeight: FontWeight.w400,
        ),
        focusedBorder: widget.isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: fixedLineColor ?? const Color(ColorTheme.defaultText),
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
        enabledBorder: widget.isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: fixedLineColor ?? const Color(ColorTheme.c_ededed),
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
        disabledBorder: widget.isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: fixedLineColor ?? const Color(ColorTheme.c_ededed),
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
        focusedErrorBorder: widget.isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(ColorTheme.errorText),
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
        errorBorder: widget.isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(ColorTheme.errorText),
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
        border: widget.isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(ColorTheme.c_ededed),
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
        suffixIcon: widget.hideSuffixIcon || widget.suffixIcon == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // if (widget.enabled && textLength > 0) ...[
                  //   InkWell(
                  //     focusColor: Colors.transparent,
                  //     hoverColor: Colors.transparent,
                  //     highlightColor: Colors.transparent,
                  //     splashColor: Colors.transparent,
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Image.asset(
                  //         'images/close_s_dg.png',
                  //         width: 13,
                  //         height: 13,
                  //       ),
                  //     ),
                  //     onTap: () {
                  //       setState(() {
                  //         controller.clear();
                  //         fixedLineColor = null;
                  //       });
                  //       if (widget.onChanged != null) {
                  //         widget.onChanged?.call('');
                  //       }
                  //     },
                  //   ),
                  //   const SizedBox(
                  //     width: 9.0,
                  //   ),
                  // ],
                  if (widget.onSuffixIconTap != null) ...[
                    const SizedBox(
                      width: 8.0,
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: widget.suffixIcon,
                      onTap: () {
                        if (widget.onSuffixIconTap != null) {
                          widget.onSuffixIconTap?.call();
                        }
                      },
                    ),
                    const SizedBox(
                      width: 17.0,
                    ),
                  ],
                ],
              ),
      ),
      controller: controller,
      onChanged: (value) {
        setState(() {
          textLength = controller.text.length;
          if (widget.fixedLineColor != null) {
            fixedLineColor = textLength > 0 ? widget.fixedLineColor : null;
          }
        });

        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      onTap: widget.onTap,
      focusNode: focusNode,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      validator: widget.validator,
      inputFormatters: [
        if (widget.denySpace) FilteringTextInputFormatter.deny(RegExp('[ ]')),
        if (widget.onlyNumber) FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
    );
  }
}

// TODO: PasswordTextField
class PasswordTextField extends StatefulWidget {
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLength;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final bool enabled;
  final Color? disableFillColor;
  final TextStyle style;
  final String? hintText;
  final bool isError;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final bool denySpace;
  final bool autofocus;
  final bool isOutline;

  const PasswordTextField({
    Key? key,
    this.keyboardType = TextInputType.visiblePassword,
    this.textInputAction,
    this.obscureText = true,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.enabled = true,
    this.disableFillColor = const Color(ColorTheme.c_ededed),
    this.style = const TextStyle(
      fontSize: 15,
      color: Color(ColorTheme.defaultText),
      fontFamily: Setting.appFont,
      fontWeight: FontWeight.w400,
    ),
    this.hintText,
    this.isError = false,
    this.errorText,
    this.helperText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.denySpace = false,
    this.autofocus = false,
    this.isOutline = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PasswordTextFieldState();
  }
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late final TextEditingController controller;

  // final String patternNumber = '^.*[0-9]';
  // final String patternSpecialChat = '^.*[!@#\$%^&*]';
  // final String patternUpperCase = '^.*[A-Z]';
  //
  // bool isNumber = false;
  // bool isSpecialChar = false;
  // bool isUpperCase = false;

  String password = '';
  late FocusNode focusNode;

  // validatePassword() {
  //   setState(() {
  //     isNumber = validate(patternNumber);
  //     isSpecialChar = validate(patternSpecialChat);
  //     isUpperCase = validate(patternUpperCase);
  //   });
  // }

  bool validate(String pattern) {
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      focusNode = widget.focusNode!;
    } else {
      focusNode = FocusNode();
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
    if (widget.controller != null) {
      controller = widget.controller!;
    } else {
      controller = TextEditingController();
    }

    if (widget.obscureText) {
      passwordInputType = true;
    } else {
      passwordInputType = false;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  bool inputPassword = false;
  bool passwordInputType = true;

  @override
  Widget build(BuildContext context) {
    if (widget.keyboardType != null && widget.keyboardType == TextInputType.visiblePassword) {
      inputPassword = true;
    }

    return TextFormField(
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: passwordInputType ? true : false,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      enabled: widget.enabled,
      style: widget.style,
      autofocus: widget.autofocus,
      cursorColor: const Color(ColorTheme.appColor),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
        isCollapsed: true,
        counterText: '',
        filled: true,
        fillColor: widget.enabled ? (focusNode.hasFocus ? const Color(ColorTheme.c_e7f5ec) : const Color(ColorTheme.c_ededed)) : widget.disableFillColor,
        enabled: widget.enabled,
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: Color(ColorTheme.c_767676),
          fontFamily: Setting.appFont,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: const TextStyle(
          height: 1.2,
          fontSize: 14.0,
          color: Color(ColorTheme.errorText),
          fontFamily: Setting.appFont,
          fontWeight: FontWeight.w400,
        ),
        focusedBorder: widget.isOutline
            ? OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: widget.isError ? const Color(ColorTheme.errorText) : const Color(ColorTheme.defaultText),
                ),
              )
            : const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide.none,
              ),
        enabledBorder: widget.isOutline
            ? const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: Color(ColorTheme.c_ededed),
                ),
              )
            : const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide.none,
              ),
        focusedErrorBorder: widget.isOutline
            ? const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: Color(ColorTheme.errorText),
                ),
              )
            : const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide.none,
              ),
        errorBorder: widget.isOutline
            ? const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: Color(ColorTheme.errorText),
                ),
              )
            : const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide.none,
              ),
        border: widget.isOutline
            ? const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 1,
                  color: Color(ColorTheme.c_ededed),
                ),
              )
            : const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide.none,
              ),
        suffixIconConstraints: const BoxConstraints(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visibility(
            //   visible: widget.enabled && controller.text.isNotEmpty ? true : false,
            //   child: InkWell(
            //     focusColor: Colors.transparent,
            //     hoverColor: Colors.transparent,
            //     highlightColor: Colors.transparent,
            //     splashColor: Colors.transparent,
            //     child: Container(
            //       margin: const EdgeInsets.all(5.0),
            //       padding: const EdgeInsets.all(6.0),
            //       child: Image.asset(
            //         'images/close_s_dg.png',
            //         width: 13,
            //         height: 13,
            //         fit: BoxFit.none,
            //       ),
            //     ),
            //     onTap: () {
            //       setState(() {
            //         controller.clear();
            //         if (widget.onChanged != null) {
            //           widget.onChanged?.call(controller.text);
            //         }
            //       });
            //     },
            //   ),
            // ),
            Visibility(
              visible: inputPassword ? true : false,
              child: InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5.0, 10.0, 17.0, 10.0),
                  child: SvgPicture.asset(
                    passwordInputType ? 'images/icon_eye_off.svg' : 'images/icon_eye_on.svg',
                    width: 22,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                onTap: () {
                  setState(() {
                    passwordInputType = !passwordInputType;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      controller: controller,
      onChanged: (value) {
        password = value;
        // validatePassword();

        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      onTap: widget.onTap,
      focusNode: focusNode,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      validator: widget.validator,
      inputFormatters: widget.denySpace
          ? [
              FilteringTextInputFormatter.deny(RegExp('[ ]')),
            ]
          : null,
    );
  }
}

class NewPasswordTextField extends StatefulWidget {
  final Function(String text)? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final Function(String text)? onChange;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final String? hint;

  const NewPasswordTextField({
    Key? key,
    this.onChange,
    this.onSaved,
    this.onFieldSubmitted,
    this.validator,
    this.focusNode,
    this.hint,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewPasswordTextFiled();
  }
}

class _NewPasswordTextFiled extends State<NewPasswordTextField> {
  final String patternNumber = '^.*[0-9]';
  final String patternSpecialChar = r'^.*[~!@#$%^&*()_+\-=\[\]{}\\|;:,.<>/?]';

  // final String patternChar = '^.*(?=\\w)(?=\\D)';
  // final String patternChar = '^.*[a-zA-Z]';

  String password = '';
  late FocusNode focusNode;

  bool isLength = false;
  bool isNumber = false;
  bool isSpecialChar = false;
  bool isValidate = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      focusNode = widget.focusNode!;
    } else {
      focusNode = FocusNode();
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PasswordTextField(
          focusNode: focusNode,
          hintText: widget.hint ?? 'password'.tr(),
          isError: isError,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            password = value.trim();
            if (widget.onChange != null) {
              widget.onChange?.call(password);
            }
            if (password.isEmpty) {
              isValidate = false;
            }
            validatePassword();
          },
          onSaved: (value) {
            password = value ?? '';
            if (widget.onSaved != null) {
              widget.onSaved?.call(value);
            }
          },
          onFieldSubmitted: (value) {
            if (widget.onFieldSubmitted != null) {
              widget.onFieldSubmitted?.call(value);
            }
          },
        ),
        const SizedBox(height: 10.0),
        Wrap(
          spacing: 12.0,
          runSpacing: 5.0,
          children: [
            validateView(
              text: 'password_condition_length'.tr(),
              isValid: isLength,
            ),
            validateView(
              text: 'number'.tr(),
              isValid: isNumber,
            ),
            validateView(
              text: 'special_char'.tr(),
              isValid: isSpecialChar,
            ),
          ],
        ),
      ],
    );
  }

  Widget validateView({required String text, required bool isValid}) {
    BoxDecoration boxDecoration = const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(ColorTheme.c_dbdbdb),
    );
    int textColor = ColorTheme.defaultText;
    String checkImg = 'images/icon_check_w_s.svg';

    if (password.isNotEmpty) {
      if (isValid) {
        boxDecoration = const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(ColorTheme.c_19984b),
        );
        textColor = ColorTheme.defaultText;
        checkImg = 'images/icon_check_w_s.svg';
      } else {
        boxDecoration = const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(ColorTheme.errorText),
        );
        textColor = ColorTheme.errorText;
        checkImg = 'images/icon_del_w_s.svg';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 5),
          decoration: boxDecoration,
          child: SvgPicture.asset(
            checkImg,
            width: 8,
            fit: BoxFit.fitWidth,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            height: 1.2,
            fontSize: 12,
            fontFamily: Setting.appFont,
            fontWeight: FontWeight.w400,
            color: Color(textColor),
          ),
        ),
      ],
    );
  }

  void validatePassword() {
    setState(() {
      isLength = password.length >= 8 && password.length <= 32;
      isNumber = validate(patternNumber);
      isSpecialChar = validate(patternSpecialChar);
      isError = password.isNotEmpty && !(isLength && isNumber && isSpecialChar);
    });
  }

  bool validate(String pattern) {
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }
}


// TODO: AmountTextFiled
class AmountTextFiled extends StatefulWidget {
  final bool isDecimal;
  final int maxDecimal;
  final String? hintText;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final TextEditingController? controller;
  final Function(String text)? onChanged;
  final Function(String text)? onFieldSubmitted;
  final FocusNode? focusNode;
  final String? fee;
  final EdgeInsetsGeometry? contentPadding;
  final bool isOutline;

  const AmountTextFiled({
    Key? key,
    this.isDecimal = true,
    this.maxDecimal = Setting.bPthDecimalDigits,
    this.hintText = '',
    this.textInputAction,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.validator,
    this.errorText = '',
    this.controller,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.fee = '0',
    this.contentPadding,
    this.isOutline = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AmountTextFiledState();
  }
}

class AmountTextFiledState extends State<AmountTextFiled> {
  late final TextEditingController _controller;
  late FocusNode focusNode;

  int maxDecimal = 0;

  String _amount = '';

  @override
  void initState() {
    super.initState();

    maxDecimal = widget.maxDecimal;

    if (widget.controller == null) {
      _controller = TextEditingController();
    } else {
      _controller = widget.controller!;
    }

    if (widget.focusNode != null) {
      focusNode = widget.focusNode!;
    } else {
      focusNode = FocusNode();
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
      textInputAction: widget.textInputAction,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      cursorColor: const Color(ColorTheme.appColor),
      style: const TextStyle(
        height: 1.2,
        fontSize: 15,
        color: Color(ColorTheme.defaultText),
        fontFamily: Setting.appFont,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: widget.contentPadding ?? const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
        isCollapsed: true,
        filled: true,
        fillColor: focusNode.hasFocus ? const Color(ColorTheme.c_e7f5ec) : const Color(ColorTheme.c_ededed),
        focusColor: const Color(ColorTheme.appColor),
        counterText: '',
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 15.0,
          color: Color(ColorTheme.c_767676),
          fontFamily: Setting.appFont,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: const TextStyle(
          height: 0,
          fontSize: 0,
          color: Colors.transparent,
        ),
        focusedBorder: widget.isOutline
            ? const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Color(ColorTheme.defaultText),
          ),
        )
            : const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: widget.isOutline
            ? const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Color(ColorTheme.c_ededed),
          ),
        )
            : const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide.none,
        ),
        disabledBorder: null,
        focusedErrorBorder: null,
        errorBorder: null,
      ),
      onChanged: (text) {
        _amount = validateAmount(text);
        widget.onChanged?.call(_amount);
      },
      onFieldSubmitted: (text) {
        widget.onFieldSubmitted?.call(text);
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
      ],
      // toolbarOptions: const ToolbarOptions(
      //   copy: false,
      //   cut: false,
      //   paste: false,
      //   selectAll: false,
      // ),
      contextMenuBuilder: null,
    );
  }

  // TODO: validation
  String validateAmount(String amount) {
    String result = _amount;
    try {
      bool isDelete = _amount.length > amount.length;

      int offset = _controller.selection.baseOffset;
      // print('## value = $value , _isDelete = $_isDelete , _offset = $_offset');

      String value = '';
      String decimalValue = '';

      /// remove symbol
      String pattern = r"^[0-9\.]*$";
      RegExp regex = RegExp(pattern);
      bool isContainSymbol = !regex.hasMatch(amount.replaceAll(',', ''));

      /// check two decimal
      var split = amount.split('.');
      if (split.length > 2 || isContainSymbol) {
        split = _amount.split('.'); // back to the original
        value = split[0];
        if (split.length > 1) {
          decimalValue = split[1];
        }

        return setAmount(value, decimalValue, split.length, (offset - 1));
      }

      value = split[0];

      /// delete
      if (isDelete) {
        String deleteChar = _amount.substring(offset, offset + 1);
        var valueSplitNum = CommonFunction.getDecimalFormatFormString(value, decimalDigits: maxDecimal).split(',');
        var amountSplitNum = _amount.split(',');

        if (deleteChar.contains(',')) {
          String start = (offset > 1) ? _amount.substring(0, offset - 1) : '';
          String end = _amount.substring(offset + 1, _amount.length);
          value = start + end;
          offset = offset - 1;
        } else if (amountSplitNum.length > valueSplitNum.length) {
          offset = offset - 1;
        }
        value = CommonFunction.getDecimalFormatFormString(value, decimalDigits: maxDecimal);

        if (split.length > 1) {
          decimalValue = split[1].replaceAll(',', '');
        }

        return setAmount(value, decimalValue, split.length, offset);
      }

      /// check decimal
      if (split.length > 1) {
        decimalValue = split[1].replaceAll(',', '');

        // If the decimal point exceeds the maximum number
        if (decimalValue.length > maxDecimal) {
          var amountSplit = _amount.split('.');
          int amountDecimalLength = (amountSplit.length > 1) ? amountSplit[1].length : 0;

          // When the number of decimal points is at its maximum, no input is maximum.
          if (amountDecimalLength == maxDecimal) {
            split = _amount.split('.'); // back to the original
            value = split[0];
            if (split.length > 1) {
              decimalValue = split[1];
            }
          } else {
            decimalValue = decimalValue.substring(0, maxDecimal);
            String amountValue = _amount.split('.')[0];

            int sub = 0;
            if (amountValue.length == value.length) {
              offset = offset - 1;
            } else {
              if (isDelete) {
                sub = amountValue.length - value.length;
                offset = offset + sub;
              }
            }
          }
          return setAmount(value, decimalValue, split.length, offset - 1);
        }
      }

      return setAmount(value, decimalValue, split.length, offset);
    } catch (e) {}
    return result;
  }

  String setAmount(String value, String decimalValue, int splitNum, int offset) {
    String decimal = (splitNum > 1) ? '.' : '';

    int commaNum = value.split(',').length;
    value = value.replaceAll(',', '');

    if (splitNum == 1 && value.length > 1 && value.substring(0, 1).contains('0')) {
      offset = offset - splitNum;
    }

    String result = CommonFunction.getDecimalFormatFormString(value, decimalDigits: maxDecimal);
    int commaN = result.split(',').length - commaNum;

    // Set offset when deleting the first decimal point.  0.123 -> 123
    if (splitNum > 1) {
      if (result.isEmpty) {
        result = '0';
        offset = offset + 1;
      }
    }

    result = result + decimal + decimalValue;

    offset = offset + commaN;
    if (offset < 0) {
      offset = 0;
    } else if (offset > result.length) {
      offset = result.length;
    }

    _controller.text = result;
    _controller.selection = TextSelection(baseOffset: offset, extentOffset: offset);
    return result;
  }
}

