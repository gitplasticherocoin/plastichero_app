import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryListItemView extends StatefulWidget {
  final AssetEntity media;

  const GalleryListItemView({Key? key, required this.media}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GalleryListItemViewState();
  }
}

class _GalleryListItemViewState extends State<GalleryListItemView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     '## item title = ${widget.media.title}, orientation = ${widget.media.orientation}');
    int thumbnailSize = MediaQuery.of(context).size.width ~/ 2;

    if ((widget.media.mimeType ?? '').toLowerCase().contains('gif')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xfff2f2f2),
        child: FutureBuilder(
          future: widget.media.file,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Image.file(
                snapshot.data as File,
                fit: BoxFit.cover,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      );
    }

    return Container(
      color: const Color(0xfff2f2f2),
      child: FutureBuilder(
        future: widget.media.thumbnailDataWithSize(ThumbnailSize(thumbnailSize, thumbnailSize)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.memory(
                  snapshot.data as Uint8List,
                  fit: BoxFit.cover,
                ),
                if (widget.media.type == AssetType.video) ...[
                  Positioned(
                    right: 4.0,
                    bottom: 4.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0x80000000),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.fromLTRB(7.0, 2.5, 7.0, 2.5),
                      child: Text(
                        CommonFunction.getVideoTime(widget.media.duration),
                        style: const TextStyle(
                          height: 1.0,
                          fontSize: 13,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
