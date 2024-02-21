import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

// ignore: must_be_immutable
class GalleryMediaInfo extends AssetEntity {
  int fileIdx;
  int thumbIdx;
  Offset offset;
  double scale;
  String? filePath;
  String? thumbPath;
  File? tempFile;
  Uint8List? tempThumbFile;
  String cropPath;

  GalleryMediaInfo({
    super.id = '',
    super.typeInt = 1,
    super.mimeType,
    super.title,
    super.relativePath,
    super.width = 0,
    super.height = 0,
    super.duration = 0,
    super.orientation = 0,
    this.fileIdx = -1,
    this.thumbIdx = -1,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.filePath,
    this.tempFile,
    this.thumbPath,
    this.tempThumbFile,
    this.cropPath = '',
  });

  GalleryMediaInfo.clone(GalleryMediaInfo info)
      : this(
          id: info.id,
          typeInt: info.typeInt,
          mimeType: info.mimeType,
          title: info.title,
          relativePath: info.relativePath,
          width: info.width,
          height: info.height,
          duration: info.duration,
          orientation: info.orientation,
          fileIdx: info.fileIdx,
          thumbIdx: info.thumbIdx,
          offset: info.offset,
          scale: info.scale,
          filePath: info.filePath,
          tempFile: info.tempFile,
          thumbPath: info.thumbPath,
          tempThumbFile: info.tempThumbFile,
        );
}
