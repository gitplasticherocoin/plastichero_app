import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/setting.dart';

// TODO : BTN_01
class BtnFill extends StatefulWidget {
  final bool isEnable;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color btnColor;
  final Color pressBtnColor;
  final Color disableBtnColor;
  final double radius;
  final String? text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final String? icon;
  final Color pressTextColor;
  final Color disableTextColor;
  final bool isRound;

  const BtnFill({
    Key? key,
    this.isEnable = true,
    this.onTap,
    this.margin,
    this.width = double.infinity,
    this.height = Common.buttonH,
    this.btnColor = const Color(ColorTheme.appColor),
    this.pressBtnColor = const Color(ColorTheme.c_14793c),
    this.disableBtnColor = const Color(ColorTheme.c_dbdbdb),
    this.radius = 10,
    this.text,
    this.fontSize = 15.0,
    this.fontFamily = Setting.appFont,
    this.fontWeight = FontWeight.w500,
    this.textColor = Colors.white,
    this.icon,
    this.pressTextColor = Colors.white,
    this.disableTextColor = Colors.white,
    this.isRound = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BtnFillState();
  }
}

class _BtnFillState extends State<BtnFill> {
  bool isOnPress = false;

  @override
  void initState() {
    super.initState();
  }

  void setOnPress(bool onPress, {bool onTap = false}) async {
    if (mounted) {
      if (isOnPress != onPress) {
        setState(() {
          isOnPress = onPress;
        });
      }
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() => setOnPress(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.isEnable) {
      return GestureDetector(
        onTap: () {
          setOnPress(true, onTap: true);
          if (widget.onTap != null) {
            widget.onTap!.call();
          }
        },
        onTapDown: (details) {
          setOnPress(true);
        },
        onTapUp: (details) {
          setOnPress(false);
        },
        onTapCancel: () {
          setOnPress(false);
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: widget.isRound ? BorderRadius.circular(widget.radius) : null,
            color: isOnPress ? widget.pressBtnColor : widget.btnColor,
          ),
          child: widget.icon != null && widget.icon!.isNotEmpty
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                widget.icon!,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.text ?? '',
                style: TextStyle(
                  height: 1.2,
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: widget.textColor,
                  fontWeight: widget.fontWeight,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          )
              : Text(
            widget.text ?? '',
            style: TextStyle(
              height: 1.2,
              fontSize: widget.fontSize,
              fontFamily: widget.fontFamily,
              color: widget.textColor,
              fontWeight: widget.fontWeight,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: widget.isRound ? BorderRadius.circular(widget.radius) : null,
          color: widget.disableBtnColor,
        ),
        child: widget.icon != null && widget.icon!.isNotEmpty
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              widget.icon!,
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.text ?? '',
              style: TextStyle(
                height: 1.2,
                fontSize: widget.fontSize,
                fontFamily: widget.fontFamily,
                color: widget.disableBtnColor,
                fontWeight: widget.fontWeight,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        )
            : Text(
          widget.text ?? '',
          style: TextStyle(
            height: 1.2,
            fontSize: widget.fontSize,
            fontFamily: widget.fontFamily,
            color: widget.disableTextColor,
            fontWeight: widget.fontWeight,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }
  }
}

// TODO : BTN_02
class BtnBorderAppColor extends StatefulWidget {
  final bool isEnable;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color btnColor;
  final Color pressBtnColor;
  final Color disableBtnColor;
  final Color borderColor;
  final Color pressBorderColor;
  final Color disableBorderColor;
  final double radius;
  final String? text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color pressTextColor;
  final Color disableTextColor;
  final String? img;
  final String? pressedImg;

  const BtnBorderAppColor(
      {Key? key,
      this.isEnable = true,
      this.onTap,
      this.margin,
      this.width = double.infinity,
      this.height = Common.buttonH,
      this.btnColor = Colors.white,
      this.pressBtnColor = const Color(ColorTheme.appColor),
      this.disableBtnColor = Colors.white,
      this.borderColor = const Color(ColorTheme.appColor),
      this.pressBorderColor = const Color(ColorTheme.appColor),
      this.disableBorderColor = const Color(ColorTheme.c_cccccc),
      this.radius = 10,
      this.text,
      this.fontSize = 15,
      this.fontFamily = Setting.appFont,
      this.fontWeight = FontWeight.w500,
      this.textColor = const Color(ColorTheme.appColor),
      this.pressTextColor = Colors.white,
      this.disableTextColor = const Color(ColorTheme.c_cccccc),
      this.img,
      this.pressedImg})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BtnBorderAppColorState();
  }
}

class _BtnBorderAppColorState extends State<BtnBorderAppColor> {
  bool isOnPress = false;

  @override
  void initState() {
    super.initState();
  }

  void setOnPress(bool onPress, {bool onTap = false}) async {
    if (mounted) {
      if (isOnPress != onPress) {
        setState(() {
          isOnPress = onPress;
        });
      }
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() => setOnPress(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.isEnable) {
      return GestureDetector(
        onTap: () {
          setOnPress(true, onTap: true);
          if (widget.onTap != null) {
            widget.onTap!.call();
          }
        },
        onTapDown: (details) {
          setOnPress(true);
        },
        onTapUp: (details) {
          setOnPress(false);
        },
        onTapCancel: () {
          setOnPress(false);
        },
        child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                width: 1.0,
                color: isOnPress ? widget.pressBorderColor : widget.borderColor,
              ),
              color: isOnPress ? widget.pressBtnColor : widget.btnColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.img != null) ...{
                  SvgPicture.asset(
                    isOnPress ? widget.pressedImg ?? widget.img! : widget.img!,
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(
                    width: 10,
                  )
                },
                Text(
                  widget.text ?? '',
                  style: TextStyle(
                    height: 1.2,
                    fontSize: widget.fontSize,
                    fontFamily: widget.fontFamily,
                    color: isOnPress ? widget.pressTextColor : widget.textColor,
                    fontWeight: widget.fontWeight,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            )),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            width: 1.0,
            color: widget.disableBorderColor,
          ),
          color: widget.disableBtnColor,
        ),
        child: Text(
          widget.text ?? '',
          style: TextStyle(
            height: 1.2,
            fontSize: widget.fontSize,
            fontFamily: widget.fontFamily,
            color: widget.disableTextColor,
            fontWeight: widget.fontWeight,
          ),
        ),
      );
    }
  }
}

// TODO : BTN_03
class BtnBorderBlack extends StatefulWidget {
  final bool isEnable;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color btnColor;
  final Color pressBtnColor;
  final Color disableBtnColor;
  final Color borderColor;
  final Color pressBorderColor;
  final Color disableBorderColor;
  final double radius;
  final String? text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color pressTextColor;
  final Color disableTextColor;
  final Widget? icon;

  const BtnBorderBlack({
    Key? key,
    this.isEnable = true,
    this.onTap,
    this.margin,
    this.width = double.infinity,
    this.height = Common.buttonH,
    this.btnColor = Colors.white,
    this.pressBtnColor = const Color(ColorTheme.c_ededed),
    this.disableBtnColor = Colors.white,
    this.borderColor = const Color(ColorTheme.c_4b4b4b),
    this.pressBorderColor = const Color(ColorTheme.c_4b4b4b),
    this.disableBorderColor = const Color(ColorTheme.c_cccccc),
    this.radius = 10,
    this.text,
    this.fontSize = 15,
    this.fontFamily = Setting.appFont,
    this.fontWeight = FontWeight.w500,
    this.textColor = const Color(ColorTheme.c_4b4b4b),
    this.pressTextColor = const Color(ColorTheme.c_4b4b4b),
    this.disableTextColor = const Color(ColorTheme.c_cccccc),
    this.icon = null,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BtnBorderBlackState();
  }
}

class _BtnBorderBlackState extends State<BtnBorderBlack> {
  bool isOnPress = false;

  @override
  void initState() {
    super.initState();
  }

  void setOnPress(bool onPress, {bool onTap = false}) async {
    if (mounted) {
      if (isOnPress != onPress) {
        setState(() {
          isOnPress = onPress;
        });
      }
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() => setOnPress(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.isEnable) {
      return GestureDetector(
        onTap: () {
          setOnPress(true, onTap: true);
          if (widget.onTap != null) {
            widget.onTap!.call();
          }
        },
        onTapDown: (details) {
          setOnPress(true);
        },
        onTapUp: (details) {
          setOnPress(false);
        },
        onTapCancel: () {
          setOnPress(false);
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              width: 1.0,
              color: isOnPress ? widget.pressBorderColor : widget.borderColor,
            ),
            color: isOnPress ? widget.pressBtnColor : widget.btnColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null)
                widget.icon!,
              Text(
                widget.text ?? '',
                style: TextStyle(
                  height: 1.2,
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: isOnPress ? widget.pressTextColor : widget.textColor,
                  fontWeight: widget.fontWeight,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            width: 1.0,
            color: widget.disableBorderColor,
          ),
          color: widget.disableBtnColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(widget.icon != null)
              widget.icon!,
            Text(
              widget.text ?? '',
              style: TextStyle(
                height: 1.2,
                fontSize: widget.fontSize,
                fontFamily: widget.fontFamily,
                color: widget.disableTextColor,
                fontWeight: widget.fontWeight,
              ),
            ),
          ],
        ),
      );
    }
  }
}

// TODO : BTN_04
class BtnHamburger extends StatefulWidget {
  final bool isEnable;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color btnColor;
  final Color pressBtnColor;
  final Color disableBtnColor;
  final double radius;
  final String? text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color pressTextColor;
  final Color disableTextColor;

  const BtnHamburger({
    Key? key,
    this.isEnable = true,
    this.onTap,
    this.margin,
    this.width,
    this.height,
    this.btnColor = const Color(ColorTheme.c_d1eadb),
    this.pressBtnColor = const Color(ColorTheme.c_a3d6b7),
    this.disableBtnColor = const Color(ColorTheme.c_dbdbdb),
    this.radius = 28,
    this.text,
    this.fontSize = 13.0,
    this.fontFamily = Setting.appFont,
    this.fontWeight = FontWeight.w400,
    this.textColor = const Color(ColorTheme.c_4b4b4b),
    this.pressTextColor = const Color(ColorTheme.c_4b4b4b),
    this.disableTextColor = Colors.white,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BtnHamburgerState();
  }
}

class _BtnHamburgerState extends State<BtnHamburger> {
  bool isOnPress = false;

  @override
  void initState() {
    super.initState();
  }

  void setOnPress(bool onPress, {bool onTap = false}) async {
    if (mounted) {
      if (isOnPress != onPress) {
        setState(() {
          isOnPress = onPress;
        });
      }
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() => setOnPress(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.isEnable) {
      return GestureDetector(
        onTap: () {
          setOnPress(true, onTap: true);
          if (widget.onTap != null) {
            widget.onTap!.call();
          }
        },
        onTapDown: (details) {
          setOnPress(true);
        },
        onTapUp: (details) {
          setOnPress(false);
        },
        onTapCancel: () {
          setOnPress(false);
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 65, minHeight: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: isOnPress ? widget.pressBtnColor : widget.btnColor,
          ),
          child: Text(
            widget.text ?? '',
            style: TextStyle(
              height: 1.2,
              fontSize: widget.fontSize,
              fontFamily: widget.fontFamily,
              color: isOnPress ? widget.pressTextColor : widget.textColor,
              fontWeight: widget.fontWeight,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        constraints: const BoxConstraints(minWidth: 65, minHeight: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: widget.disableBtnColor,
        ),
        child: Text(
          widget.text ?? '',
          style: TextStyle(
            height: 1.2,
            fontSize: widget.fontSize,
            fontFamily: widget.fontFamily,
            color: widget.disableTextColor,
            fontWeight: widget.fontWeight,
          ),
        ),
      );
    }
  }
}

// TODO : BTN_05
class BtnSmall extends StatefulWidget {
  final bool isEnable;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color btnColor;
  final Color pressBtnColor;
  final Color disableBtnColor;
  final double radius;
  final String? text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color pressTextColor;
  final Color disableTextColor;

  const BtnSmall({
    Key? key,
    this.isEnable = true,
    this.onTap,
    this.margin,
    this.width,
    this.height,
    this.btnColor = const Color(ColorTheme.c_f3f3f3),
    this.pressBtnColor = const Color(ColorTheme.c_dbdbdb),
    this.disableBtnColor = const Color(ColorTheme.c_cccccc),
    this.radius = 5,
    this.text,
    this.fontSize = 12.0,
    this.fontFamily = Setting.appFont,
    this.fontWeight = FontWeight.w400,
    this.textColor = const Color(ColorTheme.defaultText),
    this.pressTextColor = const Color(ColorTheme.defaultText),
    this.disableTextColor = Colors.white,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BtnSmallState();
  }
}

class _BtnSmallState extends State<BtnSmall> {
  bool isOnPress = false;

  @override
  void initState() {
    super.initState();
  }

  void setOnPress(bool onPress, {bool onTap = false}) async {
    if (mounted) {
      if (isOnPress != onPress) {
        setState(() {
          isOnPress = onPress;
        });
      }
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() => setOnPress(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.isEnable) {
      return GestureDetector(
        onTap: () {
          setOnPress(true, onTap: true);
          if (widget.onTap != null) {
            widget.onTap!.call();
          }
        },
        onTapDown: (details) {
          setOnPress(true);
        },
        onTapUp: (details) {
          setOnPress(false);
        },
        onTapCancel: () {
          setOnPress(false);
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 65, minHeight: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: isOnPress ? widget.pressBtnColor : widget.btnColor,
          ),
          child: Text(
            widget.text ?? '',
            style: TextStyle(
              height: 1.2,
              fontSize: widget.fontSize,
              fontFamily: widget.fontFamily,
              color: isOnPress ? widget.pressTextColor : widget.textColor,
              fontWeight: widget.fontWeight,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        constraints: const BoxConstraints(minWidth: 65, minHeight: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: widget.disableBtnColor,
        ),
        child: Text(
          widget.text ?? '',
          style: TextStyle(
            height: 1.2,
            fontSize: widget.fontSize,
            fontFamily: widget.fontFamily,
            color: widget.disableTextColor,
            fontWeight: widget.fontWeight,
          ),
        ),
      );
    }
  }
}

class ImageButton extends StatefulWidget {
  final String img;
  final String? pressImg;
  final String? disableImg;
  final double? imgWidth;
  final double? imgHeight;
  final bool isEnable;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final Color? iconPressedColor;
  final BoxDecoration? boxDecoration;
  final BoxDecoration? pressedBoxDecoration;

  const ImageButton({
    Key? key,
    required this.img,
    this.pressImg,
    this.disableImg,
    this.imgWidth,
    this.imgHeight,
    this.isEnable = true,
    this.isSelected = false,
    this.onTap,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.iconPressedColor,
    this.boxDecoration,
    this.pressedBoxDecoration,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImageButtonState();
  }
}

class _ImageButtonState extends State<ImageButton> {
  bool isOnPress = false;

  @override
  void initState() {
    super.initState();
  }

  void setOnPress(bool onPress, {bool onTap = false}) async {
    if (mounted) {
      if (isOnPress != onPress) {
        setState(() {
          isOnPress = onPress;
        });
      }
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() => setOnPress(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setOnPress(true, onTap: true);
        if (widget.isEnable && widget.onTap != null) {
          widget.onTap!.call();
        }
      },
      onTapDown: (details) {
        setOnPress(true);
      },
      onTapUp: (details) {
        setOnPress(false);
      },
      onTapCancel: () {
        setOnPress(false);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        color: widget.color,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        padding: widget.padding,
        decoration: isOnPress || widget.isSelected ? (widget.pressedBoxDecoration ?? widget.boxDecoration) : widget.boxDecoration,
        child: SvgPicture.asset(
          getImage(),
          width: widget.imgWidth,
          height: widget.imgHeight,
          color: isOnPress || widget.isSelected ? widget.iconPressedColor : null,
        ),
      ),
    );
  }

  String getImage() {
    if (!widget.isEnable) {
      return widget.disableImg ?? widget.img;
    } else if (isOnPress || widget.isSelected) {
      return widget.pressImg ?? widget.img;
    } else {
      return widget.img;
    }
  }


}

class ButtonStyle1 extends StatelessWidget {
  final bool isEnable;
  final bool isDisableTap;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color btnColor;
  final Color disableColor;
  final Color? pressColor;
  final String? text;
  final double radius;
  final double fontSize;
  final Color textColor;
  final Alignment? alignment;

  const ButtonStyle1(
      {Key? key,
        this.isEnable = true,
        this.isDisableTap = false,
        this.onTap,
        this.margin,
        this.padding,
        this.width = double.infinity,
        this.height = Common.boxH,
        this.btnColor = const Color(ColorTheme.c_ffffff),
        this.disableColor = const Color(ColorTheme.c_ffffff),
        this.pressColor,
        this.text,
        this.radius = 5.0,
        this.fontSize = 14.0,
        this.textColor = const Color(ColorTheme.c_bb2649),
        this.alignment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEnable) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: btnColor,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            highlightColor: pressColor,
            hoverColor: pressColor,
            splashColor: pressColor,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              alignment: alignment ?? Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: Text(
                text ?? 'confirm'.tr(),
                style: TextStyle(
                  height: 1.2,
                  fontSize: fontSize,
                  fontFamily: Setting.appFont,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (isDisableTap && onTap != null) {
            onTap!.call();
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: disableColor,
          ),
          child: Text(
            text ?? 'confirm'.tr(),
            style: TextStyle(
              height: 1.2,
              fontSize: fontSize,
              fontFamily: Setting.appFont,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
  }
}

class ButtonStyle4 extends StatelessWidget {
  final bool isEnable;
  final bool isDisableTap;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color btnColor;
  final Color borderColor;
  final Color disableColor;
  final Color? pressColor;
  final String? text;
  final double radius;
  final double fontSize;
  final Color textColor;
  final Alignment? alignment;
  final Widget? prefixIcon;

  const ButtonStyle4(
      {Key? key,
        this.isEnable = true,
        this.isDisableTap = false,
        this.onTap,
        this.margin,
        this.padding,
        this.width = double.infinity,
        this.height = 54,
        this.btnColor = const Color(ColorTheme.c_ffffff),
        this.disableColor = const Color(ColorTheme.c_ffffff),
        this.pressColor,
        this.text,
        this.radius = 5.0,
        this.fontSize = 14.0,
        this.textColor = const Color(ColorTheme.c_bb2649),
        this.borderColor = const Color(ColorTheme.c_d6d6dc),
        this.alignment,
        this.prefixIcon = null,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEnable) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: btnColor,
            border: Border.all(
                width: 1,
                color: borderColor
            )
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            highlightColor: pressColor,
            hoverColor: pressColor,
            splashColor: pressColor,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              alignment: alignment ?? Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: Visibility(
                visible: prefixIcon == null,
                replacement: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(prefixIcon != null)
                      prefixIcon!,
                    Text(
                      text ?? 'confirm'.tr(),
                      style: TextStyle(
                        height: 1.2,
                        fontSize: fontSize,
                        fontFamily: Setting.appFont,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                child: Text(
                  text ?? 'confirm'.tr(),
                  style: TextStyle(
                    height: 1.2,
                    fontSize: fontSize,
                    fontFamily: Setting.appFont,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (isDisableTap && onTap != null) {
            onTap!.call();
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                width: 1,
                color: borderColor
            ),
            color: disableColor,
          ),
          child: Visibility(
            visible: prefixIcon == null,
            replacement: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(prefixIcon != null)
                  prefixIcon!,
                Text(
                  text ?? 'confirm'.tr(),
                  style: TextStyle(
                    height: 1.2,
                    fontSize: fontSize,
                    fontFamily: Setting.appFont,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            child: Text(
              text ?? 'confirm'.tr(),
              style: TextStyle(
                height: 1.2,
                fontSize: fontSize,
                fontFamily: Setting.appFont,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
  }
}