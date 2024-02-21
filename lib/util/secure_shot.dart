import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:screen_protector/screen_protector.dart';

class SecureShot {
  static const _channel = MethodChannel('secureShotChannel');

  static void _preventScreenShotON() async {
    await ScreenProtector.preventScreenshotOn();
  }

  static void _preventScreenShotOFF() async {
    await ScreenProtector.preventScreenshotOff();
  }

  static void on() {
    if (Platform.isAndroid) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      _preventScreenShotON();
    }
  }

  static void off() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      _preventScreenShotOFF();
    }
  }
}
