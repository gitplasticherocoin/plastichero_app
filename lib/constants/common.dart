import 'package:flutter/material.dart';

class Common {
  static const String device = "app";
  static const double appBar = 64.0;

  static const double boxH = 50.0;
  static const double buttonH = 54;
  static const double dialogButtonH = 48;

  static const String rotation_0 = '0';
  static const String rotation_90 = '90';
  static const String rotation_180 = '180';
  static const String rotation_270 = '270';

  static const int maxGalleryItems = 10;
  static const int maxGalleryVideoItems = 10;
  static const int maxVideoFileSize = 200;

  static const double galleryItemSpacing = 4.0;
  static const String fileExtensionGIF = "gif";
  static const String fileExtensionJPG = "jpg";
  static const String fileExtensionPNG = "png";
  static const String fileExtensionMP4 = "mp4";
  static const String fileExtensionMOV = 'mov';
  static const String image = 'image';
  static const String video = 'video';
  static const String thumb = 'thumb';

  static const String allFolder = 'isAll';
  static const String tempPath = '/temp';

  static const String qrcodeSplit = "?amount=";

  static const double foldingSize = 550;

  // push
  static String pushData = '';
  static String shareData = '';

  // operation
  static const String operationWalletCreate = 'account_create';
  static const String operationWalletUpdate = 'account_update';
  static const String operationTransfer = 'transfer';
  static const String operationDApp = 'transfer_fund';
  static const String operationDAppFee = 'dapp_fee_virtual';
  static const String operationFee = 'tx_fee_virtual';

  static const String regexToRemoveEmoji =
      r'(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|\ud83c[\ude32-\ude3a]|\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])';
  static const String regHashtag = r'^[^\\/:*?"<>|# ]+$';
}

enum CoinType {
  point,
  coin,
  token,
}

enum DynamicLink {
  etc,
}

enum GalleryType {
  all,
  image,
  video,
}

enum PushLaunchType {
  wallet,
  notice,
  qna,
}

extension PushLaunchTypeName on PushLaunchType {
  String get value {
    if (this == PushLaunchType.wallet) {
      return 'wallet';
    } else if (this == PushLaunchType.notice) {
      return 'notice';
    } else if (this == PushLaunchType.qna) {
      return 'qna';
    } else {
      return 'etc';
    }
  }
}

enum NotyPreIndex {
  wallet,
  notice,
  qna,
  etc,
}

extension NotyPreIndexNumber on NotyPreIndex {
  String get number {
    if (this == PushLaunchType.wallet) {
      return '200';
    } else if (this == PushLaunchType.notice) {
      return '300';
    } else if (this == PushLaunchType.qna) {
      return '400';
    } else {
      return '100';
    }
  }
}

enum LoginPlatform {
  apple,
  naver,
  google,
  plastichero,
  none
}


enum UpdateType {
  update,
  add,
}

enum WalletType {
  pth,
  bsc,
}

extension WalletSymbol on WalletType {
  String get symbol {
    if (this == WalletType.pth) {
      return 'PTH';
    } else if (this == WalletType.bsc) {
      return 'BSC';
    } else {
      return 'PTH';
    }
  }
}

enum BSCWalletType {
  bnb,
  bPth,
}

extension BSCWalletSymbol on BSCWalletType {
  String get symbol {
    if (this == BSCWalletType.bPth) {
      return 'PTH(ERC20)';
    } else if (this == BSCWalletType.bnb) {
      return 'ETH';
    } else {
      return 'bPTH';
    }
  }
}

enum TransactionType {
  deposit,
  withdrawal,
}

extension StringEllipsis on String {
  String tight() {
    return Characters(this).replaceAll(Characters(''), Characters('\u{200B}')).toString();
  }
}
