import os
import yaml

pubspec_file = r"/Users/sigmachain/Desktop/git/plastichero_app/pubspec.yaml"
setting_filepath = r"/Users/sigmachain/Desktop/git/plastichero_app/lib/constants/setting.dart"
with open(pubspec_file) as f:
    pubspec = yaml.load(f,Loader=yaml.FullLoader)
    get_version = pubspec['version']
print(get_version)
proceed = input("Do you want proceed? [y/n]")

if proceed == "y": 
    fin = open(setting_filepath, "r", encoding="utf8")
    find_is_test = False 
    for line in fin:
        strings = line.split("=")
        if strings[0].strip() == "static const bool isTest":
            find_is_test = True
            value = strings[1].strip().replace(";","")
            if value == "false":
                print("RELEASE VERSION")
                os.system("./ios.build.sh")
            elif value == "true":
                print("TEST VERSION")
                os.system("./ios.build.sh")

    if find_is_test == False :
        print("Check settings.dart file")
