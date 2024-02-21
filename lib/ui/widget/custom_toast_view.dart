import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/setting.dart';

class CustomToastView extends StatelessWidget {
  final String? msg;

  const CustomToastView({
    Key? key,
    required this.msg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: const Color(0xB3000000), // opacity: 70%
      ),
      alignment: Alignment.center,
      child: Text(
        msg ?? '',
        textAlign: TextAlign.center,
        maxLines: 2,
        style: const TextStyle(
          height: 1.2,
          fontSize: 15,
          fontFamily: Setting.appFont,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }
}
