import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:plastichero_app/data/gallery_media_info.dart';

class GalleryProvider extends ChangeNotifier {
  List<GalleryMediaInfo> _selectedList = [];
  GalleryMediaInfo? _mediaInfo;
  int _maxItemCount = 4;
  double _scale = 0.0;
  Offset _offset = const Offset(0, 0);

  get getSelectedList => _selectedList;

  get getSelectedListSize => _selectedList.length;

  get getMediaInfo => _mediaInfo;

  get getMaxItemCount => _maxItemCount;

  get getScale => _scale;

  get getOffset => _offset;

  void clearData() {
    _selectedList.clear();
    _mediaInfo = null;
    _maxItemCount = 4;
    _scale = 0.0;
    _offset = const Offset(0, 0);
    notifyListeners();
  }

  void setSelectedList(List<GalleryMediaInfo> selectedList) {
    _selectedList = selectedList;
    notifyListeners();
  }

  void setMaxItemCount(int maxItemCount) {
    _maxItemCount = maxItemCount;
  }

  void setOffset(Offset offset) {
    _offset = offset;
  }

  void setScale(double scale) {
    _scale = scale;
  }

  bool add(GalleryMediaInfo mediaAsset) {
    if (_maxItemCount != 1 && _maxItemCount <= _selectedList.length) {
      return false;
    }
    _selectedList.add(mediaAsset);
    _mediaInfo = mediaAsset;
    notifyListeners();
    return true;
  }

  void remove(GalleryMediaInfo mediaAsset) {
    _selectedList.removeWhere((element) => element.id == mediaAsset.id);
    if (_selectedList.isNotEmpty) {
      _mediaInfo = _selectedList[_selectedList.length - 1];
    }
    notifyListeners();
  }

  void setMedia(AssetEntity mediaAsset, {Offset offset = const Offset(0, 0), double scale = 1.0}) async {
    _mediaInfo = await setGalleryMediaInfo(mediaAsset, offset, scale);
    notifyListeners();
  }

  void changeMedia(int index, {Offset offset = const Offset(0, 0), double scale = 1.0, bool isNotify = true}) {
    if (index < 0 || index >= _selectedList.length) {
      return;
    }
    if (_mediaInfo != null) {
      int preIndex = getIndex(_mediaInfo!.id);
      if (preIndex >= 0) {
        GalleryMediaInfo info = _selectedList[preIndex];
        info.offset = offset;
        info.scale = scale;
      }
    }
    _mediaInfo = _selectedList[index];
    if (isNotify) {
      notifyListeners();
    }
  }

  Future<bool> toggle(AssetEntity mediaAsset, {Offset offset = const Offset(0, 0), double scale = 1.0}) async {
    GalleryMediaInfo galleryMediaInfo = await setGalleryMediaInfo(mediaAsset, offset, scale);
    if (contains(galleryMediaInfo.id)) {
      remove(galleryMediaInfo);
      return true;
    } else {
      return add(galleryMediaInfo);
    }
  }

  void selectMedia(AssetEntity mediaAsset, {Offset offset = const Offset(0, 0), double scale = 1.0, isSaveInfo = false}) async {
    GalleryMediaInfo galleryMediaInfo = await setGalleryMediaInfo(mediaAsset, isSaveInfo ? _offset : offset, isSaveInfo ? _scale : scale);
    _selectedList.clear();
    add(galleryMediaInfo);
  }

  Future<GalleryMediaInfo> setGalleryMediaInfo(AssetEntity asset, Offset offset, double scale) async {
    File? file = await asset.file;
    if (_mediaInfo == null || _mediaInfo!.id == asset.id) {
      return GalleryMediaInfo(
        id: asset.id,
        typeInt: asset.typeInt,
        mimeType: asset.mimeType,
        title: asset.title,
        relativePath: asset.relativePath,
        width: asset.width,
        height: asset.height,
        duration: asset.duration,
        orientation: asset.orientation,
        offset: offset,
        scale: scale,
        filePath: file?.path.toString(),
      );
    }
    int index = getIndex(_mediaInfo!.id);
    if (index >= 0) {
      GalleryMediaInfo info = _selectedList[index];
      info.offset = offset;
      info.scale = scale;
    }
    return GalleryMediaInfo(
      id: asset.id,
      typeInt: asset.typeInt,
      mimeType: asset.mimeType,
      title: asset.title,
      relativePath: asset.relativePath,
      width: asset.width,
      height: asset.height,
      duration: asset.duration,
      orientation: asset.orientation,
      offset: const Offset(0, 0),
      scale: 1.0,
      filePath: file?.path.toString(),
    );
  }

  bool contains(String id) {
    return _selectedList.any((element) => element.id == id);
  }

  int getIndex(String id) {
    return _selectedList.indexWhere((element) => element.id == id);
  }

  GalleryMediaInfo? getSelectedItem(int index) {
    return (index < 0 && index >= _selectedList.length) ? null : _selectedList[index];
  }

  int getVideoFileCount() {
    int count = 0;
    int type = AssetType.video.index;
    for (var element in _selectedList) {
      if (element.typeInt == type) {
        count++;
      }
    }
    return count;
  }

  bool isNowSelectedFile(String id) {
    return _mediaInfo != null && _mediaInfo!.id == id;
  }

  int isNowMediaIndex() {
    int index = -1;
    if (_mediaInfo != null) {
      GalleryMediaInfo info;
      for (int i = 0; i < _selectedList.length; i++) {
        info = _selectedList[i];
        if (_mediaInfo!.id == info.id) {
          index = i;
          break;
        }
      }
    }
    return index;
  }
}
