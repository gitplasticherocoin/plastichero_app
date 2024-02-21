
import 'package:plastichero/plastichero.dart';
// ignore_for_file: constant_identifier_names
class Setting {
  static const bool isTest = false;
  static const bool isTestLocal = false;
  static const bool isUseSwap = true;
  static const bool isUseWallet = true;

  static const bool isAuthCode = isTest;
  static const String device = "mobile";

  static const String appFont = 'Pretendard';

  static const String appName = 'Plastic Hero';
  static const String appFolderName = 'Plastic Hero';

  /// Notification
  static const String notificationChannelId = appName;
  static const String notificationChannelName = '$appName Channel';
  static const String notificationGroupKey = 'io.ecocentre.app';

  /// Local DB
  static const int dbVersion = 1;
  static const String dbName = "plastic_hero.db";

  ///App Store Link

  static const String MARKET_LINK_ANDROID = "https://play.google.com/store/apps/details?id=sigmachain.app.plastichero";
  static const String MARKET_LINK_IOS = "https://apps.apple.com/app/6447415477";
  static const String APP_MARKET_LINK_ANDROID = "https://play.google.com/store/apps/details?id=sigmachain.app.plastichero";
  static const String APP_MARKET_LINK_IOS = "https://apps.apple.com/app/6464238261";
  static const String EXPLORER_LINK_RUN = "https://pthscan.com/explorer";
  static const String EXPLORER_LINK_DEV = "https://testnet.pthscan.com/explorer";
  static const String EXPLORER_LINK = isTest ? EXPLORER_LINK_DEV : EXPLORER_LINK_RUN;
  /// User Info
  static const int nickMaxLength = 10;
  static const int oneLineMaxLength = 60;

  /// hashtag
  static const int hashtagMaxNum = 10;
  static const int hashtagMaxLength = 20;

  /// Wallet
  static const String appCoin = 'P';
  static const String appSymbol = 'PTH';

  static const String walletCoin = 'XTRION';
  static const String walletSymbol = 'X3O';
  static const String decimalFormat = '#,###.##################';
  static const int decimalDigits = 6;
  static const int bPthDecimalDigits = 18;
  static const int scaleNum = 8;

  static const int authCodeLength = 6;

  /// server
  static const String domain = "https://app.plasticherocoin.com"; //"https://ph.sigmachain.co.kr";
  static const String domainDev = Setting.isTestLocal ?  "http://192.168.100.193:94" :  "https://ph.sgmchain.com";
  static const String nodeDomain = "https://wallet.plasticherocoin.com";
  static const String nodeDomainDev = "https://wallet-api-dev.plasticherocoin.com";
  //static const String domainDev = "http://192.168.100.193:94";pub

  static const String connectUrl = "$domain/api";
  static const String connectUrlDev = "$domainDev/api";

  /// file socket server
  static const String domainFileServer = "https://piki-upload.sgmchain.net";
  static const String domainDevFileServer = "https://piki-upload.sgmchain.net";

  /// terms url
  // static const String termsOfUseCoinUrl = "https://piki.market/policyApp/terms_app_xtrion";
  // static const String termsOfUseUrl = "https://piki.market/policyApp/terms_app_piki";
  // static const String termsOfPrivacyCoinUrl = "https://piki.market/policyApp/privacy_app_xtrion";
  // static const String termsOfPrivacyUrl = "https://piki.market/policyApp/privacy_app_piki";
  // static const String termsOfLocationUrl = "https://piki.market/policyApp/location_app";
  // static const String termsOfEventUrl = "https://piki.market/policyApp/operation_app";
  static const String termsOfUseUrl = "${(Setting.isTest ? domainDev : domain )}/mobile/terms/service_use.php";
  static const String termsOfPrivacyUrl =  "${(Setting.isTest ? domainDev : domain )}/mobile/terms/privacy_policy.php";
  //앱구분
  static const AppType appType = AppType.app;
}
