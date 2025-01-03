#!/bin/sh

###
# Check admin
##
#if [ $EUID -ne 0 ]; then
#   echo "This script must be run as root" 
#   exit 1
#fi

# Try sudo
sudo echo

export KT_WITH_UNKNOWN_DEVCODES="1"

# Fall back to the bundled KindleTool if there aren't any in PATH
KINDLETOOL="${PWD}/utils/kindletool"

###
# Cleanup previous build
###
rm -rf ./build ./build_tmp ./tmp_build_cache
mkdir ./build ./build_tmp ./build_cache

###
# Build native stuff
###
echo "* Building natives"
mkdir -p ./src/kmc/armel/lib/
mkdir -p ./src/kmc/armhf/lib/
mkdir -p ./src/kmc/armel/bin/
mkdir -p ./src/kmc/armhf/bin/

echo "* Building sh_integration..."
cd sh_integration
sh ./gen_crosscompile.sh
meson setup --cross-file kindlepw2.txt builddir_armel
meson setup --cross-file kindlehf.txt builddir_armhf
cd builddir_armel
meson compile
cd ..
cd builddir_armhf
meson compile
cd ../../
echo "* Copying sh_integration"
cp -f ./sh_integration/builddir_armel/extractor/sh_integration_extractor.so ./src/kmc/armel/lib/
cp -f ./sh_integration/builddir_armel/launcher/sh_integration_launcher ./src/kmc/armel/bin/
cp -f ./sh_integration/builddir_armhf/extractor/sh_integration_extractor.so ./src/kmc/armhf/lib/
cp -f ./sh_integration/builddir_armhf/launcher/sh_integration_launcher ./src/kmc/armhf/bin/

echo "* Building fbink..."
cd FBInk
make release KINDLE=1 DRAW=1 BITMAP=1 FONTS=1 IMAGE=1 OPENTYPE=1 INPUT=1 CROSS_TC="$HOME/x-tools/arm-kindlepw2-linux-gnueabi/bin/arm-kindlepw2-linux-gnueabi"
make strip KINDLE=1 DRAW=1 BITMAP=1 FONTS=1 IMAGE=1 OPENTYPE=1 INPUT=1 CROSS_TC="$HOME/x-tools/arm-kindlepw2-linux-gnueabi/bin/arm-kindlepw2-linux-gnueabi"
cp -f ./Release/fbink ../src/kmc/armel/bin/
cp -f ./Release/libfbink* ../src/kmc/armel/lib/
make clean
make release KINDLE=1 DRAW=1 BITMAP=1 FONTS=1 IMAGE=1 OPENTYPE=1 INPUT=1 CROSS_TC="$HOME/x-tools/arm-kindlehf-linux-gnueabihf/bin/arm-kindlehf-linux-gnueabihf"
make strip KINDLE=1 DRAW=1 BITMAP=1 FONTS=1 IMAGE=1 OPENTYPE=1 INPUT=1 CROSS_TC="$HOME/x-tools/arm-kindlehf-linux-gnueabihf/bin/arm-kindlehf-linux-gnueabihf"
cp -f ./Release/fbink ../src/kmc/armhf/bin/
cp -f ./Release/libfbink* ../src/kmc/armhf/lib/
cd ..

###
# Generate the updater_keys.sqsh file
# (Based on LanguageBreak hotfix build code from Marek)
###
echo "* Copying source to build dir"
cp -r ./src ./build_tmp/src

##echo "* Downloading official firmware from Amazon (Scribe)"
##if [ ! -f ./build_cache/update_kindle_scribe.bin ]; then
##   wget https://www.amazon.com/update_Kindle_Scribe -q -O ./build_cache/update_kindle_scribe.bin
##else
##   echo "* Official firmware found in cache - SKIPPING"
##fi
##
echo "* Downloading official firmware from Amazon (PW6)"
if [ ! -f ./build_cache/update_kindle_pw6.bin ]; then
   wget https://www.amazon.com/update_KindlePaperwhite_12th_Gen_2024 -q -O ./build_cache/update_kindle_pw6.bin
else
   echo "* Official firmware found in cache - SKIPPING"
fi
##
##echo "* Downloading official firmware from Amazon (PW5)"
##if [ ! -f ./build_cache/update_kindle_pw5.bin ]; then
##   wget https://www.amazon.com/update_Kindle_Paperwhite_11th_Gen -q -O ./build_cache/update_kindle_pw5.bin
##else
##   echo "* Official firmware found in cache - SKIPPING"
##fi

cp -r build_cache tmp_build_cache

echo "* Extracting and mounting official firmware"
${KINDLETOOL} extract ./build_cache/update_kindle_pw6.bin ./build_tmp/official_firmware
gunzip ./build_tmp/official_firmware/*rootfs*.img.gz
mkdir ./build_tmp/official_firmware_mnt/
sudo mount -o loop ./build_tmp/official_firmware/*rootfs*.img ./build_tmp/official_firmware_mnt/

echo "* Patching UKS SQSH"
mkdir ./build_tmp/patched_uks
mkdir ./build_tmp/mounted_sqsh
sudo mount -o loop ./build_tmp/official_firmware_mnt/etc/uks.sqsh ./build_tmp/mounted_sqsh
cp ./build_tmp/mounted_sqsh/* ./build_tmp/patched_uks/
sudo umount ./build_tmp/mounted_sqsh
sudo umount ./build_tmp/official_firmware_mnt/
cat > "./build_tmp/patched_uks/pubdevkey01.pem" << EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJn1jWU+xxVv/eRKfCPR9e47lP
WN2rH33z9QbfnqmCxBRLP6mMjGy6APyycQXg3nPi5fcb75alZo+Oh012HpMe9Lnp
eEgloIdm1E4LOsyrz4kttQtGRlzCErmBGt6+cAVEV86y2phOJ3mLk0Ek9UQXbIUf
rvyJnS2MKLG2cczjlQIDAQAB
-----END PUBLIC KEY-----
EOF
mksquashfs ./build_tmp/patched_uks ./build_tmp/src/mkk/updater_keys.sqsh

echo "* Generating device list"
#DEVICE_LIST="$(${KINDLETOOL} convert -i tmp_build_cache/update_kindle*.bin 2>&1 | grep -o "^Device .*" | grep -o "0x[[:xdigit:]]*" | tr "\n" " ")"
#echo $DEVICE_LIST

#DEVICES="$(echo "$DEVICE_LIST" | xargs | sed "s/ / -d /g")"
#echo $DEVICES

echo "* Building hotfix"
cd ./build_tmp/src
${KINDLETOOL} create ota2 -d kindle5 -s min -t max -O -C . "../../build/Update_hotfix_universal.bin"