import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';

class Debug {
  static String tagName = 'Piki';

  static void log(String? tag, String? msg) {
    if (kDebugMode) {
      if (Platform.isIOS) {
        print('[${tag ?? ''}] ${msg ?? tagName}');
      } else {
        developer.log(msg ?? tagName, name: tag ?? '');
      }
    }
  }
}
