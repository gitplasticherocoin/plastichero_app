import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plastichero_app/api/api_param_key.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/api/wallet/wallet_pth.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/constants/setting.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/provider/wallet_provider.dart';
import 'package:plastichero_app/routes.dart';
import 'package:plastichero_app/ui/widget/button_widget.dart';
import 'package:plastichero_app/ui/widget/swap/swap_wallet_list.dart';
import 'package:plastichero_app/ui/widget/text_widget.dart';
import 'package:plastichero_app/util/common_function.dart';

import 'package:provider/provider.dart';

int findDecimalPointPosition(String input) {
  int decimalPointIndex = input.indexOf('.');
  return decimalPointIndex != -1 ? input.length - decimalPointIndex - 1 : 0;
}

class SwapStartWidget extends StatefulWidget {
  final Function(WalletInfo wallet, double convertPTH, int convertRate) onNext;

  const SwapStartWidget({super.key, required this.onNext});

  @override
  State<SwapStartWidget> createState() => _SwapStartWidgetState();
}

class _SwapStartWidgetState extends State<SwapStartWidget> {
  final gkSwap = GlobalKey<FormState>();
  double convertPTH = 0;
  int convertedPoint = 0;
  int convertRate = 10;

  late TextEditingController _pthTextController;
  final FocusNode _pthFocusNode = FocusNode();

  List<WalletInfo> pthWalletInfoList = [];
  WalletInfo? selectedWallet;

  int _point = 0;
  String _maxSwap = "0.00";

  bool _isEnableConfirm = false;
  bool _isLoad = false;

  List<String> _descriptions = [];

