import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/setting.dart';

/// DefaultToolbar
class DefaultToolbar extends AppBar {
  DefaultToolbar({
    Key? key,
    Color? backgroundColor = Colors.white,
    Color? foregroundColor,
    double? toolbarHeight,
    double? elevation,
    double? leadingWidth,
    double? titleSpacing,
    bool? automaticallyImplyLeading,
    Widget? title,
    bool centerTitle = true,
    TextStyle? titleTextStyle,
    VoidCallback? onBackPressed,
    String? titleText,
    Widget? leading,
    List<Widget>? actions,
    bool isBackButton = true,
    bool whiteBackButton = false,
    bool isUnderLine = false,
    PreferredSizeWidget? bottom,
  }) : super(
          key: key,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          toolbarHeight: Common.appBar,
          elevation: 0.0,
          leadingWidth: leadingWidth ?? 43.0,
          titleSpacing: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: centerTitle,
          titleTextStyle: titleTextStyle,
          bottom: bottom,
          actions: actions,
          leading: leading ??
              (isBackButton
                  ? Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.only(left:8),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: whiteBackButton
                            ? SvgPicture.asset('images/icon_nav_prev.svg', width: 40, height:40, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn))
                            : SvgPicture.asset('images/icon_nav_prev.svg', width: 40, height:40),
                        onPressed: onBackPressed,
                      ),
                    )
                  : null),
          title: title ??
              Text(
                titleText ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w700,
                  color: Color(ColorTheme.defaultText),
                ),
              ),
          shape: isUnderLine
              ? const Border(
                  bottom: BorderSide(
                    color: Color(ColorTheme.c_ededed),
                    width: 1.0,
                  ),
                )
              : null,
        );
}

/// PopupStyleToolbar
class PopupStyleToolbar extends AppBar {
  PopupStyleToolbar({
    Key? key,
    Color? backgroundColor,
    Color? foregroundColor,
    double? toolbarHeight,
    double? elevation,
    double? leadingWidth,
    double? titleSpacing,
    bool? automaticallyImplyLeading,
    bool? centerTitle,
    VoidCallback? onBackPressed,
    String? titleText,
    Widget? titleWidget,
    Widget? leading,
    bool isBackButton = true,
    bool isUnderLine = false,
    List<Widget>? actions,
  }) : super(
          key: key,
          backgroundColor: Colors.white,
          foregroundColor: Colors.transparent,
          toolbarHeight: Common.appBar,
          elevation: 0.0,
          // leadingWidth: 0.0,
          titleSpacing: 0.0,
          automaticallyImplyLeading: true,
          centerTitle: centerTitle,
          leading: isBackButton
              ? IconButton(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: SvgPicture.asset('images/icon_nav_prev.svg',
                      width: 40,
                      height:40),

                  onPressed: onBackPressed,
                )
              : null,
          title: titleWidget ??
              Text(
                titleText ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w500,
                  color: Color(ColorTheme.defaultText),
                ),
              ),
          shape: isUnderLine
              ? const Border(
                  bottom: BorderSide(color: Color(ColorTheme.c_ededed), width: 1.0),
                )
              : null,
          actions: actions,
        );
}
