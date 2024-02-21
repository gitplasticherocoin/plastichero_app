import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryFolderListDialog extends StatefulWidget {
  final GalleryType type;

  const GalleryFolderListDialog({Key? key, required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GalleryFolderListDialogState();
  }
}

class GalleryFolderListDialogArguments {
  String? id;
  String? name;

  GalleryFolderListDialogArguments(this.id, this.name);
}

class _GalleryFolderListDialogState extends State<GalleryFolderListDialog> with SingleTickerProviderStateMixin {
  final String tag = "GalleryFolderListDialog";

  List<AssetPathEntity> folderList = [];

  final GlobalKey key = GlobalKey();
  final double itemHeight = 50.0;
  final double radiusSize = 16.0;
  double height = 0;

  String? selectedFolderId;
  String? selectedFolderName;
  bool isDownList = false;
  bool isMoving = false;
  int hiddenFolderCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getData() async {
    var permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      Debug.log(tag, '## You don\'t have permission.');
      return;
    }

    switch (widget.type) {
      case GalleryType.image:
        folderList = await PhotoManager.getAssetPathList(type: RequestType.image);
        break;
      case GalleryType.video:
        folderList = await PhotoManager.getAssetPathList(type: RequestType.video);
        break;
      default:
        break;
    }

    AssetPathEntity? allFolder;
    if (folderList.isEmpty) {
      folderList = [];
    } else {
      for (int i = 0; i < folderList.length; i++) {
        if (folderList[i].isAll) {
          allFolder = folderList[i];
          folderList.removeAt(i);
          break;
        }
      }

      folderList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    hiddenFolderCount = 0;
    for (AssetPathEntity assetPathEntity in folderList) {
      int getCount = await assetPathEntity.assetCountAsync;
      if (getCount == 0) {
        hiddenFolderCount++;
      }
    }
    if (allFolder != null) {
      folderList.insert(0, allFolder);
    }

    selectedFolderId = '';
    selectedFolderName = '';

    if (mounted) {
      setState(() {
        setIsDownList(true);
      });
    }
  }

  setIsDownList(bool isStart) {
    if (!isMoving) {
      setState(() {
        isMoving = true;
        isDownList = isStart;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setViewHeight(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          setIsDownList(false);
        },
        child: Stack(
          key: key,
          children: <Widget>[
            Container(
              width: double.infinity,
              color: Colors.transparent,
            ),
            Container(
              margin: const EdgeInsets.only(top: Common.appBar),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: AnimatedContainer(
                      alignment: Alignment.topLeft,
                      duration: const Duration(milliseconds: 200),
                      height: isDownList ? height : 0,
                      onEnd: () {
                        if (!isDownList) {
                          if (selectedFolderId == null || selectedFolderId!.isEmpty) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(
                              context,
                              GalleryFolderListDialogArguments(selectedFolderId, selectedFolderName),
                            );
                          }
                        }
                        isMoving = false;
                      },
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(radiusSize),
                          bottomRight: Radius.circular(radiusSize),
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0xfff0f0f0), spreadRadius: 1),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: folderList.length,
                        itemBuilder: (context, index) {
                          AssetPathEntity folder = folderList[index];
                          return FutureBuilder<int>(
                              future: folder.assetCountAsync,
                              builder: (context, snapshot) {
                                int? totalAssetCount = snapshot.data;
                                if (folder.isAll || totalAssetCount != 0) {
                                  return GestureDetector(
                                    onTap: () {
                                      selectedFolderId = folder.id;
                                      selectedFolderName = folder.isAll ? 'all'.tr() : folder.name;

                                      setIsDownList(false);
                                    },
                                    child: Container(
                                      height: itemHeight,
                                      padding: const EdgeInsets.only(left: 20, right: 20),
                                      alignment: Alignment.center,
                                      decoration: (index == 0)
                                          ? const BoxDecoration(color: Colors.white)
                                          : const BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                top: BorderSide(
                                                  width: 1.0,
                                                  color: Color(0xfff0f0f0),
                                                ),
                                              ),
                                            ),
                                      child: Text(
                                        folder.isAll ? 'all'.tr() : folder.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            height: 1.0, color: Color(0xff212121), fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 15, decoration: TextDecoration.none),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    height: 0,
                                  );
                                }
                              });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setViewHeight(BuildContext context) {
    if (folderList.isEmpty) {
      height = 0;
    } else {
      final double disHeight = MediaQuery.of(context).size.height * 0.8;
      final double sumItemHeight = (folderList.length - hiddenFolderCount) * itemHeight;
      height = disHeight > sumItemHeight ? sumItemHeight : disHeight;
    }
  }
}
