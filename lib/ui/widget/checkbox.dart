import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';

class CheckBoxWithTitle extends StatelessWidget {
  final bool isChecked;
  final String title;
  const CheckBoxWithTitle({Key? key,
    required this.isChecked,
    required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CheckBox02(
            value:isChecked,
            onChanged: (_) {
            },
            size: 12,
            isEnableTouch : false
        ),
        const SizedBox(width: 5),
        Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.0 ,
              fontFamily: Setting.appFont,
              fontWeight: FontWeight.w500,
              color: isChecked ?
              const Color(ColorTheme.defaultText)
                  : const Color(ColorTheme.c_999999)
              ,
            )
        ),

      ],
    );
  }
}

class CheckBox01 extends StatelessWidget {
  final Function(bool) onChanged;
  final bool value;
  const CheckBox01({Key? key,
    required this.value,
    required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child:

      Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: value == true ? Color(ColorTheme.c_333333) :  Color(ColorTheme.c_ededed),
            ),
            width: 14,
            height: 14,
          ),
          SizedBox(
            width: 14,
            height: 14,
            child: Center(
              child: Visibility(
                visible: value == true,
                child: SvgPicture.asset("images/icon_check_w_s.svg", width: 7.9, height: 5.7),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CheckBox02 extends StatelessWidget {
  final Function(bool) onChanged;
  final bool value;
  final double size;
  final bool isEnableTouch;

  const CheckBox02({Key? key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    this.isEnableTouch = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(isEnableTouch) {
          onChanged(!value);
        }
      },
      child:

      Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: value == true ? const Color(ColorTheme.appColor) :  const Color(ColorTheme.c_ededed),
            ),
            width: size,
            height:size,
          ),
          SizedBox(
            width: size,
            height: size,
            child: Center(
                child: SvgPicture.asset("images/icon_check_w_m.svg",
                    width: size == 24 ? 11.7 : 5.85,
                    height: size == 24 ? 8.4 : 4.2)
            ),
          )
        ],
      ),
    );
  }
}