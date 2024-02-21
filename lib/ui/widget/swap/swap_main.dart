import 'package:flutter/material.dart';
import 'package:plastichero/api/api_param_key.dart';
import 'package:plastichero/ui/dialog/loading_dialog.dart';
import 'package:plastichero_app/api/member/check_response.dart';
import 'package:plastichero_app/provider/myinfo_provider.dart';
import 'package:plastichero_app/util/common_function.dart';
import 'package:plastichero_app/api/member/api_manager_member.dart';
import 'package:plastichero_app/constants/preference_key.dart';
import 'package:plastichero_app/data/wallet_info.dart';
import 'package:plastichero_app/ui/widget/swap/swap_confirm.dart';
import 'package:plastichero_app/ui/widget/swap/swap_done.dart';
import 'package:plastichero_app/ui/widget/swap/swap_password.dart';
import 'package:plastichero_app/ui/widget/swap/swap_start.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:provider/provider.dart';

enum SwapSteps { start, confirm, password, done }

class SwapMainWidget extends StatefulWidget {
  final VoidCallback onShowList;

  const SwapMainWidget({super.key, required this.onShowList});

  @override
  State<SwapMainWidget> createState() => _SwapMainWidgetState();
}

class _SwapMainWidgetState extends State<SwapMainWidget> {
  SwapSteps _steps = SwapSteps.start;
  WalletInfo? selectedWalletInfo;
  double convertPTH = 0;
  int convertRate = 10;
  String _password = "";
  MyinfoProvider? myInfoPovider;
  late final LoadingDialog loadingDialog;

  @override
  void initState() {
    super.initState();
    myInfoPovider = Provider.of<MyinfoProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadingDialog = LoadingDialog(context: context);
    });
  }

  @override
  void dispose() {
    myInfoPovider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_steps) {
      case SwapSteps.start:
        return SwapStartWidget(
            onNext: (WalletInfo wallet, double cPTH, int cRate) {
          setState(() {
            selectedWalletInfo = wallet;
            convertPTH = cPTH;
            convertRate = cRate;

            _steps = SwapSteps.confirm;
          });
        });
      case SwapSteps.confirm:
        return SwapConfirmWidget(
            convertPTH: convertPTH,
            walletInfo: selectedWalletInfo!,
            convertRate: convertRate,
            onNext: () {
              setState(() {
                _steps = SwapSteps.password;
              });
            });
      case SwapSteps.password:
        return SwapPasswordWidget(onNext: (String pw) {
          _password = pw;
          doSwap();
        });
      case SwapSteps.done:
        return SwapDoneWidget(
            convertPTH: convertPTH,
            walletInfo: selectedWalletInfo!,
            convertRate: convertRate,
            onCancel: widget.onShowList,
            onNext: () {
              Navigator.of(context).pop();
            });
      default:
        return const SizedBox(height: 0);
    }
  }

  Future<void> doSwap() async {
    final code =
        await CommonFunction.getPreferencesString(PreferenceKey.sessionCode) ??
            "";

    final idx = selectedWalletInfo?.idx.toString() ?? "";

    if (idx == "" && convertPTH > 0) {
      return;
    }

    var manager = ApiManagerMember();
    dynamic json;
    try {
      loadingDialog.show();
      json = await manager.swap(
          code: code, pw: _password, pth: convertPTH.toString(), idx: idx);

      final status = json[ApiParamKey.status];
      if (status == ApiParamKey.success) {
        myInfoPovider?.callRefresh();
        setState(() {
          _steps = SwapSteps.done;
        });
        loadingDialog.hide();
      } else {
        loadingDialog.hide();
        if (context.mounted) {
          CheckResponse.checkErrorResponse(context, json , isToast: true);
        }
      }
    } catch (e) {
      loadingDialog.hide();
      Debug.log("log", e.toString());
    }
  }
}
