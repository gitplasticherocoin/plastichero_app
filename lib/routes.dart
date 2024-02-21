import 'package:flutter/cupertino.dart';

import 'package:plastichero_app/ui/page/account_link_select.dart';
import 'package:plastichero_app/ui/page/account_link_start.dart';
import 'package:plastichero_app/ui/page/amount_setting_page.dart';
import 'package:plastichero_app/ui/page/article_page.dart';
import 'package:plastichero_app/ui/page/change_email_page.dart';
import 'package:plastichero_app/ui/page/change_phone_page.dart';
import 'package:plastichero_app/ui/page/change_wallet_password_page..dart';
import 'package:plastichero_app/ui/page/deposit_page.dart';
import 'package:plastichero_app/ui/page/find_id_page.dart';
import 'package:plastichero_app/ui/page/get_wallet_page.dart';
import 'package:plastichero_app/ui/page/input_password.dart';
import 'package:plastichero_app/ui/page/intro_page.dart';
import 'package:plastichero_app/ui/page/login_page.dart';
import 'package:plastichero_app/ui/page/main_page.dart';
import 'package:plastichero_app/ui/page/masterkey_page.dart';
// import 'package:plastichero_app/ui/page/my_mnemonic.dart';
// import 'package:plastichero_app/ui/page/my_mnemonic_recheck_page.dart';
import 'package:plastichero_app/ui/page/myinfo_page.dart';
import 'package:plastichero_app/ui/page/otp_auth_page.dart';
import 'package:plastichero_app/ui/page/password_change_page.dart';
import 'package:plastichero_app/ui/page/property_detail_page.dart';
import 'package:plastichero_app/ui/page/qr_scan_page.dart';
import 'package:plastichero_app/ui/page/safe_use_guide_page.dart';

import 'package:plastichero_app/ui/page/signout_done_page.dart';
import 'package:plastichero_app/ui/page/signout_page.dart';
import 'package:plastichero_app/ui/page/signup_done_page.dart';
import 'package:plastichero_app/ui/page/signup_id_page.dart';
import 'package:plastichero_app/ui/page/signup_page.dart';
import 'package:plastichero_app/ui/page/signup_phone_page.dart';
import 'package:plastichero_app/ui/page/signup_sms_page.dart';
import 'package:plastichero_app/ui/page/transaction_detail_page.dart';
import 'package:plastichero_app/ui/page/wallet_create_page.dart';
//import 'package:plastichero_app/ui/page/wallet_import_bpth_page.dart';
import 'package:plastichero_app/ui/page/wallet_import_page.dart';
import 'package:plastichero_app/ui/page/wallet_management_page.dart';
import 'package:plastichero_app/ui/page/web_page.dart';
import 'package:plastichero_app/ui/page/welcome_page.dart';
// import 'package:plastichero_app/ui/page/web_page.dart';
// import 'package:plastichero_app/ui/page/welcome_page.dart';
import 'package:plastichero_app/ui/page/welcome_to_bpth_wallet_page.dart';
import 'package:plastichero_app/ui/page/withdrawal_complete_page.dart';
import 'package:plastichero_app/ui/page/withdrawal_page.dart';
import 'package:plastichero_app/ui/page/withdrawal_password.dart';

class Routes {
  Routes._();

