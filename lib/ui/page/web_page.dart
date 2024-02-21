
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:plastichero/plastichero.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/main_tab_type.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';



class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final GlobalKey webViewKey = GlobalKey();
  final GlobalKey webPopupKey = GlobalKey();
  String _urlRequest = "";
  InAppWebViewController? webViewController;
  InAppWebViewController? webViewPopupControler;

  late final LoadingDialog loadingDialog;
  String _code = "";

  final ReceivePort receivePort = ReceivePort();
  // int _progress = 0;
  String savedFilePath = "";


  @pragma('vm:entry-point')
  static void downloadCallback(String id, DownloadTaskStatus status, int downloadProgress) {

    // if(status == DownloadTaskStatus.complete) {
    //   //OpenFile.open();
    // }
    // // print("id: $id, status : $status, progress: $downloadProgress");
    // final SendPort sendPort = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    // sendPort.send([id, status.value, downloadProgress]);
  }

  // Future<String> getFilePath() async {
  //   final Directory downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
  //
  //   // Get the path as a string
  //   final String downloadsPath = downloadsDirectory.path;
  //
  //   return "$downloadsPath/$savedFilePath";
  // }

  Future<Object> getPermissions() async {
    bool gotPermissions = false;
    if (Platform.isAndroid) {

      var androidInfo = await DeviceInfoPlugin().androidInfo;
      //var release = androidInfo.version.release; // Version number, example: Android 12
      var sdkInt = androidInfo.version.sdkInt; // SDK, example: 31
      //var manufacturer = androidInfo.manufacturer;
      //var model = androidInfo.model;

      // print('Android $release (SDK $sdkInt), $manufacturer $model');

      if (sdkInt >= 30) {
        var storageExternal = await Permission.manageExternalStorage.status;

        // print("stroage_external : $storage_external");

        if (storageExternal != PermissionStatus.granted) {
          await Permission.manageExternalStorage.request();
        }

        storageExternal = await Permission.manageExternalStorage.status;

        if (storageExternal == PermissionStatus.granted) {
          gotPermissions = true;
        }
        return gotPermissions;
      } else {
        // (SDK < 30)

        var storage = await Permission.storage.status;
        if (storage != PermissionStatus.granted) {
          final status = await Permission.storage.request();
          if(status == PermissionStatus.permanentlyDenied) {
            openAppSettings();
          }
          return false;
        }else {
          return true;
        }
      }
    }
    return gotPermissions;

  }


  @override
  void initState() {


    // IsolateNameServer.registerPortWithName(receivePort.sendPort, 'downloader_send_port');
    // receivePort.listen((dynamic data) async{
    //   // String id = data[0];
    //   DownloadTaskStatus status = DownloadTaskStatus(data[1] as int);
    //   // int progress = data[2];
    //   if(status ==  DownloadTaskStatus.complete) {
    //
    //     if(Platform.isAndroid) {
    //       final path = await ExternalPath.getExternalStoragePublicDirectory(
    //           ExternalPath.DIRECTORY_DOWNLOADS);
    //       await OpenFile.open("$path/$savedFilePath");
    //     }else if (Platform.isIOS) {
    //       final path = await getApplicationDocumentsDirectory();
    //       await OpenFile.open("${path.path}/$savedFilePath");
    //
    //     }
    //
    //   }
    //   setState((){
    //    // _progress = progress;
    //   });
    // });

    // FlutterDownloader.registerCallback(downloadCallback);
    // _urlRequest = widget.url ?? "";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadingDialog = LoadingDialog(context: context);
     _code =
          await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
              "";



    });


  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        final Map<String, dynamic> arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        _urlRequest = arguments["url"] ?? "";
      final title = arguments["title"] ?? "";

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);


    return WillPopScope(
      onWillPop: () async {
        if (await webViewController?.canGoBack() ?? false) {
          webViewController?.goBack();
          return false;
        }
        return await backButtonAction();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(

          appBar: title != ""
              ? DefaultToolbar(
            isBackButton: true,
            onBackPressed: () {
              Navigator.of(context).pop();
            },
            centerTitle: false,
            titleText: title,

          ): null,
          backgroundColor: Colors.white,

          body: SafeArea(
            child:  InAppWebView(
              key: webViewKey,
              // initialUrlRequest: URLRequest(url: WebUri("${_url}/?code=$_code")),
              initialUrlRequest: URLRequest(url: WebUri(_urlRequest)),
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
                javaScriptEnabled: true,
                 useOnDownloadStart: false,
                // useShouldOverrideUrlLoading: false,
                // useHybridComposition: true,
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,
                applicationNameForUserAgent: "PlasticheroApp",
                // 지갑앱에서도 동일하게 사용하면 됩니다.
              ),
              onReceivedHttpError: (controller, request, response) async {

                // print("request : $request");
                //     print("response : ${response.statusCode}");
                // print("response : ${response.headers}");
                //     print("response : ${response.data}");


              },
              onCreateWindow: (controller, createWindowRequest) async{
                  // print("onCreateWindow");
                  // print("createWindowRequest : $createWindowRequest");
                  showDialog(context: context,
                      builder: (context) {
                    return AlertDialog(
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: InAppWebView(
                          key: webPopupKey,
                          windowId:  createWindowRequest.windowId,
                          initialSettings: InAppWebViewSettings(
                            transparentBackground: true,
                            useOnDownloadStart: false,
                            javaScriptEnabled: true,
                            // supportMultipleWindows: true,
                            // javaScriptCanOpenWindowsAutomatically: true,
                            applicationNameForUserAgent: "PlasticheroApp",
                          ),
                          onWebViewCreated: (InAppWebViewController controller) {
                            webViewPopupControler = controller;
                          },
                          onLoadStart: (controller , uri) {
                           // print("onLoadStart popup ${uri}");
                          },
                          onLoadStop: (controller, uri) {
                            //print("onLoadStop popup ${uri}");
                          },
                          onCloseWindow: (controller) {
                            //print("onCloseWindow");
                          },
                        ),
                      )
                    );


                  });

                  return true;

              },
              onWebViewCreated: (controller) {
                webViewController = controller;
                addAppJavascriptHandler(controller);

              },
              onLoadStart: (controller, uri) {
              },
            ),
          )
        ),
      ),
    );
  }

  void addAppJavascriptHandler(InAppWebViewController controller ) {


    // controller.addJavaScriptHandler(
    //     handlerName: "download",
    //     callback: (args) async {
    //
    //       print("download start");
    //       final result = args[0];
    //       final value = json.decode(result);
    //       final filename = value["filename"];
    //       final filepath = value["filepath"];
    //       final direcotry = await getExternalStorageDirectory();
    //       final path = direcotry?.path;
    //
    //       if(path == null) {
    //         return;
    //       }
    //       await FlutterDownloader.enqueue(
    //         url: filepath,
    //         fileName: filename,
    //         savedDir: path,
    //         showNotification: true,
    //         requiresStorageNotLow: false,
    //         openFileFromNotification: true,
    //         saveInPublicStorage: true,
    //       );
    //
    //
    //     });



    controller.addJavaScriptHandler(
        handlerName: "fail",
        callback: (args) {
          PlasticheroMember.logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(
              Routes.loginPage,
                  (route) => false);
        });
    controller.addJavaScriptHandler(
        handlerName: "linkAccount", callback: (args)
    {
      Navigator.of(context)
          .pushNamed(Routes.signupIdPage, arguments: {'joinType': 'snsLoginCreate'})
          .whenComplete(()  {
        webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(_urlRequest)));
      });
    });
    controller.addJavaScriptHandler(
        handlerName: "untrust",
        callback: (args) {
          Navigator.of(context).pushNamed(
              Routes.signupSmsPage,
              arguments: {
                'certType': CertType.changePhone,
                'type':
                CertChangeType.phone,
                'error': 'untrust',
              });
        });
    controller.addJavaScriptHandler(
        handlerName: "loading",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);
          if (value["status"] == "show") {
            loadingDialog.show();
          } else if (value["status"] ==
              "hide") {
            loadingDialog.hide();
          }
        });

    controller.addJavaScriptHandler(
        handlerName: "window",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);
          if (value["url"].isNotEmpty) {
            final url = value["url"]!;
            openExternalWindow(url);

          }
        });

    controller.addJavaScriptHandler(
        handlerName: "tab",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);

          final status = value["status"] ?? "";
          if (status != "") {
            tapTab(MainTabType.getIndex(status));
          }
        });
    controller.addJavaScriptHandler(
        handlerName: "open",
        callback: (args) {
          final result = args[0];
          final value = json.decode(result);
          final title = value["title"] ?? "";
          String  url = value["url"] ?? "";
          if( url != "" && _code != "") {
            Uri uri = Uri.parse(url);

            const domain = Setting.isTest ? Setting.domainDev : Setting.domain;
            Uri domainUri = Uri.parse(domain);
            if(uri.host == domainUri.host) {
              if (uri.queryParameters.keys.isEmpty ) {
                url = "$url?code=$_code";
              }else {
                url = "$url&code=$_code";
              }
            }else {
              url = url;
            }
            Navigator.of(context).pushNamed(
                Routes.webPage, arguments: {"url": url, "title": title});
          }
        });
  }

  void tapTab(int index) {
    Navigator.of(context).pop(index.toString());
  }

  Future<bool> backButtonAction() async{
    Navigator.of(context).pop();
    return true;
  }

  Future<void> openExternalWindow(String url) async {
    final urlLink =Uri.parse(url);
    if(await canLaunchUrl(urlLink)) {
      launchUrl(urlLink , mode: LaunchMode.externalApplication);
    }
  }
}
