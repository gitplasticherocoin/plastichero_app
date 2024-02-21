import 'dart:collection';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/data/gallery_media_info.dart';
import 'package:plastichero_app/provider/gallery_selection_provider.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:sprintf/sprintf.dart';

class GallerySelectionNotifier extends ChangeNotifier {
  BuildContext? context;
  final List<GalleryMediaInfo> selectedList;
  GalleryMediaInfo? media;
  final int maxItemCount;
  final int maxVideoItems = Common.maxGalleryVideoItems;
  double _scale = 0.0;
  Offset _offset = const Offset(0, 0);
  final bool isFeed;
  final SplayTreeSet<String>? pikLiveFileSet;

  GallerySelectionNotifier({
    this.context,
    List<GalleryMediaInfo>? list,
    this.media,
    this.maxItemCount = 1,
    this.isFeed = false,
    this.pikLiveFileSet,
  }) : selectedList = list ?? [];

  static GallerySelectionNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<GallerySelectionProvider>();
    assert(provider != null);
    return provider!.notifier;
  }

  void add(GalleryMediaInfo mediaAsset) {
    if (maxItemCount > selectedList.length) {
      if (isFeed && mediaAsset.typeInt == AssetType.video.index && getVideoFileCount() >= Common.maxGalleryVideoItems) {
        String errorStr = sprintf('msg_error_max_select_video'.tr(), [Common.maxGalleryVideoItems]);
        CommonFunction.showToast(context, errorStr);
        return;
      }

      selectedList.add(mediaAsset);
      media = mediaAsset;
      notifyListeners();
    } else {
      CommonFunction.showToast(context, 'msg_error_max_select_gallery'.tr());
    }
  }

  void remove(GalleryMediaInfo mediaAsset) {
    selectedList.removeWhere((element) => element.id == mediaAsset.id);
    if (selectedList.isNotEmpty) {
      media = selectedList[selectedList.length - 1];
    }
    notifyListeners();
  }

  void setMedia(AssetEntity mediaAsset, {Offset offset = const Offset(0, 0), double scale = 1.0}) {
    media = setGalleryMediaInfo(mediaAsset, offset, scale);
    notifyListeners();
  }

  void changeMedia(int index, {Offset offset = const Offset(0, 0), double scale = 1.0, bool isNotify = true}) {
    if (index < 0 || index >= selectedList.length) {
      return;
    }

    // save offset and scale info from the previous file.
    if (media != null) {
      int preIndex = getIndex(media!.id);
      if (preIndex >= 0) {
        GalleryMediaInfo info = selectedList[preIndex];
        info.offset = offset;
        info.scale = scale;
      }
    }

    media = selectedList[index];

    if (isNotify) {
      notifyListeners();
    }
  }

  void toggle(
    AssetEntity mediaAsset, {
    Offset offset = const Offset(0, 0),
    double scale = 1.0,
    BuildContext? context,
  }) async {
    GalleryMediaInfo galleryMediaInfo = setGalleryMediaInfo(mediaAsset, offset, scale);
    if (contains(galleryMediaInfo.id)) {
      File? file = await galleryMediaInfo.originFile;
      if (file != null && pikLiveFileSet != null && pikLiveFileSet!.contains(file.path)) {
        if (context != null && context.mounted) {
          CommonFunction.showToast(context, 'msg_error_remove_live_file'.tr());
        }
        return;
      }
      remove(galleryMediaInfo);
    } else {
      add(galleryMediaInfo);
    }
  }

  // use when max count is 1.
  void selectMedia(AssetEntity mediaAsset, {Offset offset = const Offset(0, 0), double scale = 1.0, isSaveInfo = false}) {
    GalleryMediaInfo galleryMediaInfo = setGalleryMediaInfo(mediaAsset, isSaveInfo ? _offset : offset, isSaveInfo ? _scale : scale);

    selectedList.clear();
    add(galleryMediaInfo);
  }

  GalleryMediaInfo setGalleryMediaInfo(AssetEntity asset, Offset offset, double scale) {
    if (media == null || media!.id == asset.id) {
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
      );
    }

    // Save offset and scale info from the previous file.
    int index = getIndex(media!.id);
    if (index >= 0) {
      GalleryMediaInfo info = selectedList[index];
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
    );
  }

  List<GalleryMediaInfo> getSelectedList() {
    return selectedList;
  }

  int getSelectedListSize() {
    return selectedList.length;
  }

  bool contains(String id) {
    return selectedList.any((element) => element.id == id);
  }

  int getIndex(String id) {
    return selectedList.indexWhere((element) => element.id == id);
  }

  GalleryMediaInfo? getSelectedItem(int index) {
    return (index < 0 && index >= selectedList.length) ? null : selectedList[index];
  }

  int getVideoFileCount() {
    int count = 0;
    int type = AssetType.video.index;
    for (var element in selectedList) {
      if (element.typeInt == type) {
        count++;
      }
    }
    return count;
  }

  bool isNowSelectedFile(String id) {
    return media != null && media!.id == id;
  }

  int isNowMediaIndex() {
    int index = -1;
    if (media != null) {
      GalleryMediaInfo info;
      for (int i = 0; i < selectedList.length; i++) {
        info = selectedList[i];
        if (media!.id == info.id) {
          index = i;
          break;
        }
      }
    }
    return index;
  }

  double get scale => _scale;

  Offset get offset => _offset;

  void setOffset(Offset offset) {
    _offset = offset;
  }

  void setScale(double scale) {
    _scale = scale;
  }
}
