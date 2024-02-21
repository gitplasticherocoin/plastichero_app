import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/gallery_media_info.dart';
import 'package:plastichero_app/manager/gallery_manager.dart';
import 'package:plastichero_app/notifier/gallery_selection_notifier.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/gallery_list_item_view.dart';
import 'package:plastichero_app/ui/widget/gallery_preview_view.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryListView extends StatefulWidget {
  final GalleryType type;
  final bool isFeed;
  final bool isSetFirstFile;
  final bool isCamera;
  final EdgeInsetsGeometry? padding;
  final GlobalKey<GalleryPreviewState>? previewKey;

  const GalleryListView({
    Key? key,
    required this.type,
    this.isFeed = false,
    this.isSetFirstFile = false,
    this.isCamera = false,
    this.padding,
    this.previewKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GalleryListViewState();
  }
}

class GalleryListViewState extends State<GalleryListView> with AutomaticKeepAliveClientMixin {
  final String tag = "GalleryListView";

  // late BuildContext loadContext;

  List<AssetEntity> galleryList = [];
  List<AssetPathEntity>? folders;

  String folderId = Common.allFolder; // All File
  bool isSetFirstFile = false;

  int headerCount = 0;

  File? cameraFile;

  final GlobalKey<AnimatedListState> gridViewKey = GlobalKey();
  late final ScrollController scrollController;
  late final LoadingDialog loadingDialog;

  int updateRepeat = 0; // check media scan file after taking a picture of the camera.

  int endIdx = 0;
  bool isMoreItem = true;
  bool isLoadMoreRunning = false;
  final int itemLimit = 1000;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: initState()
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(loadMore);
    loadingDialog = LoadingDialog(context: context);

    isSetFirstFile = widget.isSetFirstFile;