  @override
  void initState() {
    super.initState();
    _pthTextController = TextEditingController();

    _pthTextController.text = "0";
    _pthFocusNode.addListener(() {
      // if(_pthTextController.text == "0" && convertPTH == -1 ) {
      //   _pthTextController.text = "0";
      // }else if(_pthTextController.text == "0" && convertPTH == 0 ) {
      // _pthTextController.text = "";
      // }
      if (convertPTH == 0) {
        _pthTextController.text = "";
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadData();
      getWalletList();
    });
  }

  @override
  void dispose() {
    _pthFocusNode.dispose();
    _pthTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isLoad,
      replacement: Container(
        height: 300,
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: CircularProgressIndicator(color: Color(ColorTheme.appColor)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text("swap.title".tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.0,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w500,
                  color: Color(ColorTheme.defaultText),
                )),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${"swap.point_enable_change_title".tr()} : ",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w600,
                      color: Color(ColorTheme.defaultText),
                    )),
                Text("${(_maxSwap)}  ${Setting.appSymbol}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      fontFamily: Setting.appFont,
                      fontWeight: FontWeight.w400,
                      color: Color(ColorTheme.defaultText),
                    )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text("swap.change_count".tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.0,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w500,
                        color: Color(ColorTheme.defaultText),
                      )),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(ColorTheme.c_ededed),
                        width: 1,
                      )),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: showWalletList,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 17, left: 16),
                          child: Row(
                            children: [
                              Text(selectedWallet?.name ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                    fontFamily: Setting.appFont,
                                    fontWeight: FontWeight.w500,
                                    color: Color(ColorTheme.defaultText),
                                  )),
                              const SizedBox(width: 8),
                              SvgPicture.asset("images/icon_textfield_down.svg", width: 14, height: 14),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Row(
                                children: [
                                  Text("amount_owned".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.0,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w400,
                                        color: Color(ColorTheme.defaultText),
                                      )),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Text("${(selectedWallet?.balance ?? "0.000000")}  ${Setting.appSymbol}",
                                  //"100 ${Setting.appSymbol}" ,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.0,
                                      fontFamily: Setting.appFont,
                                      fontWeight: FontWeight.w500,
                                      color: Color(ColorTheme.c_1e1e1e))),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      //   child: Container(
                      //     width: double.infinity,
                      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      //     decoration: BoxDecoration(
                      //       color: const Color(ColorTheme.c_ededed),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Text("00000000000${}",
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //         textAlign: TextAlign.right,
                      //         style: const TextStyle(
                      //
                      //           fontSize: 15,
                      //           height: 1.0 ,
                      //           fontFamily: Setting.appFont,
                      //           fontWeight: FontWeight.w500,
                      //           color: Color(ColorTheme.defaultText),
                      //         )
                      //     ),
                      //   ),
                      // )
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Form(
                          key: gkSwap,
                          child: InputTextField(
                            controller: _pthTextController,
                            focusNode: _pthFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            onSuffixIconTap: () {},
                            suffixIcon: const Text(Setting.appSymbol,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.0,
                                  fontFamily: Setting.appFont,
                                  fontWeight: FontWeight.w600,
                                  color: Color(ColorTheme.c_1e1e1e),
                                )),
                            onChanged: (value) {
                              checkTextField(value);
                            },
                            onSaved: (value) {
                              checkTextField(value!);
                            },
                            onEditingComplete: () {
                              CommonFunction.hideKeyboard(context);
                              checkTextField(_pthTextController.text);
                            },
                            onFieldSubmitted: (value) {
                              checkTextField(value);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(ColorTheme.c_19984b),
              ),
              child: Center(child: SvgPicture.asset("images/icon_change.svg", width: 20, height: 20)),
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text("swap.expect_price".tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.0,
                        fontFamily: Setting.appFont,
                        fontWeight: FontWeight.w500,
                        color: Color(ColorTheme.defaultText),
                      )),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(ColorTheme.c_ededed),
                        width: 1,
                      )),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 4),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Row(
                                children: [
                                  SvgPicture.asset("images/nav_menu_point.svg", width: 22, height: 22),
                                  const SizedBox(width: 8),
                                  Text("amount_owned".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.0,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w400,
                                        color: Color(ColorTheme.defaultText),
                                      )),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: _isLoad,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Text("${pointFormated(_point)} ${Setting.appCoin}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.0,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.c_1e1e1e))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(ColorTheme.c_ededed),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("${pointFormated(convertedPoint)} ${Setting.appCoin}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.0,
                                fontFamily: Setting.appFont,
                                fontWeight: FontWeight.w500,
                                color: Color(ColorTheme.defaultText),
                              )),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: _descriptions.length > 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(ColorTheme.c_f3f3f3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("* ${"notice".tr()}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.0,
                          fontFamily: Setting.appFont,
                          fontWeight: FontWeight.w500,
                          color: Color(ColorTheme.defaultText),
                        )),
                    const SizedBox(height: 5),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Visibility(
                          visible: _isLoad,
                          child: Column(
                            children: List.generate(
                                _descriptions.length, (index) => rowTextDescription(_descriptions[index])),
                          ),
                        )

                        // Text("- 교환 비율은 10P = 1PTH 입니다.\n- 플라스틱 수거함에 플라스틱을 넣어 얻은 PTH로만 포인트로 교환이 가능합니다.",
                        //                     maxLines: 3,
                        //                     overflow: TextOverflow.ellipsis,
                        //                     style: const TextStyle(
                        //                       fontSize: 12,
                        //                       height: 1.5 ,
                        //                       fontFamily: Setting.appFont,
                        //                       fontWeight: FontWeight.w400,
                        //                       color: Color(ColorTheme.defaultText),
                        //                     )
                        //                   ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: BtnBorderAppColor(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    text: "close".tr(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BtnFill(
                    isEnable: _isEnableConfirm,
                    onTap: () {
                      if (selectedWallet != null && convertPTH > 0 && _pthTextController.text !="") {
                        widget.onNext(selectedWallet!, convertPTH, convertRate);
                      }else {

                        setState(() {
                          _isEnableConfirm = false;
                        });

                      }
                    },
                    text: "next".tr(),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> showWalletList() async {
    final result = await showDialog(
        context: context,
        barrierColor: const Color(ColorTheme.dim),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SwapWalletList(
            pthWalletInfoList: pthWalletInfoList,
            selectedWallet: selectedWallet,
            onCancel: () {},
            onConfirm: () {},
          );
        });

    if (result != false) {
      setState(() {
        selectedWallet = result;
        _pthTextController.text = "0";
        convertPTH = 0;
        _isEnableConfirm = false;
      });
      loadWalletMaxPoint();
    }
  }

  void next() {}

  // PTH
  Future<void> getWalletList() async {
    String sessionCode = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";
    if (sessionCode.isEmpty) {
      return;
    }

    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      json = await manager.list();
      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        var result = json[ApiParamKey.result];

        List<WalletInfo> walletList = result.map<WalletInfo>((json) => WalletInfo.fromJson(json)).toList();
        if (pthWalletInfoList != walletList) {
          setState(() {
            pthWalletInfoList = walletList;
          });
        }

        if (mounted) {
          Provider.of<WalletProvider>(context, listen: false).setWalletInfoList(pthWalletInfoList: walletList);
        }

        if (pthWalletInfoList.isEmpty) {
          if (mounted) {
            Navigator.of(context).pop();

            CommonFunction.showToast(context, "msg_empty_wallet".tr());
            // 지갑 생성 페이지로 갈것
            //Navigator.of(context).pushNamed(Routes.walletCreatePage);
          }
        }
      } else {
        if (context.mounted) {
          await CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      for (var wallet in pthWalletInfoList) {
        if (wallet.isMain) {
          setState(() {
            selectedWallet = wallet;
          });

          break;
        }
      }
      selectedWallet ??= pthWalletInfoList.first;

      await loadWalletMaxPoint();
    }
  }

  Future<void> loadWalletMaxPoint() async {
    final code = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";

    setState(() {
      _isLoad = false;
    });

    final email = selectedWallet?.email;
    if (email == null) {
      return;
    }
    var manager = ApiManagerPTHWallet();
    dynamic json;
    try {
      json = await manager.getPoint(email: email!);
      final String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        final maxSwap = json['result'] ?? "0.00";
        setState(() {
          _maxSwap = maxSwap;
        });

      } else {
        if (context.mounted) {
          CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoad = true;
      });
    }
  }

  Future<void> loadData() async {
    final code = await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ?? "";

    setState(() {
      _isLoad = false;
    });
    var manager = ApiManagerMember();
    dynamic json;
    try {
      json = await manager.getPoint(type: 'get', code: code);
      final String status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        dynamic result = json['result'];

        final point = result['point'];
        //final maxSwap = json['result'] ?? "0.00";

        final rate = result['rate'] ?? 10;
        convertRate = rate;

        final List<String> desc = [
          "swap.desc1".tr(args: [convertRate.toString()]),
          "swap.desc2".tr()
        ];

        setState(() {
          _point = point;
          _descriptions = desc;
          _isLoad = true;
        });
      } else {
        if (context.mounted) {
          CheckResponse.checkErrorResponse(context, json);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoad = true;
      });
    }
  }

  String pointFormated(int point) {
    NumberFormat format = NumberFormat('#,###,###');
    return format.format(point);
  }

  void checkTextField(String value) {
    final input = value.trim();

    if (input.isEmpty) {
      setState(() {
        _isEnableConfirm = false;
      });
      return;
    } else {
      if (input == "0" || input == "0." || input =="") {
        setState(() {
          _isEnableConfirm = false;
        });
        return;
      }
      
      var numericValue = double.tryParse(input);
      print("numericValue : ${numericValue}");
      if (numericValue != null) {
        var roundedValue = double.parse(numericValue.toStringAsFixed(1));

        if (roundedValue == 0.0) {
          _pthTextController.text = "0";
          convertPTH = 0;
          setState(() {
            _isEnableConfirm = false;
          });
          return;
        } else if (roundedValue != numericValue) {
          _pthTextController.text = roundedValue.toString();
          _pthTextController.selection = TextSelection.fromPosition(
            TextPosition(offset: _pthTextController.text.length),
          );
        }

        // if (roundedValue > double.parse(_maxSwap)) {
        //   roundedValue = double.parse(_maxSwap);
        // }
        convertPTH = roundedValue;
        int converted = 0;
        if (convertPTH > 0) {
          converted = (convertPTH * convertRate.toDouble()).toInt();
        } else {
          converted = 0;
        }
        setState(() {
          convertedPoint = converted;
        });
      } else {
        _pthTextController.text = "0";
        convertPTH = 0;
        setState(() {
          _isEnableConfirm = false;
        });
      }
    }

    //final balance = double.parse(selectedWallet?.balance ?? "0");

    if (convertPTH > double.parse(_maxSwap) ) {
      print("_maxSwap : $_maxSwap}");
      print("converPTH : ${convertPTH}");
      setState(() {
        _isEnableConfirm = false;
      });
    } else {
      print("_maxSwap : ${_maxSwap}");
      print("converPTH : ${convertPTH}");
      setState(() {
        _isEnableConfirm = true;
      });
    }
  }

  Widget rowTextDescription(String description) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32 - 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text("- ",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.0,
                    fontFamily: Setting.appFont,
                    fontWeight: FontWeight.w400,
                    color: Color(ColorTheme.defaultText),
                  )),
            ),
            Expanded(
              child: Text(description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    fontFamily: Setting.appFont,
                    fontWeight: FontWeight.w400,
                    color: Color(ColorTheme.defaultText),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
