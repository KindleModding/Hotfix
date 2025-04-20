#!/bin/sh

###
# Check admin
##
#if [ $EUID -ne 0 ]; then
#   echo "This script must be run as root" 
#   exit 1
#fi

set -e

# Try sudo
sudo echo

export HAKT_VERSION="v2.0.0-DEV"
export KT_WITH_UNKNOWN_DEVCODES="1"

# Fall back to the bundled KindleTool if there aren't any in PATH
KINDLETOOL="${PWD}/utils/kindletool"

###
# Cleanup previous build
###
sudo rm -rf ./build ./build_tmp ./tmp_build_cache
mkdir -p ./build ./build_tmp ./build_cache

###
# Build native stuff
###
echo "* Building natives"
rm -rf ./src/kmc/armel/lib/
rm -rf ./src/kmc/armhf/lib/
rm -rf ./src/kmc/armel/bin/
rm -rf ./src/kmc/armhf/bin/
rm -rf ./src/kmrp/armel
rm -rf ./src/kmrp/armhf

mkdir -p ./src/kmc/armel/lib/
mkdir -p ./src/kmc/armhf/lib/
mkdir -p ./src/kmc/armel/bin/
mkdir -p ./src/kmc/armhf/bin/
mkdir -p ./src/kmrp/armel
mkdir -p ./src/kmrp/armhf

echo "* Building KMRP..."
pushd kindle_modding_recovery_project
   meson setup --cross-file ~/x-tools/arm-kindlepw2-linux-gnueabi/meson-crosscompile.txt builddir_armel
   meson setup --cross-file ~/x-tools/arm-kindlehf-linux-gnueabihf/meson-crosscompile.txt builddir_armhf
   meson compile -C builddir_armel
   meson compile -C builddir_armhf
popd
echo "* Copying KMRP"
for ARCH in armel armhf
do
   cp -f "./kindle_modding_recovery_project/builddir_${ARCH}/src/kmrp" "./src/kmrp/${ARCH}/"
   cp -f "./kindle_modding_recovery_project/builddir_${ARCH}/subprojects/fbink/libfbink_input.so" "./src/kmrp/${ARCH}/"
   cp -f "./kindle_modding_recovery_project/builddir_${ARCH}/subprojects/libevdev/libevdev.so.2.3.0" "./src/kmrp/${ARCH}/libevdev.so.2.3.0"
   cp -f "./kindle_modding_recovery_project/builddir_${ARCH}/subprojects/libevdev/libevdev.so.2.3.0" "./src/kmrp/${ARCH}/libevdev.so.2"
   cp -f "./kindle_modding_recovery_project/builddir_${ARCH}/subprojects/libevdev/libevdev.so.2.3.0" "./src/kmrp/${ARCH}/libevdev.so"
done

echo "* Building sh_integration..."
pushd sh_integration
   meson setup --cross-file ~/x-tools/arm-kindlepw2-linux-gnueabi/meson-crosscompile.txt builddir_armel
   meson setup --cross-file ~/x-tools/arm-kindlehf-linux-gnueabihf/meson-crosscompile.txt builddir_armhf
   meson compile -C builddir_armel
   meson compile -C builddir_armhf
popd
echo "* Copying sh_integration"
for ARCH in armel armhf
do
   cp -f "./sh_integration/builddir_${ARCH}/extractor/sh_integration_extractor.so" "./src/kmc/${ARCH}/lib/"
   cp -f "./sh_integration/builddir_${ARCH}/launcher/sh_integration_launcher" "./src/kmc/${ARCH}/bin/"
done

