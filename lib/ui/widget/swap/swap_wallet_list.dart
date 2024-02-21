import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';

import '../../../data/wallet_info.dart';
import '../button_widget.dart';

class SwapWalletList extends StatefulWidget {
  final List<WalletInfo>? pthWalletInfoList;
  final WalletInfo? selectedWallet;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const SwapWalletList({super.key,
  this.pthWalletInfoList ,
  this.selectedWallet,
  this.onCancel,
  this.onConfirm});

  @override
  State<SwapWalletList> createState() => _SwapWalletListState();
}

class _SwapWalletListState extends State<SwapWalletList> {


  WalletInfo? selected;

  @override
  void initState() {
    super.initState();

    selected = widget.selectedWallet;

  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width  - 57,
        height: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text("swap.wallet_select_title".tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.0 ,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w600,
                  color: Color(ColorTheme.defaultText),
                )
            ),
            const SizedBox(height: 5),
            Text("swap.wallet_select_subtitle".tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.0 ,
                  fontFamily: Setting.appFont,
                  fontWeight: FontWeight.w400,
                  color: Color(ColorTheme.defaultText),
                )
            ),

            const SizedBox(height:12),
            Expanded(child: Container(
              color: Colors.white,
              child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: ListView.builder(
                    itemCount: widget.pthWalletInfoList?.length ?? 0,
                    itemBuilder: (context, i) {

                      final wallet = widget.pthWalletInfoList![i];



                      return GestureDetector(
                        onTap: () {
                          setState(() {
                           selected = wallet;
                          });

                          print(selected);


                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              Row(
                                children: [

                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Stack(
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: const Color(ColorTheme.c_dbdbdb)
                                                )

                                            )
                                        ),
                                        if( selected?.idx == wallet.idx)
                                          Center(
                                            child: Container(
                                              width: 12,
                                              height:  12,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(ColorTheme.appColor)
                                              ),
                                            ),
                                          )


                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(wallet.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.0 ,
                                        fontFamily: Setting.appFont,
                                        fontWeight: FontWeight.w500,
                                        color: Color(ColorTheme.defaultText),
                                      )
                                  ),

                                ],
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top:14, left: 16, right: 16, bottom : 13),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(ColorTheme.c_ededed),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("amount_owned".tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.0 ,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w400,
                                          color: Color(ColorTheme.c_767676),
                                        )
                                    ),
                                    const SizedBox(height: 3,),
                                    Text("${wallet.balance} ${Setting.appSymbol}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.0 ,
                                          fontFamily: Setting.appFont,
                                          fontWeight: FontWeight.w400,
                                          color: Color(ColorTheme.c_1e1e1e),
                                        )
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                ),
              ),
            )),
            const SizedBox(height:20),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: BtnBorderAppColor(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      text: "cancel".tr(),
                    )),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child:
                  BtnFill(
                      onTap: () {
                        Navigator.of(context).pop(selected);
                      },
                      text: "confirm".tr()),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
