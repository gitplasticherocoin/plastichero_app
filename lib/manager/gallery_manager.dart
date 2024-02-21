import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/file_info.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/debug.dart';

class GalleryManager {
  final String tag = 'GalleryManager';

  BuildContext? context;

  GalleryManager(this.context);

  Future<bool> checkPermission({
    bool isCamera = false,
  }) async {
    PermissionStatus permissionStatus;

    if (Platform.isIOS) {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        return false;
      }
      return true;
    } else if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        permissionStatus = await Permission.storage.request();
        if (permissionStatus != PermissionStatus.granted) {
          Debug.log(tag, '### Permission.storage $permissionStatus');
          return false;
        }
      } else {
        permissionStatus = await Permission.photos.request();
        if (permissionStatus != PermissionStatus.granted) {
          Debug.log(tag, '### Permission.photos $permissionStatus');
          return false;
        }
        permissionStatus = await Permission.videos.request();
        if (permissionStatus != PermissionStatus.granted) {
          Debug.log(tag, '### Permission.videos $permissionStatus');
          return false;
        }
      }
    }
    if (isCamera) {
      permissionStatus = await Permission.camera.request();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<FileInfo?> takePhoto() async {
    FileInfo? fileInfo;

    try {
      bool isPermission = await checkPermission(isCamera: true);
      if (!isPermission) {
        CommonFunction.showToast(context, 'msg_error_not_permission'.tr());
        return fileInfo;
      }

      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return fileInfo;
      }

      String folderPath = '';

      if (Platform.isIOS) {
        Directory documents = await getApplicationDocumentsDirectory();
        folderPath = "${documents.path}/${Setting.appFolderName}";

        String filePath = image.path;
        bool result = await GallerySaver.saveImage(image.path) ?? false;

        if (result) {
          File saveFile = File(filePath);
          var decodedImage = await decodeImageFromList(saveFile.readAsBytesSync());
          fileInfo = FileInfo(type: Common.image, filePath: filePath, width: decodedImage.width, height: decodedImage.height);

          Debug.log(tag, '## takePhoto() path = ${fileInfo.filePath}, width = ${fileInfo.width}, height = ${fileInfo.height}');
        }
      } else {
        String dcimPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DCIM);
        folderPath = "$dcimPath/${Setting.appFolderName}";

        final Directory directory = Directory(folderPath);

        bool isExistsFolder = await directory.exists();
        if (!isExistsFolder) {
          await directory.create(recursive: true);
          Debug.log(tag, '## create folder path = $folderPath');
        }

        File storedImage = File(image.path);
        final fileName = "${Setting.appFolderName}_${DateTime.now().millisecondsSinceEpoch}.${Common.fileExtensionJPG}";

        final filePath = '$folderPath/$fileName';

        final saveFile = await storedImage.copy(filePath);

        if (!await saveFile.exists()) {
          Debug.log(tag, '## photo save fail !!');
          return fileInfo;
        }

        if (Platform.isAndroid) {
          await MediaScanner.loadMedia(path: filePath);
        }

        var decodedImage = await decodeImageFromList(saveFile.readAsBytesSync());
        fileInfo = FileInfo(type: Common.image, filePath: filePath, width: decodedImage.width, height: decodedImage.height);

        Debug.log(tag, '## takePhoto() path = ${fileInfo.filePath}, width = ${fileInfo.width}, height = ${fileInfo.height}');
      }

      return fileInfo;
    } catch (e) {
      Debug.log(tag, '## Failed to pick image: $e');
    }
    return fileInfo;
  }

  Future<FileInfo?> takeVideo() async {
    FileInfo? fileInfo;

    try {
      bool isPermission = await checkPermission(isCamera: true);
      if (!isPermission) {
        CommonFunction.showToast(context, 'msg_error_not_permission'.tr());
        return fileInfo;
      }

      final video = await ImagePicker().pickVideo(source: ImageSource.camera);
      if (video == null) {
        return fileInfo;
      }

      String folderPath = '';

      File? saveFile;

      if (Platform.isIOS) {
        Directory documents = await getApplicationDocumentsDirectory();
        folderPath = "${documents.path}/${Setting.appFolderName}";

        // final fileName = "${Setting.appFolderName}_${DateTime.now().millisecondsSinceEpoch}";
        // final filePath = '$folderPath/$fileName.${Common.fileExtensionMOV}';

        String filePath = video.path;
        bool result = await GallerySaver.saveVideo(filePath) ?? false;

        if (!result) {
          Debug.log(tag, '## takeVideo() save video fail !!');
        }
        saveFile = File(filePath);
      } else {
        String dcimPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DCIM);
        folderPath = "$dcimPath/${Setting.appFolderName}";

        final Directory directory = Directory(folderPath);

        bool isExistsFolder = await directory.exists();
        if (!isExistsFolder) {
          await directory.create(recursive: true);
          Debug.log(tag, '## create folder path = $folderPath');
        }

        File storedVideo = File(video.path);
        final fileName = "${Setting.appFolderName}_${DateTime.now().millisecondsSinceEpoch}.${Common.fileExtensionMP4}";

        final filePath = '$folderPath/$fileName';

        saveFile = await storedVideo.copy(filePath);

        if (!await saveFile.exists()) {
          Debug.log(tag, '## video save fail !!');
          return fileInfo;
        }

        if (Platform.isAndroid) {
          await MediaScanner.loadMedia(path: filePath);
        }
      }

      final videoInfo = FlutterVideoInfo();
      VideoData? info = await videoInfo.getVideoInfo(saveFile.path);

      // fileInfo = FileInfo(type: Common.video, filePath: saveFile.path, width: info!.width!, height: info!.height!, rotation: info!.orientation);
      fileInfo = FileInfo(type: Common.video, filePath: saveFile.path);
      if (info != null) {
        fileInfo.width = info.width;
        fileInfo.height = info.height;
        fileInfo.rotation = info.orientation ?? 0;
        fileInfo.duration = (info.duration ?? 0) ~/ 1000;
      }

      Debug.log(tag, '## takeVideo() path = ${fileInfo.filePath}, width = ${fileInfo.width}, height = ${fileInfo.height}, rotation = ${fileInfo.rotation}');
      return fileInfo;
    } catch (e) {
      Debug.log(tag, '## Failed to pick image: $e');
    }
    return fileInfo;
  }
}
