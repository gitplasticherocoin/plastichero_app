import yaml
import os 
import shutil
from time import sleep

# 명령어 python .\android.local.release.py

# os.system("start .")

os.system("flutter build apk --release ")
project_path = os.getcwd()
pubspec_file = project_path + r"\pubspec.yaml"
with open(pubspec_file) as f:
    pubspec = yaml.load(f,Loader=yaml.FullLoader)
    get_version = pubspec['version']

temp = get_version.split("+")
version="v" + temp[0]
print(version)

curret_directory = os.getcwd()
print(curret_directory)


android_network_directory = r'\\192.168.100.100\sigmachain_share\public\10_Project\PlasticHero\release\App'
# os.chdir(android_network_directory)

curret_directory = os.getcwd()
print(curret_directory)

path = os.path.join(android_network_directory, version)
os.mkdir(path)


# 원본 apk 파일경로
filename_source = "app-release.apk"
filename_dest = "ph_" + version + ".apk"
sour_dir = project_path + r'\build\app\outputs\apk\release'

sour=os.path.join(sour_dir, filename_source)
dest=os.path.join(path, filename_dest)
shutil.move(sour, dest )
sleep(1)
os.system("flutter build appbundle")
print("done")
sleep(1)
# mapping 폴더 경로
mapping_folder_name_source = "mapping"
mapping_sour_dir= project_path +  r'\build\app\outputs'

mapping_sour=os.path.join(mapping_sour_dir, mapping_folder_name_source)
mapping_dest=os.path.join(path, mapping_folder_name_source)
shutil.move(mapping_sour, mapping_dest )

# 원본 aab 파일경로
aab_filename_source = "app-release.aab"
aab_filename_dest = "pth_" + version + ".aab"
aab_sour_dir= project_path + r'\build\app\outputs\bundle\release'

aab_sour=os.path.join(aab_sour_dir, aab_filename_source)
aab_dest=os.path.join(path, aab_filename_dest)
shutil.move(aab_sour, aab_dest )