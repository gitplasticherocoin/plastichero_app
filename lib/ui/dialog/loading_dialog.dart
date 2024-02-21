//@@@
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';

class LoadingDialog {
  bool _isLoading = false;
  bool _isShow = false;
  BuildContext context;
  BuildContext? loadingContext;

  LoadingDialog({required this.context});

  void show() {
    if (!_isShow) {
      _isShow = true;
      print("context: $context");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          loadingContext = context;
          return const Loading();
        },
      ).whenComplete(() {
        _isShow = false;
      });

      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        _isLoading = true;
      });
    }
  }

  void hide() async {
    if (_isLoading) {
      if (loadingContext != null && loadingContext!.mounted) {
        _isLoading = false;
        Navigator.pop(loadingContext!);
        return;
      }
    } else if (_isShow) {
      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        hide();
      });
    }
  }
}

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoadingState();
  }
}

class _LoadingState extends State<Loading> {
  late int circle1;
  late int circle2;
  late int circle3;

  int topPosition = 0;

  Future<void> animationHandler() async {
    await Future.delayed(const Duration(milliseconds: 22)).then((value) {
      if (mounted) {
        setState(() {
          if (topPosition > 24) {
            topPosition = 0;
          } else {
            topPosition++;
          }

          if (topPosition == 0) {
            circle1 = 0;
            circle2 = 0;
            circle3 = 0;
          } else if (topPosition == 1) {
            circle1 = 1;
            circle2 = 0;
            circle3 = 0;
          } else if (topPosition == 2) {
            circle1 = 2;
            circle2 = 0;
            circle3 = 0;
          } else if (topPosition == 3) {
            circle1 = 3;
            circle2 = 0;
            circle3 = 0;
          } else if (topPosition == 4) {
            circle1 = 4;
            circle2 = 1;
            circle3 = 0;
          } else if (topPosition == 5) {
            circle1 = 5;
            circle2 = 2;
            circle3 = 0;
          } else if (topPosition == 6) {
            circle1 = 6;
            circle2 = 3;
            circle3 = 0;
          } else if (topPosition == 7) {
            circle1 = 7;
            circle2 = 4;
            circle3 = 1;
          } else if (topPosition == 8) {
            circle1 = 8;
            circle2 = 5;
            circle3 = 2;
          } else if (topPosition == 9) {
            circle1 = 7;
            circle2 = 6;
            circle3 = 3;
          } else if (topPosition == 10) {
            circle1 = 6;
            circle2 = 7;
            circle3 = 4;
          } else if (topPosition == 11) {
            circle1 = 5;
            circle2 = 8;
            circle3 = 5;
          } else if (topPosition == 12) {
            circle1 = 4;
            circle2 = 7;
            circle3 = 6;
          } else if (topPosition == 13) {
            circle1 = 3;
            circle2 = 6;
            circle3 = 7;
          } else if (topPosition == 14) {
            circle1 = 2;
            circle2 = 5;
            circle3 = 8;
          } else if (topPosition == 15) {
            circle1 = 1;
            circle2 = 4;
            circle3 = 7;
          } else if (topPosition == 16) {
            circle1 = 0;
            circle2 = 3;
            circle3 = 6;
          } else if (topPosition == 17) {
            circle1 = 0;
            circle2 = 2;
            circle3 = 5;
          } else if (topPosition == 18) {
            circle1 = 0;
            circle2 = 1;
            circle3 = 4;
          } else if (topPosition == 19) {
            circle1 = 0;
            circle2 = 0;
            circle3 = 3;
          } else if (topPosition == 20) {
            circle1 = 0;
            circle2 = 0;
            circle3 = 2;
          } else if (topPosition == 21) {
            circle1 = 0;
            circle2 = 0;
            circle3 = 1;
          } else if (topPosition == 22 || topPosition == 23 || topPosition == 24) {
            circle1 = 0;
            circle2 = 0;
            circle3 = 0;
          }

          if (mounted) {
            animationHandler();
          }
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    circle1 = 0;
    circle2 = 0;
    circle3 = 0;

    topPosition = 0;
    animationHandler();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        color: const Color(ColorTheme.dim),
        child: Center(
          child: AlertDialog(
            alignment: Alignment.center,
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: Container(
              alignment: Alignment.center,
              width: 119.0,
              height: 30.0,
              margin: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10.0,
                    height: 10.0,
                    margin: EdgeInsets.only(bottom: 2.5 * circle1),
                    decoration: BoxDecoration(
                      color: const Color(ColorTheme.appColor),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  Container(
                    width: 10.0,
                  ),
                  Container(
                    width: 10.0,
                    height: 10.0,
                    margin: EdgeInsets.only(bottom: 2.5 * circle2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  Container(
                    width: 10.0,
                  ),
                  Container(
                    width: 10.0,
                    height: 10.0,
                    margin: EdgeInsets.only(bottom: 2.5 * circle3),
                    decoration: BoxDecoration(
                      color: const Color(ColorTheme.c_dbdbdb),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
