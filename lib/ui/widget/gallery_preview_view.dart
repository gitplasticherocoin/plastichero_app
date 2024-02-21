import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/data/gallery_media_info.dart';
import 'package:plastichero_app/notifier/gallery_selection_notifier.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/crop/crop.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:video_player/video_player.dart';

class GalleryPreview extends StatefulWidget {
  final bool isProfile;
  final bool removePreviewCircle;
  const GalleryPreview({
    Key? key,
    this.isProfile = false,
    this.removePreviewCircle = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GalleryPreviewState();
  }
}

class GalleryPreviewState extends State<GalleryPreview> {
  final tag = 'GalleryPreview';

  final GlobalKey key = GlobalKey();
  final GlobalKey<CropState> cropKey = GlobalKey();

  GallerySelectionNotifier? selectionNotifier;
  GalleryMediaInfo? media;
  File? mediaFile;
  String? fileType;
  String? videoUrl;

  Offset _offset = const Offset(0, 0);
  double _scale = 1.0;
  bool isPlayReady = false;
  Image? image;

  /// controller
  final cropController = CropController(aspectRatio: 1.0);
  VideoPlayerController? videoController;

  void stopPlay() {
    if (videoController != null && videoController!.value.isPlaying) {
      videoController!.seekTo(const Duration(seconds: 0));
      videoController!.pause();
    }
  }

  void startPlay() {
    if (videoController != null && isPlayReady) {
      videoController!.play();
    }
  }

  Offset get getOffset => cropController.offset;

  double get getScale => cropController.scale;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectionNotifier = GallerySelectionNotifier.of(context);
      selectionNotifier!.addListener(onReceive);
    });
  }

  @override
  void dispose() {
    cropController.dispose();
    if (videoController != null) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      }
      videoController!.dispose();
      videoController = null;
    }

    if (selectionNotifier != null) {
      selectionNotifier!.removeListener(onReceive);
    }

    super.dispose();
  }

  void initVideoController() {
    if (videoController != null) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      }
      videoController!.dispose();
      videoController = null;
    }
  }

  void onReceive() {
    if (selectionNotifier != null) {
      GalleryMediaInfo? media = selectionNotifier!.media;
      getMediaFile(media);
    }
  }

  void getMediaFile(GalleryMediaInfo? _media) async {
    if (_media == null) {
      return;
    }

    if (media != null) {
      if (media!.id == _media.id) {
        return;
      }
    }

    mediaFile = null;

    media = _media;

    _offset = _media.offset;
    _scale = _media.scale;

    fileType = '';

    if (videoController != null) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      }
      await videoController!.dispose();
      videoController = null;
    }

    if (media != null) {
      fileType = await media!.mimeTypeAsync;

      if (fileType != null && fileType!.contains(Common.fileExtensionMP4) || fileType!.contains(Common.video)) {
        videoUrl = await media!.getMediaUrl();
        if(Platform.isAndroid) {
          if (videoUrl != null) {
            isPlayReady = false;
            videoController = VideoPlayerController.contentUri(Uri.parse(videoUrl!))
              ..initialize().then((_) {
                isPlayReady = true;
                videoController!.play();
                setState(() {});
              });
            return;
          }
        }
        else {
          isPlayReady = false;
          File? file = await media!.originFile;

          if(file != null) {
            videoController = VideoPlayerController.file(file!)
              ..initialize().then((_) {
                isPlayReady = true;
                videoController!.play();
                setState(() {});
              });
          }
        }
      } else {
        cropKey.currentState?.setCropInfo(_offset, _scale);
      }
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant GalleryPreview oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: mediaWidget(),
    );
  }

  Widget mediaWidget() {
    if (fileType != null) {
      if (fileType!.toLowerCase().contains(Common.fileExtensionMP4) || fileType!.toLowerCase().contains(Common.video)) {
        if (videoUrl != null && isPlayReady && videoController != null && videoController!.value.isInitialized) {
          // Debug.log(tag, '## videoUrl = $videoUrl');
          // Debug.log(tag, '## file videoUrl = ${mediaFile?.path}');
          return FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: videoController!.value.size.width,
              height: videoController!.value.size.height,
              child: VideoPlayer(videoController!),
            ),
          );
        }
      } else if (mediaFile == null) {
        return FutureBuilder(
          future: media!.originFile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              mediaFile = snapshot.data as File;
              return imageWidget();
            } else {
              return Container(
                color: const Color(0xffe1e1e1),
              );
            }
          },
        );
      } else {
        return imageWidget();
      }
    }

    return Container(
      color: const Color(0xffe1e1e1),
    );
  }

  Widget imageWidget() {
    if (fileType!.contains(Common.fileExtensionGIF)) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          mediaFile!,
          errorBuilder: (context, exception, stackTrace) {
            return Container(
              color: const Color(0xffe1e1e1),
            );
          },
        ),
      );
    } else {
      double disWidth = MediaQuery.of(context).size.width;
      return Crop(
        key: cropKey,
        onChanged: (decomposition) {
          // print(
          //     "Scale : ${decomposition.scale}, translation: ${decomposition.translation}");
        },
        controller: cropController,
        shape: BoxShape.rectangle,
        offset: _offset,
        scale: _scale,
        childKey: key,
        overlay: widget.isProfile && !widget.removePreviewCircle
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.75), BlendMode.srcOut),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, backgroundBlendMode: BlendMode.dstOut), // This one will handle background + difference out
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.all(0),
                        height: disWidth,
                        width: disWidth,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(disWidth / 2),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        child: Image.file(
          mediaFile!,
          key: key,
          fit: BoxFit.cover,
          errorBuilder: (context, exception, stackTrace) {
            return Container(
              color: const Color(0xffe1e1e1),
            );
          },
        ),
      );
    }
  }

  Future<String> cropImage() async {
    String cropPath = '';
    try {
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final cropped = await cropController.crop(pixelRatio: pixelRatio);
      if (cropped != null) {
        String folderPath = await CommonFunction.getFolderPath(Common.tempPath);
        File file = await CommonFunction.saveCropImage(cropped, folderPath);
        cropPath = file.path;
      }
    } catch (e) {
      Debug.log(tag, '## cropImage() error = $e');
    }
    return cropPath;
  }
}
