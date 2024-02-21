flutter clean
flutter pub get
cd ios
rm -rf ./Pods
rm -rf ./Podfile.lock
pod install 
/usr/bin/python3 /Users/sigmachain/Desktop/git/piki/ios.prepare.build.py
fastlane beta 