echo "* Building fbink..."
cp -rf ./utils/fbink_patch/* ./FBInk/
pushd FBInk
   meson setup --cross-file ~/x-tools/arm-kindlepw2-linux-gnueabi/meson-crosscompile.txt builddir_armel -Dtarget=Kindle -Dbitmap=enabled -Ddraw=enabled -Dfonts=enabled -Dimage=enabled -Dinputlib=enabled -Dopentype=enabled -Dfbink=enabled -Dinput_scan=enabled -Dfbdepth=enabled
   meson setup --cross-file ~/x-tools/arm-kindlehf-linux-gnueabihf/meson-crosscompile.txt builddir_armhf -Dtarget=Kindle -Dbitmap=enabled -Ddraw=enabled -Dfonts=enabled -Dimage=enabled -Dinputlib=enabled -Dopentype=enabled -Dfbink=enabled -Dinput_scan=enabled -Dfbdepth=enabled
   meson compile -C builddir_armel
   meson compile -C builddir_armhf
popd
echo "* Copying FBInk"
for ARCH in armel armhf
do
   cp -f "./FBInk/builddir_${ARCH}/libfbink_input.so" "./src/kmc/${ARCH}/lib/"
   cp -f "./FBInk/builddir_${ARCH}/libfbink.so" "./src/kmc/${ARCH}/lib/"
   cp -f "./FBInk/builddir_${ARCH}/input_scan" "./src/kmc/${ARCH}/bin/"
   cp -f "./FBInk/builddir_${ARCH}/fbink" "./src/kmc/${ARCH}/bin/"
   cp -f "./FBInk/builddir_${ARCH}/fbdepth" "./src/kmc/${ARCH}/bin/"
done

###
# Generate the updater_keys.sqsh file
# (Based on LanguageBreak hotfix build code from Marek)
###
echo "* Copying source to build dir"
cp -r ./src ./build_tmp/src

echo "* Downloading official firmware from Amazon (PW6)"
if [ ! -f ./build_cache/update_kindle_pw6.bin ]; then
   wget https://www.amazon.com/update_KindlePaperwhite_12th_Gen_2024 -q -O ./build_cache/update_kindle_pw6.bin
else
   echo "* Official firmware found in cache - SKIPPING"
fi

cp -r build_cache tmp_build_cache

echo "* Extracting and mounting official firmware"
${KINDLETOOL} extract ./build_cache/update_kindle_pw6.bin ./build_tmp/official_firmware
gunzip ./build_tmp/official_firmware/*rootfs*.img.gz
mkdir ./build_tmp/official_firmware_mnt/
sudo mount -o loop ./build_tmp/official_firmware/*rootfs*.img ./build_tmp/official_firmware_mnt/

echo "* Patching UKS SQSH"
mkdir ./build_tmp/patched_uks
mkdir ./build_tmp/mounted_sqsh
if [ -e  ./build_tmp/official_firmware_mnt/etc/uks.sqsh ]; then
   sudo mount -o loop ./build_tmp/official_firmware_mnt/etc/uks.sqsh ./build_tmp/mounted_sqsh
else
   sudo cp -r ./build_tmp/official_firmware_mnt/etc/uks/* ./build_tmp/mounted_sqsh/
fi

cp ./build_tmp/mounted_sqsh/* ./build_tmp/patched_uks/
if [ -e  ./build_tmp/official_firmware_mnt/etc/uks.sqsh ]; then
   sudo umount ./build_tmp/mounted_sqsh
fi
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

echo "* Packing persistent storage folders"
tar -cf ./build_tmp/src/kmc.tar -C ./build_tmp/src/kmc/ .
tar -cf ./build_tmp/src/mkk.tar -C ./build_tmp/src/mkk/ .
rm -rf ./build_tmp/src/kmc
rm -rf ./build_tmp/src/mkk

echo "* Generating device list"
#DEVICE_LIST="$(${KINDLETOOL} convert -i tmp_build_cache/update_kindle*.bin 2>&1 | grep -o "^Device .*" | grep -o "0x[[:xdigit:]]*" | tr "\n" " ")"
#echo $DEVICE_LIST

#DEVICES="$(echo "$DEVICE_LIST" | xargs | sed "s/ / -d /g")"
#echo $DEVICES

echo "* Building HAKT"
cd ./build_tmp/src
${KINDLETOOL} create ota2 -d kindle5 -s min -t max -O -C . "../../build/Update_HAKT_${HAKT_VERSION}_install.bin"