import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:html/parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/provider/gallery_provider.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/provider/push_notification_provider.dart';
import 'package:plastichero_app/provider/share_provider.dart';
import 'package:plastichero_app/provider/wallet_provider.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:provider/provider.dart';

import 'constants/setting.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Debug.log(tag, 'firebaseMessagingBackgroundHandler');
  await Firebase.initializeApp();
  String sessionCode =
      await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
          '';
  if (sessionCode.isEmpty) {
    return;
  }
  getPushMessage(message: message, isBackground: true);
}

Future<void> onDidReceiveNotificationResponse(
    NotificationResponse details) async {
  Debug.log(tag, 'onDidReceiveNotificationResponse');
  onSelectNotification(details.payload);
}

Future<void> onDidReceiveBackgroundNotificationResponse(
    NotificationResponse details) async {
  Debug.log(tag, 'onDidReceiveBackgroundNotificationResponse');
  onSelectNotification(details.payload);
}

String parseHtmlString(String htmlString) {
  try {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  } catch (e) {
    return htmlString;
  }
}

Future<dynamic> showNotification(RemoteMessage message) async {
  Debug.log(Setting.appName, 'showNotification()');
  RemoteNotification? remoteNotification = message.notification;
  String title;
  String? body;
  String channelId;
  String channelName;
  if (remoteNotification != null) {
    title = remoteNotification.title ?? Setting.appName;
    body = remoteNotification.body;
    if (remoteNotification.android != null) {
      channelId = remoteNotification.android!.channelId ?? Setting.appName;
      channelName = remoteNotification.android!.channelId ?? 'Notification';
    } else {
      channelId = Setting.appName;
      channelName = 'Notification';
    }
  } else {
    title = message.data[ApiParamKey.title] ?? Setting.appName;
    body = message.data[ApiParamKey.body];
    channelId = message.data[ApiParamKey.channelId] ?? Setting.appName;
  }

  if (channelId.isNotEmpty) {
    if (channelId == Setting.appName) {
      channelName = 'Notification';
    } else {
      channelName = channelId;
    }
  } else {
    channelId = Setting.appName;
    channelName = 'Notification';
  }

  int notiIdx = 0;
  if (message.data.isNotEmpty) {
    if (message.data.containsKey(ApiParamKey.launch)) {
      String? launch = message.data[ApiParamKey.launch];
      if (launch != null) {
        if (launch == PushLaunchType.wallet.value) {
          if (message.data[ApiParamKey.targetIdx] is String) {
            notiIdx = int.tryParse(message.data[ApiParamKey.targetIdx]) ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.wallet.number}$notiIdx') ?? -1;
            }
          } else if (message.data[ApiParamKey.targetIdx] is int) {
            notiIdx = message.data[ApiParamKey.targetIdx] ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.wallet.number}$notiIdx') ?? -1;
            }
          }
        } else if (launch == PushLaunchType.notice.value) {
          if (message.data[ApiParamKey.targetIdx] is String) {
            notiIdx = int.tryParse(message.data[ApiParamKey.targetIdx]) ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.notice.number}$notiIdx') ?? -1;
            }
          } else if (message.data[ApiParamKey.targetIdx] is int) {
            notiIdx = message.data[ApiParamKey.targetIdx] ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.notice.number}$notiIdx') ?? -1;
            }
          }
        } else if (launch == PushLaunchType.qna.value) {
          if (message.data[ApiParamKey.targetIdx] is String) {
            notiIdx = int.tryParse(message.data[ApiParamKey.targetIdx]) ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.qna.number}$notiIdx') ?? -1;
            }
          } else if (message.data[ApiParamKey.targetIdx] is int) {
            notiIdx = message.data[ApiParamKey.targetIdx] ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.qna.number}$notiIdx') ?? -1;
            }
          }
        } else {
          if (message.data[ApiParamKey.targetIdx] is String) {
            notiIdx = int.tryParse(message.data[ApiParamKey.targetIdx]) ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.etc.number}$notiIdx') ?? -1;
            }
          } else if (message.data[ApiParamKey.targetIdx] is int) {
            notiIdx = message.data[ApiParamKey.targetIdx] ?? -1;
            if (notiIdx > -1) {
              notiIdx =
                  int.tryParse('${NotyPreIndex.etc.number}$notiIdx') ?? -1;
            }
          }
        }
      }
    }
  }

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channelId,
    channelName,
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(
      body ?? '',
      htmlFormatBigText: true,
    ),
    ticker: Setting.appName,
    groupKey: Setting.notificationGroupKey,
    setAsGroupSummary: true,
  );
  DarwinNotificationDetails darwinNotificationDetails =
      const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      notiIdx, title, parseHtmlString(body ?? ''), platformChannelSpecifics,
      payload: jsonEncode(message.data));
}

