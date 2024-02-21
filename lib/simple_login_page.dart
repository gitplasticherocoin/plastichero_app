import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plastichero_app/constants/common.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SimpleLoginPage extends StatefulWidget {
  const SimpleLoginPage({Key? key}) : super(key: key);

  @override
  State<SimpleLoginPage> createState() => _SimpleLoginPageState();
}

class _SimpleLoginPageState extends State<SimpleLoginPage> {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  @override
  void initState() {
    super.initState();
    // FirebaseAuth.instance.authStateChanges().listen((event) {
    //   if(event == null) {
    //
    //
    //
    //   }else {
    //
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Simple login")),
      body: SafeArea(
        // child: StreamBuilder(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: (context, AsyncSnapshot<User?> user) {
        //     if(user.hasData) {
        //       return Container(
        //         child: Text("main"),
        //       );
        //     }else {
        //       return GestureDetector(
        //         onTap: signWithGoogle,
        //         child: Card(
        //           child: Text("구글 로그인")
        //         )
        //       );
        //     }
        //   }),
          child: Visibility(
            visible: _loginPlatform == LoginPlatform.none,
            replacement: Container(
              child: GestureDetector(
                onTap: signOut,
                child: Card(
                  child: Text("로그아웃"),
                )
              )
            ),
            child: Container(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: signWithGoogle,
                    child: Card(
                      child: Text("구글로그인"),
                    ),
                  ),

                  GestureDetector(
                    onTap: signWithApple,
                    child: Card(
                      child: Text("애플로그인"),
                    ),
                  ),
                  GestureDetector(
                    onTap: signWithNaver,
                    child: Card(
                      child: Text("네이버로그인"),
                    ),
                  ),
                  GestureDetector(
                    onTap: signWithNaver,
                    child: Card(
                      child: Text("구글로그인"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Future<void> signOut() async {
    switch(_loginPlatform) {
      case LoginPlatform.apple:
        break;
      case LoginPlatform.naver:
        await FlutterNaverLogin.logOut();
        break;
      case LoginPlatform.google:
        await GoogleSignIn().signOut();
        break;
      default:
        break;
    }
    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  Future<void> signWithApple() async {
    try {
      final scopes = <AppleIDAuthorizationScopes>[
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ];
      final AuthorizationCredentialAppleID credential = await SignInWithApple
          .getAppleIDCredential(scopes: scopes,
          webAuthenticationOptions: WebAuthenticationOptions(
              clientId: "app.plastichero.com",
              redirectUri: Uri.parse(
                  "https://airy-frill-waterlily.glitch.me/callbacks/sign_in_with_apple")));
      print('credential.state = ${credential.state}');
      print('credential.email = ${credential.email}');
      print('credential.userIdentifier = ${credential.userIdentifier}');
      print('credential.givenName = ${credential.givenName}');
      print('credential.familyName = ${credential.familyName}');

      setState(() {
        _loginPlatform = LoginPlatform.apple;
      });

    }catch (error) {
      print("error = $error");
    }
  }
  Future<void> signWithNaver() async {
    final NaverLoginResult result = await FlutterNaverLogin.logIn();
    if(result.status == NaverLoginStatus.loggedIn) {
      print("accessToken : ${result.accessToken}");
      print("id : ${result.account.id}");
      print("email : ${result.account.email}");
      print("name : ${result.account.name}");

      setState(() {
        _loginPlatform = LoginPlatform.naver;
      });
    }
  }

  Future<void> signWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if(googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');
      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
    }
    // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    //
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
