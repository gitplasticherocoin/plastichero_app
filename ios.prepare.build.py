sh_file = r"/Users/sigmachain/Desktop/git/plastichero_app/ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh"
old_str = r'source="$(readlink "${source}")"'
new_str = r'source="$(readlink -f "${source}")"'

def replace_in_file(file_path, old_str, new_str):
  fr = open(file_path, "r" , encoding="utf8")
  lines = fr.readlines()
  fr.close()

  fw = open(file_path, "w", encoding="utf8")
  for line in lines:
    fw.write(line.replace(old_str, new_str))
  fw.close()

replace_in_file(sh_file, old_str, new_str)