Future<void> onSelectNotification(String? data) async {
  Debug.log(tag, '## onSelectNotification ${data ?? ''}');
  if (data != null) {
    String email =
        await CommonFunction.getPreferencesString(PreferenceKey.email) ?? '';
    String sessionCode =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            '';
    if (email.isEmpty || sessionCode.isEmpty) {
      return;
    }

    if (navigatorKey.currentContext == null) {
      Common.pushData = data;
    } else {
      Common.pushData = data;
      Provider.of<PushNotificationProvider>(navigatorKey.currentContext!,
              listen: false)
          .setNotificationData(data, isSelectNoty: true);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }

  var androidSettings =
      const AndroidInitializationSettings("@mipmap/launcher_icon");
  var iOSSettings = const DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );
  InitializationSettings initSettings =
      InitializationSettings(android: androidSettings, iOS: iOSSettings);
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
  );
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    Setting.notificationChannelId,
    Setting.notificationChannelName,
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );
  AndroidNotificationChannel channelNotShowNoti =
      const AndroidNotificationChannel(
    Setting.notificationChannelId,
    Setting.notificationChannelName,
    description:
        'This channel is used for important notifications with not show noti.',
    importance: Importance.high,
    playSound: false,
    enableVibration: false,
    showBadge: false,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channelNotShowNoti);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  // await initDynamicLinks();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  messaging.getToken().then((token) {
    Debug.log(tag, 'token = $token');
    CommonFunction.setPreferencesString(PreferenceKey.fcmKey, token ?? '');
  });
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  messaging.getInitialMessage().then((RemoteMessage? message) async {
    Debug.log(tag, 'getInitialMessage Listen');
    if (message != null) {
      onSelectNotification(jsonEncode(message.data));
    } else {
      NotificationAppLaunchDetails? details =
          await flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
      if (details != null) {
        if (details.didNotificationLaunchApp) {
          if (details.notificationResponse != null) {
            onSelectNotification(details.notificationResponse!.payload);
          }
        }
      }
    }
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    Debug.log(tag, 'onMessage Listen');
    getPushMessage(message: message, isBackground: false);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    Debug.log(tag, 'onMessageOpenedApp Listen');
    getPushMessage(message: message, isBackground: true);
  });

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  await Permission.storage.request();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale.fromSubtags(languageCode: "en"),
          Locale.fromSubtags(languageCode: "ko"),
          Locale.fromSubtags(languageCode: "ja"),
        ],
        path: 'assets/translations',
        saveLocale: true,
        fallbackLocale: const Locale.fromSubtags(languageCode: 'ko'),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (BuildContext context) => PushNotificationProvider(),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => GalleryProvider(),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => ShareProvider(),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => WalletProvider(),
            ),
            // ChangeNotifierProvider(
            //   create: (BuildContext context) => WelcomeTobPTHProvider(),
            // ),
            ChangeNotifierProvider(
              create: (BuildContext context) => MyinfoProvider(),
            )
          ],
          child: const PlasticHero(),
        ),
      ),
    );
  });

  lang = await CommonFunction.getPreferencesString(PreferenceKey.lang) ?? '';
}

getPushMessage(
    {required RemoteMessage message, bool isBackground = false}) async {
  if (message.notification != null) {
    Debug.log(tag,
        '## getPushMessage message.notification.title = ${message.notification!.title}');
    Debug.log(tag,
        '## getPushMessage message.notification.body = ${message.notification!.body}');
  }

  // Map data = message.data;
  Debug.log(tag, '## getPushMessage message.data = ${message.data.toString()}');
  Debug.log(tag,
      '## getPushMessage message.notification.android.channelId = ${message.notification?.android?.channelId.toString()}');
  showNotification(message);
  // if (data.containsKey(ApiParamKey.launch)) {
  //   String? launch = data[ApiParamKey.launch];
  //   if (launch != null) {
  //     if (launch == PushLaunchType.wallet.value) {
  //       showNotification(message);
  //     } else if (launch == PushLaunchType.notice.value) {
  //       showNotification(message);
  //     } else if (launch == PushLaunchType.qna.value) {
  //       showNotification(message);
  //     } else {
  //       showNotification(message);
  //     }
  //   }
  // }
}

// Future<void> initDynamicLinks() async {
//   FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
//   final PendingDynamicLinkData? dynamicLinkData =
//       await dynamicLinks.getInitialLink();
//   if (dynamicLinkData != null) {
//     final Uri uri = dynamicLinkData.link;
//     final queryParams = uri.queryParameters;
//     if (queryParams.isNotEmpty) {
//       if (navigatorKey.currentContext == null) {
//         Common.shareData = uri.query;
//       } else {
//         Common.shareData = '';
//         Provider.of<ShareProvider>(navigatorKey.currentContext!, listen: false)
//             .setShareData(uri.query);
//       }
//     }
//   }
//   dynamicLinks.onLink.listen((dynamicLinkData) {
//     final Uri uri = dynamicLinkData.link;
//     final queryParams = uri.queryParameters;
//     if (queryParams.isNotEmpty) {
//       if (navigatorKey.currentContext == null) {
//         Common.shareData = uri.query;
//       } else {
//         Common.shareData = '';
//         Provider.of<ShareProvider>(navigatorKey.currentContext!, listen: false)
//             .setShareData(uri.query);
//       }
//     }
//   });
// }

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
const String tag = "Plastic Hero";
String? lang;

class PlasticHero extends StatelessWidget {
  const PlasticHero({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Status bar color
        statusBarColor: Colors.transparent,

        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.dark, // For iOS (dark icons)
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primaryColor: const Color(ColorTheme.appColor),
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Color(ColorTheme.appColor),
        ),
      ),
      onGenerateRoute: (settings) {
        return null;
      },
      routes: Routes.routes,
      initialRoute: Routes.introPage,
      navigatorObservers: [routeObserver],
      navigatorKey: navigatorKey,
      builder: (context, child) {
        if (child != null) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child,
          );
        } else {
          return Container();
        }
      },
      // home: const IntroPage()
    );
  }
}
