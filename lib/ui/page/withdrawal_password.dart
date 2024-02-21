import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:open_settings/open_settings.dart';
import 'package:plastichero/util/encrypt.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/common/api_manager_common.dart';
import 'package:plastichero_app/api/wallet/wallet_common.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/ui/widget/toolbar_widget.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

import '../../api/member/check_response.dart';
import '../../constants/preference_key.dart';
import '../../constants/setting.dart';


class WithdrawalPassword extends StatefulWidget {
  const WithdrawalPassword({super.key});

  @override
  State<StatefulWidget> createState() {
    return WithdrawalPasswordState();
  }
}

class WithdrawalPasswordState extends State<WithdrawalPassword> {
  Map<String, dynamic>? arguments;

  int type = 0;

  int passwordLength = 6;

  double gridItemWidth = 0;
  double gridItemHeight = 0;

  List<bool> isInputPassword = [false, false, false, false, false, false];

  int currentIndex = -1;

  String getPassword = '';
  String savedPassword = '';

  bool failCheck = false;

  bool recheckPassword = false;

  bool ingDel = false;

  List<bool> onPress = List.generate(12, (index) => false);

  final LocalAuthentication auth = LocalAuthentication();

  List<double> passwordBtnSize = [];

  double passwordBtnSizeDefault = 18;
  double passwordBtnSizeFocus = 23;

  int changePasswordStep = 0; // 0 = oldPw, 1 = newPw, 2= newPwConfirm
  String oldPw = '';

  late LoadingDialog loadingDialog;

