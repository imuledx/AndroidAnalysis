#!/usr/bin/env bash

echo "[*] Enter the name describing your malware - for the operating folder: "
read folder

user=$(whoami)

mkdir /home/$user/android_analysis/malware

vhome () {
  cd /home/$user/android_analysis/malware
}

opshome () {
  cd /home/$user/android_analysis/malware/$folder
}

binhome () {
  cd /home/$user/android_analysis/malware/$folder/binaries
}

vhome
mkdir $folder
opshome
mkdir binaries

binhome
echo "[*]Put the malware in this directory:"
pwd

echo "[*]Press Enter when the malware is in place: "

read input
echo

ls > ../$folder.bins.ls

sha256sum * > ../sha256.$folder
mkdir ../apkinfos
cat ../$folder.bins.ls |while read line; do androapkinfo.py -i $line > ../apkinfos/$line.info.txt; done 
cat ../$folder.bins.ls |while read line; do unzip -e $line -d $line.unzip; done
cat ../$folder.bins.ls |while read line; do d2j-dex2jar $line.unzip/classes.dex -o $line.unzip/classes-dex2jar.jar; done
cat ../$folder.bins.ls |while read line; do androaxml.py -i $line.unzip/AndroidManifest.xml -o $line.unzip/manifest.out.xml; done
cwd=$(pwd)
cat ../$folder.bins.ls |while read line; do baksmali dis $cwd/$line.unzip/classes.dex -o $cwd/$line.unzip/out; done

mkdir ../strings.decoded
cat ../$folder.bins.ls |while read line; do grep -ir "const-string" $cwd/$line.unzip/out | cut -d "/" -f8- >> ../strings.decoded/$line.strings.txt; done

echo "[*] Goodbye"
 
