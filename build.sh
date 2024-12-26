#!/usr/bin/zsh
# If you aren't using zsh what are you doing with your life?

###
# Check admin
##
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

export KT_WITH_UNKNOWN_DEVCODES="1"

# Fall back to the bundled KindleTool if there aren't any in PATH
KINDLETOOL="$(command -v kindletool)"
KINDLETOOL="${KINDLETOOL:-${PWD}/utils/kindletool}"

###
# Cleanup previous build
###
rm -rf ./build ./build_tmp ./tmp_build_cache
mkdir ./build ./build_tmp ./build_cache

###
# Generate the updater_keys.sqsh file
# (Based on LanguageBreak hotfix build code from Marek)
###
echo "* Copying source to build dir"
cp -r ./src ./build_tmp/src

echo "* Downloading official firmware from Amazon (Scribe)"
if [ ! -f ./build_cache/update_kindle_scribe.bin ]; then
   wget https://www.amazon.com/update_Kindle_Scribe -q -O ./build_cache/update_kindle_scribe.bin
else
   echo "* Official firmware found in cache - SKIPPING"
fi

echo "* Downloading official firmware from Amazon (PW6)"
if [ ! -f ./build_cache/update_kindle_pw6.bin ]; then
   wget https://www.amazon.com/update_KindlePaperwhite_12th_Gen_2024 -q -O ./build_cache/update_kindle_pw6.bin
else
   echo "* Official firmware found in cache - SKIPPING"
fi

echo "* Downloading official firmware from Amazon (PW5)"
if [ ! -f ./build_cache/update_kindle_pw5.bin ]; then
   wget https://www.amazon.com/update_Kindle_Paperwhite_11th_Gen -q -O ./build_cache/update_kindle_pw5.bin
else
   echo "* Official firmware found in cache - SKIPPING"
fi

cp -r build_cache tmp_build_cache

echo "* Extracting and mounting official firmware"
${KINDLETOOL} extract ./build_cache/update_kindle_pw6.bin ./build_tmp/official_firmware
gunzip ./build_tmp/official_firmware/*rootfs*.img.gz
mkdir ./build_tmp/official_firmware_mnt/
mount -o loop ./build_tmp/official_firmware/*rootfs*.img ./build_tmp/official_firmware_mnt/

echo "* Patching UKS SQSH"
mkdir ./build_tmp/patched_uks
mkdir ./build_tmp/mounted_sqsh
mount -o loop ./build_tmp/official_firmware_mnt/etc/uks.sqsh ./build_tmp/mounted_sqsh
cp ./build_tmp/mounted_sqsh/* ./build_tmp/patched_uks/
umount ./build_tmp/mounted_sqsh
cat > "./build_tmp/patched_uks/pubdevkey01.pem" << EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJn1jWU+xxVv/eRKfCPR9e47lP
WN2rH33z9QbfnqmCxBRLP6mMjGy6APyycQXg3nPi5fcb75alZo+Oh012HpMe9Lnp
eEgloIdm1E4LOsyrz4kttQtGRlzCErmBGt6+cAVEV86y2phOJ3mLk0Ek9UQXbIUf
rvyJnS2MKLG2cczjlQIDAQAB
-----END PUBLIC KEY-----
EOF
mksquashfs ./build_tmp/patched_uks ./build_tmp/src/updater_keys.sqsh

echo "* Generating device list"
DEVICE_LIST="$(${KINDLETOOL} convert -i tmp_build_cache/update_kindle*.bin 2>&1 | grep -o "^Device .*" | grep -o "0x[[:xdigit:]]*" | tr "\n" " ")"
echo $DEVICE_LIST

DEVICES=$(echo "$DEVICE_LIST" | xargs | sed "s/ / -d /g")
echo $DEVICES

echo "* Building hotfix"
cd ./build_tmp/src
${KINDLETOOL} create ota2 -d kindle5 -d ${DEVICES} -s min -t max -O -C . "../../build/Update_hotfix_universal.bin"