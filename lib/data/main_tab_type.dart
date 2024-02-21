

import 'package:plastichero_app/constants/setting.dart';

enum MainTabType {
  home('home',''),
  point('point',''),
  wallet('wallet',''),
  store('store',''),
  profile('profile',''),
  undefined('undefined','');

	const MainTabType(this.code, this.name);

	final String code;
	final String name;

	factory MainTabType.getByCode(String code) {
		return MainTabType.values.firstWhere((value) => value.code == code,
		orElse: () => MainTabType.undefined);
	}

	static int getIndex(String code) {

		if(code == MainTabType.home.code || code == "0" ) {
			return Setting.isUseWallet ? 0 : 0 ;
		}else if(code == MainTabType.point.code || code == "1") {
			return Setting.isUseWallet ? 1 : 1 ;
		}else if(code == MainTabType.wallet.code || code == "2") {
			return Setting.isUseWallet ? 2 : 0 ;
		} else if(code == MainTabType.store.code || code == "3") {
			return Setting.isUseWallet ? 3 : 2 ;
		}else if (code == MainTabType.profile.code || code == "4") {
			return Setting.isUseWallet ? 4 : 3 ;
		} else {
			return 0;
		}
	}
}