  @override
  void initState() {
    super.initState();

    loadingDialog = LoadingDialog(context: context);

    passwordBtnSize = List.generate(passwordLength, (index) => passwordBtnSizeDefault);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      checkBiometrics(isStart: true);
    });
  }

  Future<void> checkBiometrics({bool isStart = false}) async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

    if (canAuthenticate) {
      if (type == 2 || (type == 3 && changePasswordStep == 0)) {
        final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty || !isStart) {
          _authenticateWithBiometrics();
        }
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      AndroidAuthMessages androidAuthStrings = AndroidAuthMessages(
        biometricHint: '',
        biometricNotRecognized: 'biometricNotRecognized',
        biometricRequiredTitle: 'biometricRequiredTitle',
        biometricSuccess: 'biometricSuccess',
        cancelButton: 'input_password'.tr(),
        deviceCredentialsRequiredTitle: 'deviceCredentialsRequiredTitle',
        deviceCredentialsSetupDescription: 'deviceCredentialsSetupDescription',
        goToSettingsButton: 'goToSettingsButton',
        goToSettingsDescription: 'goToSettingsDescription',
        signInTitle: 'need_auth'.tr(),
      );

      IOSAuthMessages iosAuthStrings = IOSAuthMessages(
        // lockOut: '',
        // goToSettingsButton: '',
        // goToSettingsDescription: '',
        cancelButton: 'input_password'.tr(),
        // localizedFallbackTitle: ''
      );

      authenticated = await auth.authenticate(
        localizedReason: 'localized_reason'.tr(),
        authMessages: [const IOSAuthMessages(), androidAuthStrings],
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true, useErrorDialogs: false),
      );

      if (authenticated) {
        if (mounted) {
          if (type == 2) {
            Navigator.pop(context, true);
          } else {
            // type 3
            oldPw = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? "";
            String oldTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? "";

            AESHelper aesHelper = AESHelper();
            oldPw = aesHelper.decrypt(oldPw, oldTs);

            setState(() {
              changePasswordStep = 1;
            });
          }
        }
      } else {
        // if(mounted) {
        //   CommonFunction.showToast(context, 'fail_localized_reason'.tr());
        // }

        // setState(() {
        //   failCheck = true;
        // });
      }
    } on PlatformException catch (e) {
      print('PlatformException $e');
      if (e.code == auth_error.notAvailable) {
        CommonFunction.showConfirmDialog(
            context: context,
            msg: 'msg_turn_on_security_setting'.tr(),
            btnConfirmText: 'confirm'.tr(),
            btnCancelText: 'cancel'.tr(),
            onConfirm: () {
              OpenSettings.openSecuritySetting();
            });
      } else if (e.code == auth_error.notEnrolled) {
        // OpenSettings.openBiometricEnrollSetting();

        CommonFunction.showConfirmDialog(
            context: context,
            msg: 'msg_turn_on_biometric_setting'.tr(),
            btnConfirmText: 'confirm'.tr(),
            btnCancelText: 'cancel'.tr(),
            onConfirm: () async {
              final androidInfo = await DeviceInfoPlugin().androidInfo;
              if (androidInfo.version.sdkInt < 30) {
                OpenSettings.openSecuritySetting();
              } else {
                OpenSettings.openBiometricEnrollSetting();
              }
            });
      } else {
        CommonFunction.showInfoDialog(context, e.message);
      }
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? "msg_validate_code".tr() : "msg_fail_code".tr();
    setState(() {});
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    if (arguments == null) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      type = arguments!["type"] ?? 0; // 1= create, 2= check, 3 = change
    }

    gridItemWidth = (MediaQuery.of(context).size.width - 2 * 24) / 3;
    if (gridItemWidth > 104) gridItemWidth = 104;
    gridItemHeight = gridItemWidth * 80 / 104;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: DefaultToolbar(
            titleText: type == 1
                ? 'create_withdrawal_password'.tr()
                : type == 2
                    ? 'withdrawal_password'.tr()
                    : changePasswordStep == 0
                        ? 'withdrawal_password'.tr()
                        : 'change_withdrawal_password'.tr(),
            centerTitle: type == 1
                ? true
                : type == 2
                    ? false
                    : true,
            isBackButton: type == 1
                ? recheckPassword
                    ? true
                    : false
                : type == 2
                    ? true
                    : true,
            onBackPressed: () {
              if (type == 1 && recheckPassword) {
                backToFirstPassword();
              } else if (type == 2) {
                Navigator.pop(context, false);
              } else if (type == 3) {
                if (changePasswordStep == 0 || changePasswordStep == 1) {
                  Navigator.pop(context, false);
                } else {
                  changePasswordStep = 1;
                  backToFirstPassword();
                }
              }
            },
          ),
          body: WillPopScope(
              onWillPop: () async {
                if (type == 1) {
                  if (recheckPassword) {
                    backToFirstPassword();
                  }
                  return false;
                } else if (type == 2) {
                  Navigator.pop(context, false);
                  return false;
                } else if (type == 3) {
                  if (changePasswordStep == 0 || changePasswordStep == 1) {
                    return true;
                  } else {
                    changePasswordStep = 1;

                    backToFirstPassword();
                    return false;
                  }
                }

                return true;
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (type == 3)
                                ? changePasswordStep == 0
                                    ? 'msg_withdrawal_password2'.tr()
                                    : changePasswordStep == 1
                                        ? 'msg_withdrawal_password'.tr()
                                        : 'msg_recheck_password'.tr()
                                : recheckPassword
                                    ? 'msg_recheck_password'.tr()
                                    : 'msg_withdrawal_password'.tr(),
                            style: const TextStyle(fontFamily: Setting.appFont, fontWeight: FontWeight.w400, fontSize: 15, color: Color(ColorTheme.defaultText)),
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          SizedBox(
                            height: 23,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: passwordLength,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return passwordWidget(index);
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return const SizedBox(
                                  width: 12,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          failCheck
                              ? Text(
                                  'hint_fail_withdrawal_password'.tr(),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, fontFamily: Setting.appFont, color: Color(ColorTheme.errorText)),
                                )
                              : Container()
                        ],
                      )),
                      SizedBox(
                          height: gridItemHeight * 4,
                          width: gridItemWidth * 3,
                          child: ScrollConfiguration(
                            behavior: const ScrollBehavior().copyWith(overscroll: false),
                            child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 0, crossAxisSpacing: 0, childAspectRatio: 104 / 80),
                                itemCount: 12,
                                itemBuilder: (context, index) {
                                  if (index >= 0 && index <= 8 || index == 10) {
                                    int num = index == 10 ? 0 : index + 1;
                                    return numberWidget(num);
                                  }
                                  if (index == 9) {
                                    if (type == 2) {
                                      return fingerprintWidget();
                                    } else if (type == 3) {
                                      if (changePasswordStep == 0) {
                                        return fingerprintWidget();
                                      } else {
                                        return Container();
                                      }
                                    } else {
                                      return Container();
                                    }
                                  }

                                  if (index == 11) {
                                    return delWidget();
                                  }
                                }),
                          )),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Widget passwordWidget(int index) {
    Color color = Color(isInputPassword.elementAt(index) ? ColorTheme.c_19984b : ColorTheme.c_dbdbdb);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: index != currentIndex ? passwordBtnSizeDefault : passwordBtnSize.elementAt(index),
      height: index != currentIndex ? passwordBtnSizeDefault : passwordBtnSize.elementAt(index),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  void setOnPress(int index, bool value, {bool onTap = false}) async {
    if (value != onPress[index]) {
      setState(() {
        onPress[index] = value;
      });
      if (onTap) {
        await Future.delayed(const Duration(milliseconds: 50)).whenComplete(() => setOnPress(index, false));
      }
    }
  }

  Widget numberWidget(int num) {
    return GestureDetector(
      onTapDown: (_) {
        setOnPress(num, true);
      },
      onTapUp: (_) {
        setOnPress(num, false);
      },
      onTapCancel: () {
        setOnPress(num, false);
      },
      onTap: () async {
        setOnPress(num, true, onTap: true);
        if (getPassword.length < passwordLength) {
          if (currentIndex < passwordLength - 1) {
            setState(() {
              getPassword = getPassword + num.toString();
              currentIndex++;
              isInputPassword[currentIndex] = true;
              if (currentIndex < passwordLength) {
                passwordBtnSize[currentIndex] = passwordBtnSizeFocus;
                int tempIndex = currentIndex;
                Future.delayed(const Duration(milliseconds: 200), () {
                  setState(() {
                    passwordBtnSize[tempIndex] = passwordBtnSizeDefault;
                  });
                });
              }
            });
            if (currentIndex == passwordLength - 1) {
              if (type == 2) {
                // password check

                final withdrawPass = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? "";
                final withdrawPassTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? "";

                String password = AESHelper().decrypt(withdrawPass, withdrawPassTs);

                if (password == getPassword) {
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                } else {
                  setState(() {
                    failCheck = true;
                  });
                }
              } else if (type == 1) {
                // password create
                if (!recheckPassword) {
                  setRecheckPassword();
                } else {
                  if (savedPassword == getPassword) {
                    bool result = await setPassword(getPassword, getPassword);

                    if (mounted && result) {
                      CommonFunction.showToast(context, 'msg_success_create_password'.tr());

                      //Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.pushNamedAndRemoveUntil(context, Routes.mainPage, (route) => false));

                      Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.of(context).pop(true));
                    }
                  } else {
                    setState(() {
                      failCheck = true;
                    });
                  }
                }
              } else if (type == 3) {
                if (changePasswordStep == 0) {
                  oldPw = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPass) ?? "";
                  String oldTs = await CommonFunction.getPreferencesString(PreferenceKey.withdrawalPassTs) ?? "";

                  AESHelper aesHelper = AESHelper();

                  oldPw = aesHelper.decrypt(oldPw, oldTs);

                  if (oldPw == getPassword) {
                    changePasswordStep = 1;

                    setRecheckPassword();
                  } else {
                    setState(() {
                      failCheck = true;
                    });
                  }
                } else if (changePasswordStep == 1) {
                  changePasswordStep = 2;
                  setRecheckPassword();
                } else if (changePasswordStep == 2) {
                  if (savedPassword == getPassword) {
                    bool result = await setPassword(oldPw, getPassword);

                    if (mounted && result) {
                      CommonFunction.showToast(context, 'msg_success_change_password'.tr());

                      //Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.pushNamedAndRemoveUntil(context, Routes.mainPage, (route) => false));
                      Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.of(context).pop(true));
                    }
                  } else {
                    setState(() {
                      failCheck = true;
                    });
                  }
                }
              }
            }
          }
        }
      },
      child: Container(
        alignment: Alignment.center,
        color: onPress.elementAt(num) ? Theme.of(context).highlightColor : Colors.transparent,
        child: Text(
          num.toString(),
          style:
              TextStyle(fontSize: 24, fontWeight: FontWeight.w500, fontFamily: Setting.appFont, color: onPress.elementAt(num) ? const Color(ColorTheme.c_19984b) : const Color(ColorTheme.defaultText)),
        ),
      ),
    );
  }

  void backToFirstPassword() {
    setState(() {
      failCheck = false;
      recheckPassword = false;
      savedPassword = '';

      currentIndex = -1;
      getPassword = '';
      isInputPassword = List.generate(passwordLength, (index) => false);
    });
  }

  void setRecheckPassword() {
    setState(() {
      recheckPassword = true;
      savedPassword = getPassword;

      currentIndex = -1;
      getPassword = '';
      isInputPassword = List.generate(passwordLength, (index) => false);
    });
  }

  Widget delWidget() {
    int num = 11;
    return GestureDetector(
        onTapDown: (_) {
          setOnPress(num, true);
        },
        onTapUp: (_) {
          setOnPress(num, false);
        },
        onTapCancel: () {
          setOnPress(num, false);
        },
        onTap: () {
          setOnPress(num, true, onTap: true);
          if (getPassword.isNotEmpty) {
            if (!ingDel) {
              ingDel = true;
              setState(() {
                getPassword = getPassword.substring(0, getPassword.length - 1);
                isInputPassword[getPassword.length] = false;
                currentIndex--;
                if (currentIndex >= 0) {
                  passwordBtnSize[currentIndex] = passwordBtnSizeDefault;
                }
                failCheck = false;
              });
              ingDel = false;
            }
          }
        },
        child: Container(
          color: onPress.elementAt(num) ? Theme.of(context).highlightColor : Colors.transparent,
          child: Center(child: SvgPicture.asset(onPress.elementAt(num) ? 'images/icon_keypad_del_default_press.svg' : 'images/icon_keypad_del_default.svg')),
        ));
  }

  Widget fingerprintWidget() {
    int num = 10;
    return GestureDetector(
      onTapDown: (_) {
        setOnPress(num, true);
      },
      onTapUp: (_) {
        setOnPress(num, false);
      },
      onTapCancel: () {
        setOnPress(num, false);
      },
      onTap: () {
        setOnPress(num, true, onTap: true);
        if (type == 1) {
          // X
        } else if (type == 2) {
          checkBiometrics();
        } else if (type == 3) {
          if (changePasswordStep == 0) {
            checkBiometrics();
          }
        }
      },
      child: Container(
        color: onPress.elementAt(num) ? Theme.of(context).highlightColor : Colors.transparent,
        child: Center(
          child: SvgPicture.asset(onPress.elementAt(num) ? 'images/icon_fingerprint_default_press.svg' : 'images/icon_fingerprint_default.svg'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  Future<bool> setPassword(String oldPw, String newPw) async {
    loadingDialog.show();

    var manager = ApiManageHWalletCommon();

    dynamic json;

    try {
      json = await manager.setPass(oldPw: oldPw, pw: newPw);

      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        Map<String, String> getData = AESHelper().encrypt(newPw);

        await CommonFunction.setPreferencesString(PreferenceKey.withdrawalPass, getData['data']!);
        await CommonFunction.setPreferencesString(PreferenceKey.withdrawalPassTs, getData['iv']!);

        loadingDialog.hide();
        return true;
      } else {
        if (mounted) {
          CommonFunction.showInfoDialog(context, 'msg_fail_create_password'.tr());
        }
        loadingDialog.hide();
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        CommonFunction.showConnectErrorDialog(context, json);
      }
      loadingDialog.hide();
      return false;
    }
  }

  Future<bool> getPasswordApi(String pw) async {
    loadingDialog.show();

    var manager = ApiManageHWalletCommon();

    dynamic json;

    try {
      json = await manager.getPass(pw: pw);

      String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        loadingDialog.hide();
        return true;
      } else {
        if (mounted) {
          CommonFunction.showInfoDialog(context, 'hint_fail_withdrawal_password'.tr());
        }
        loadingDialog.hide();
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        CommonFunction.showConnectErrorDialog(context, json);
      }
      loadingDialog.hide();
      return false;
    }
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
