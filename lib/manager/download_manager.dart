import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/setting.dart';
import '../util/common_function.dart';
import '../util/debug.dart';

class DownloadManager {
  final String tag = 'DownloadManager';

  BuildContext? context;
  ReceivePort port = ReceivePort();

  DownloadManager(this.context) {
    FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);

    IsolateNameServer.registerPortWithName(port.sendPort, 'download_send_port');
    port.listen((data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
    });
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping('download_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<String?> downloadFile({required String downloadPath, required String fileName, bool isShowNotification = true}) async {
    String? result;
    try {
      bool isPermission = await checkPermission();
      if (!isPermission) {
        if (context != null) {
          CommonFunction.showToast(context, 'msg_error_not_permission'.tr());
        }
        return result;
      }

      String dir = '';

      if (Platform.isIOS) {
        var directory = await getApplicationDocumentsDirectory();
        dir = "${directory.path}/${Setting.appFolderName}";
      } else {
        dir = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
      }

      final Directory directory = Directory(dir);

      bool isExistsFolder = await directory.exists();
      if (!isExistsFolder) {
        await directory.create(recursive: true);
        Debug.log(tag, '## create folder path = $dir');
      }

      File file = File('$dir${Platform.pathSeparator}$fileName');

      print('## save file path = ${file.path}');

      if (await file.exists()) {
        await file.delete();
      }

      await file.create();

      result = await FlutterDownloader.enqueue(
        url: downloadPath,
        savedDir: '$dir/',
        fileName: fileName,
        showNotification: isShowNotification,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );
      Debug.log(tag, '## downloadFile result = $result');
    } catch (e) {
      Debug.log(tag, '## File download error : $e');
    }

    return result;
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    PermissionStatus permissionStatus;
    if (!status.isGranted) {
      permissionStatus = await Permission.storage.request();

      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }
}
