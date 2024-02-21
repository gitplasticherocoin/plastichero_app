import 'dart:io';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class ShareExternal {
  static const String tag = 'ShareExternal';

  ShareExternal._();

  static void shareNetworkImage(String networkImageUrl) async {
    final  response = await get(Uri.parse(networkImageUrl));
    final bytes = response.bodyBytes;
    final Directory temp = await getTemporaryDirectory();
    final File imageFile = File('${temp.path}/tempImage');
    imageFile.writeAsBytesSync(bytes);
    Share.shareFiles(['${temp.path}/tempImage'], text: 'text to share',);

  }
}