import 'package:plastichero_app/api/api_param_key.dart';

class FileInfo {
  String type;
  int? width;
  int? height;
  int thumbIdx;
  int fileIdx;
  int rotation;
  int duration = 0;
  String filePath;
  String filePathResize;
  String filePathResizeS;
  String thumbPath;
  String thumbPathResizeS;
  int fileSize = 0;
  String codecName = '';
  String encoding = '';

  FileInfo(
      {required this.type,
      this.width,
      this.height,
      this.thumbIdx = -1,
      this.fileIdx = -1,
      this.rotation = 0,
      this.duration = 0,
      this.filePath = '',
      this.filePathResize = '',
      this.filePathResizeS = '',
      this.thumbPath = '',
      this.thumbPathResizeS = '',
      this.fileSize = 0,
      this.codecName = '',
      this.encoding = ''});

  FileInfo.fromJson(Map<String, dynamic> json)
      : type = json[ApiParamKey.type] ?? '',
        width = (json[ApiParamKey.width] ?? 0) is String ? int.tryParse(json[ApiParamKey.width]) : json[ApiParamKey.width],
        height = (json[ApiParamKey.height] ?? 0) is String ? int.tryParse(json[ApiParamKey.height]) : json[ApiParamKey.height],
        thumbIdx = json[ApiParamKey.thumb] ?? -1,
        fileIdx = json[ApiParamKey.fileIdx] ?? -1,
        duration = json[ApiParamKey.duration] ?? 0,
        rotation = int.parse(json[ApiParamKey.rotation] ?? '0'),
        filePath = json[ApiParamKey.filePath] ?? '',
        filePathResize = json[ApiParamKey.filePathResize] ?? '',
        filePathResizeS = json[ApiParamKey.filePathResizeS] ?? '',
        thumbPath = json[ApiParamKey.thumbPath] ?? '',
        thumbPathResizeS = json[ApiParamKey.thumbPathResizeS] ?? '',
        fileSize = json[ApiParamKey.fileSize] ?? 0,
        encoding = json[ApiParamKey.encoding] ?? '';

  Map<String, dynamic> toMap() => {
        ApiParamKey.type: type,
        ApiParamKey.width: width,
        ApiParamKey.height: height,
        ApiParamKey.thumb: thumbIdx,
        ApiParamKey.fileIdx: fileIdx,
        ApiParamKey.duration: duration,
        ApiParamKey.rotation: rotation.toString(),
        ApiParamKey.filePath: filePath,
        ApiParamKey.filePathResize: filePathResize,
        ApiParamKey.filePathResizeS: filePathResizeS,
        ApiParamKey.thumbPath: thumbPath,
        ApiParamKey.thumbPathResizeS: thumbPathResizeS,
        ApiParamKey.fileSize: fileSize,
        ApiParamKey.encoding: encoding
      };
}