    getData();
  }

  @override
  void dispose() {
    scrollController.removeListener(loadMore);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> showLoading() async {
    loadingDialog.show();
  }

  Future<void> hideLoading() async {
    loadingDialog.hide();
  }

  // TODO: setFolderList()
  void setFolderList(String? id) {
    if (id == null || id.isEmpty) {
      Debug.log(tag, '## Folder Index is not correct!');
      return;
    }
    folderId = id;
    isSetFirstFile = false;
    getData();

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  // TODO: loadMore()
  loadMore() {
    if (isMoreItem == true && isLoadMoreRunning == false && scrollController.position.extentAfter < 1000) {
      isLoadMoreRunning = true;
      addData();
    }
  }

  addData() async {
    if (folders != null && folders!.isNotEmpty) {
      AssetPathEntity? folder;
      if (folderId.isEmpty || folderId == Common.allFolder) {
        // folder = folders![0];
        for (int i = 0; i < folders!.length; i++) {
          if (folders![i].isAll) {
            folder = folders![i];
            break;
          }
        }
      } else {
        for (AssetPathEntity item in folders!) {
          if (folderId == item.id) {
            folder = item;
            break;
          }
        }
      }
      if (folder != null) {
        int totalAssetCount = await folder.assetCountAsync;
        endIdx = galleryList.length + 1000 < totalAssetCount ? galleryList.length + 1000 : totalAssetCount;
        isMoreItem = endIdx < totalAssetCount;
        galleryList.addAll(await folder.getAssetListRange(start: galleryList.length, end: endIdx));
      }
    }
    isLoadMoreRunning = false;

    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        isLoadMoreRunning = false;
      });
    });
  }

  // TODO: checkPermission()
  Future<bool> checkPermission({bool isCamera = false}) async {
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

  // TODO : getDaTa()
  getData({bool isTakePhoto = false}) async {
    Debug.log(tag, '## getData() type = ${widget.type}');
    bool isPermission = await checkPermission(isCamera: widget.isCamera);
    if (!isPermission) {
      Debug.log(tag, '## You don\'t have permission.');
      if (mounted) {
        CommonFunction.showInfoDialog(context, 'msg_error_not_permission'.tr(), onConfirm: () {
          Navigator.pop(context);
        });
      }
      return;
    }

    galleryList.clear();

    switch (widget.type) {
      case GalleryType.image:
        folders = await PhotoManager.getAssetPathList(type: RequestType.image);
        break;
      case GalleryType.video:
        folders = await PhotoManager.getAssetPathList(type: RequestType.video);
        break;
      default:
        folders = await PhotoManager.getAssetPathList(onlyAll: true);
        break;
    }

    if (folders == null || folders!.isEmpty) {
      galleryList = [];
    } else {
      AssetPathEntity? folder;
      if (folderId.isEmpty || folderId == Common.allFolder) {
        folder = folders![0];
      } else {
        for (AssetPathEntity item in folders!) {
          if (folderId == item.id) {
            folder = item;
            break;
          }
        }
      }

      if (folder != null) {
        int totalAssetCount = await folder.assetCountAsync;
        endIdx = galleryList.length + itemLimit < totalAssetCount ? galleryList.length + itemLimit : totalAssetCount;

        if (endIdx == 0) {
          setState(() {});
          return;
        }
        galleryList = await folder.getAssetListRange(start: 0, end: endIdx);
      }

      if (widget.type == GalleryType.video && galleryList.isNotEmpty) {
        if (Platform.isIOS) {
          for (int i = galleryList.length - 1; i >= 0; i--) {
            AssetEntity asset = galleryList[i];

            String? mimeType = await asset.mimeTypeAsync;
            if (mimeType == null || !mimeType.toLowerCase().contains(Common.video)) {
              galleryList.removeAt(i);
            }
          }
        } else {
          galleryList.removeWhere((element) {
            return element.mimeType == null || !(element.mimeType!.toLowerCase().contains(Common.fileExtensionMP4) || element.mimeType!.toLowerCase().contains(Common.fileExtensionMOV));
          });
        }
      }

      if (widget.isCamera && widget.type == GalleryType.image && folderId == Common.allFolder) {
        headerCount = 1;
      } else {
        headerCount = 0;
      }

      if (!mounted) {
        return;
      }

      if (galleryList.isNotEmpty) {
        AssetEntity media = galleryList[0];
        GallerySelectionNotifier selectionNotifier = GallerySelectionNotifier.of(context);

        if (isTakePhoto) {
          GalleryMediaInfo? selectedMedia = selectionNotifier.media;

          Offset offset = const Offset(0, 0);
          double scale = 1.0;

          if (widget.type == GalleryType.image) {
            if (widget.previewKey != null) {
              offset = widget.previewKey?.currentState!.getOffset ?? const Offset(0, 0);
              scale = widget.previewKey?.currentState!.getScale ?? 1.0;
            }
          } else {
            if (selectedMedia != null && selectedMedia.typeInt == AssetType.image.index) {
              offset = selectionNotifier.offset;
              scale = selectionNotifier.scale;
            }
          }

          selectionNotifier.toggle(media, offset: offset, scale: scale);
        } else if (isSetFirstFile && galleryList.isNotEmpty) {
          int index = selectionNotifier.getIndex(media.id);
          if (index >= 0) {
            GalleryMediaInfo? mediaInfo = selectionNotifier.getSelectedItem(index);
            selectionNotifier.setMedia(galleryList[0], offset: mediaInfo!.offset, scale: mediaInfo.scale);
          } else {
            selectionNotifier.setMedia(galleryList[0]);
          }
        }
      }
    }

    Debug.log(tag, '## ${widget.type} list size = ${galleryList.length}');

    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoadMoreRunning = false;
      });
    });
  }

  GalleryMediaInfo setGalleryMediaInfo(AssetEntity asset) {
    return GalleryMediaInfo(
      id: asset.id,
      typeInt: asset.typeInt,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final selectionNotifier = GallerySelectionNotifier.of(context);
    final maxItemCount = selectionNotifier.maxItemCount;

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: galleryList.isEmpty
          ? Container(
              color: Colors.transparent,
            )
          : GridView.builder(
              key: gridViewKey,
              padding: widget.padding,
              shrinkWrap: true,
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: Common.galleryItemSpacing,
                crossAxisSpacing: Common.galleryItemSpacing,
              ),
              itemCount: galleryList.length,
              itemBuilder: (context, index) {
                if (headerCount == 1 && index == 0) {
                  /// camera view (header view)
                  return GestureDetector(
                    onTap: () async {
                      if (selectionNotifier.getSelectedListSize() >= maxItemCount) {
                        CommonFunction.showToast(context, 'msg_error_max_select_gallery'.tr());
                        return;
                      }

                      var isPermission = await GalleryManager(context).checkPermission(isCamera: true);

                      if (!isPermission) {
                        if (mounted) {
                          CommonFunction.showToast(context, 'msg_error_not_permission'.tr());
                        }
                        return;
                      }

                      takePhoto(selectionNotifier);
                    },
                    child: Container(
                      color: const Color(0xfff2f2f2),
                      child: Image.asset(
                        'images/feed_camera.png',
                        width: 47.0,
                        height: 46.0,
                      ),
                    ),
                  );
                } else {
                  AssetEntity media = galleryList[index - headerCount];

                  return GestureDetector(
                    onTap: () async {
                      if (widget.isFeed) {
                        // File? file = await media.file;
                        // if (widget.type == GalleryType.video) {
                        // int length = await file!.length();
                        // if (length > Common.maxVideoFileSize * 1024 * 1024) {
                        //   String errStr = sprintf('msg_error_large_size_video_file'.tr(), [Common.maxVideoFileSize]);
                        //   if (mounted) {
                        //     CommonFunction.showToast(context, errStr);
                        //   }
                        //   return;
                        // }
                        // }

                        GalleryMediaInfo? selectedMedia = selectionNotifier.media;
                        int index = selectionNotifier.getIndex(media.id);

                        Offset offset = const Offset(0, 0);
                        double scale = 1.0;

                        if (index >= 0 && selectedMedia != null && selectedMedia.id != media.id) {
                          if (widget.previewKey != null) {
                            offset = widget.previewKey?.currentState!.getOffset ?? const Offset(0, 0);
                            scale = widget.previewKey?.currentState!.getScale ?? 1.0;
                          }
                          selectionNotifier.changeMedia(index, offset: offset, scale: scale);
                        } else {
                          if (widget.type == GalleryType.image) {
                            if (widget.previewKey != null) {
                              offset = widget.previewKey?.currentState!.getOffset ?? const Offset(0, 0);
                              scale = widget.previewKey?.currentState!.getScale ?? 1.0;
                            }
                          } else {
                            if (selectedMedia != null && selectedMedia.typeInt == AssetType.image.index) {
                              offset = selectionNotifier.offset;
                              scale = selectionNotifier.scale;
                            }
                          }

                          selectionNotifier.toggle(media, offset: offset, scale: scale, context: context);
                        }
                      } else {
                        int index = selectionNotifier.getIndex(media.id);
                        if (maxItemCount > 1 || index >= 0) {
                          selectionNotifier.toggle(media);
                        } else {
                          selectionNotifier.selectMedia(media);
                        }
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        GalleryListItemView(
                          media: media,
                        ),
                        AnimatedBuilder(
                          animation: selectionNotifier,
                          builder: (context, _) {
                            bool isSelected = selectionNotifier.contains(media.id);
                            bool isNowSelected = selectionNotifier.isNowSelectedFile(media.id);
                            return isSelected
                                ? Container(
                                    color: isNowSelected ? Colors.white.withOpacity(0.6) : Colors.transparent,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width: 26.0,
                                        height: 26.0,
                                        margin: const EdgeInsets.only(top: 4.0, right: 4.0),
                                        decoration: BoxDecoration(
                                          color: const Color(ColorTheme.appColor),
                                          border: Border.all(color: Colors.white, width: 1.0),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        padding: (maxItemCount > 1) ? const EdgeInsets.only(left: 1.0, top: 1.0) : null,
                                        child: (maxItemCount > 1)
                                            ? Text(
                                                (selectionNotifier.getIndex(media.id) + 1).toString(),
                                                style: const TextStyle(
                                                  height: 1.0,
                                                  fontSize: 13,
                                                  fontFamily: Setting.appFont,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Image.asset(
                                                'images/check_im_w.png',
                                                width: 14.0,
                                                height: 10.0,
                                              ),
                                      ),
                                    ),
                                  )
                                : Container();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }

  void takePhoto(GallerySelectionNotifier selectionNotifier) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }

      updateRepeat = 0;

      String folderPath = '';

      if (Platform.isIOS) {
        String filePath = image.path;
        bool result = await GallerySaver.saveImage(image.path) ?? false;

        Debug.log(tag, '## saveImage result = $result');
        if (result) {
          updateList(filePath);
        }
      } else {
        String directoryPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DCIM);
        folderPath = "$directoryPath/${Setting.appFolderName}";

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
          return;
        }

        MediaScanner.loadMedia(path: filePath).then((value) async {
          Debug.log(tag, '## MediaScanner success !!');
          showLoading();
          updateList(filePath);
        });
      }
    } on PlatformException catch (e) {
      Debug.log(tag, 'Failed to pick image: $e');
    }
  }

  void updateList(String path) async {
    // check files in folders after taking a camera on Android until you scan the image
    await Future.delayed(const Duration(seconds: 1));

    if (updateRepeat > 3) {
      hideLoading();
      return;
    }

    List<AssetPathEntity> folders = await PhotoManager.getAssetPathList(type: RequestType.image);
    AssetPathEntity folder = folders[0];
    int assetCount = await folder.assetCountAsync;
    int index = assetCount > 5 ? 5 : assetCount;
    List<AssetEntity> list = await folders[0].getAssetListRange(start: 0, end: index);

    for (AssetEntity media in list) {
      if (media.title != null && path.contains(media.title!)) {
        getData(isTakePhoto: true);
        hideLoading();
        return;
      }
    }

    updateRepeat++;
    updateList(path);
  }
}