  static const String introPage = "/introPage";
  static const String loginPage = "/loginPage";
  static const String mainPage = "/mainPage";
  static const String signupPage = "/signupPage";
  static const String articlePage = "/articlePage";
  static const String signupPhonePage = "/signupPhonePage";
  static const String signupIdPage = "/singupIdPage";
  static const String signupDonePage = "/singupDonePage";
  static const String findIdPage = "/findIdPage";
  static const String passwordChangePage = "/passwordChangePage";
  static const String signOutPage = "/signOutPage";
  static const String signOutDonePage = "/signOutDonePage";
  static const String changeEmailPage = "/changeEmailPage";
  static const String changePhonePage = "/changePhonePage";
  static const String changeWalletPasswordPage = "/changeWalletPasswordPage";
  static const String myInfoPage = "/myInfoPage";
  static const String transactionDetailPage = "/transactionDetailPage";
  static const String myMnemonicPage = "/myMnemonicPage";
  static const String safeUseGuidePage = "/safeUseGuidePage";
  static const String myMnemonicRecheckPage = "/myMnemonicRecheckPage";
  static const String walletManagementPage = "/walletManagementPage";
  static const String walletCreatePage = "/walletCreatePage";
  static const String walletImportPage = "/walletImportPage";
  static const String withdrawalPasswordPage = '/withdrawalPasswordPage';
  static const String depositPage = "/depositPage";
  static const String amountSettingPage = "/amountSettingPage";
  static const String withdrawalPage = "/withdrawalPage";
  static const String qrScanPage = "/qrScanPage";
  static const String withdrawalCompletePage = "/withdrawalCompletePage";
  static const String welcomeTobPTHWalletPage = "/welcomeTobPTHWalletPage";
  static const String propertyDetailPage = "/propertyDetailPage";
  static const String getWalletPage = '/getWalletPage';
  static const String walletImportBPTHPage = '/walletImportBPTHPage';
//  static const String realnamePage = "/realnamePage";
  static const String signupSmsPage = "/signupSmsPage";
  static const String accountLinkStart = "/accountLinkStart";
  static const String accountLinkSelect = "/accountLinkSelect";
  static const String otpAuthPage = "/otpAuthPage";
  static const String masterKeyPage = "/masterKey";
  static const String inputPasswordPage = "/inputPassword";
  static const String welcomePage = "/welcomPage";
  static const String webPage = "/webPage";


  static final routes = <String, WidgetBuilder>{
    introPage: (BuildContext context) => const IntroPage(),
    loginPage: (BuildContext context) => const LoginPage(),
    mainPage: (BuildContext context) => MainPage(),
    signupPage: (BuildContext context) => const SignupPage(),
    articlePage: (BuildContext context) => const ArticlePage(),
    signupPhonePage: (BuildContext context) => const SignUpPhonePage(),
    signupIdPage: (BuildContext context) => const SignUpIdPage(),
    signupDonePage: (BuildContext context) => const SignUpDonePage(),
    accountLinkStart: (BuildContext context) => const AccountLinkStart(),
    accountLinkSelect: (BuildContext context) => const AccountLinkSelect(),
    findIdPage: (BuildContext context) => const FindIdPage(),
    passwordChangePage: (BuildContext context) => const PasswordChangePage(),
    signOutPage: (BuildContext context) => const SignOutPage(),
    signOutDonePage: (BuildContext context) => const SignOutDonePage(),
    changeEmailPage: (BuildContext context) => const ChangeEmailPage(),
    changePhonePage: (BuildContext context) => const ChangePhonePage(),
    changeWalletPasswordPage: (BuildContext context) => const ChangeWalletPasswordPage(),
    myInfoPage: (BuildContext context) => const MyInfoPage(),
    // realnamePage: (BuildContext context) => const RealnamePage(),
    signupSmsPage: (BuildContext context) => const SignupSmsPage(),
    transactionDetailPage: (BuildContext context) => const TransactionDetailPage(),
    // myMnemonicPage: (BuildContext context) => const MyMnemonicPage(),
    safeUseGuidePage: (BuildContext context) => const SafeUseGuidePage(),
    // myMnemonicRecheckPage: (BuildContext context) => const MyMnemonicRecheckPage(),
    withdrawalPasswordPage: (BuildContext context) => const WithdrawalPassword(),
    walletManagementPage: (BuildContext context) => const WalletManagementPage(),
    walletCreatePage: (BuildContext context) => const WalletCreatePage(),
    walletImportPage: (BuildContext context) => const WalletImportPage(),
    // walletImportBPTHPage: (BuildContext context) => const WalletImportBPTHPage(),
    depositPage: (BuildContext context) => const DepositPage(),
    amountSettingPage: (BuildContext context) => const AmountSettingPage(),
    withdrawalPage: (BuildContext context) => const WithdrawalPage(),
    qrScanPage: (BuildContext context) => const QrScanPage(),
    withdrawalCompletePage: (BuildContext context) => const WithdrawalCompletePage(),
    welcomeTobPTHWalletPage: (BuildContext context) => const WelcomeTobPTHWalletPage(),
    welcomePage : (BuildContext context) => const WelcomePage(),
    propertyDetailPage: (BuildContext context) => const PropertyDetailPage(),
    getWalletPage: (BuildContext context) => const GetWalletPage(),
    otpAuthPage: (BuildContext context) => const OtpAuthPage(),
    masterKeyPage : (BuildContext context) => const MasterKeyPage(),
    inputPasswordPage: (BuildContext context) => const InputPasswordPage(),
    webPage: (BuildContext context) => const WebPage(),
  };
}

