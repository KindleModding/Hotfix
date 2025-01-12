#!/bin/sh

echo "[binaries]" > ./kindlehf.txt
echo "c = '/home/$USER/x-tools/arm-kindlehf-linux-gnueabihf/bin/arm-kindlehf-linux-gnueabihf-gcc'" >> ./kindlehf.txt
echo "cpp = '/home/$USER/x-tools/arm-kindlehf-linux-gnueabihf/bin/arm-kindlehf-linux-gnueabihf-g++'" >> ./kindlehf.txt
echo "ar = '/home/$USER/x-tools/arm-kindlehf-linux-gnueabihf/bin/arm-kindlehf-linux-gnueabihf-ar'" >> ./kindlehf.txt
echo "strip = '/home/$USER/x-tools/arm-kindlehf-linux-gnueabihf/bin/arm-kindlehf-linux-gnueabihf-strip'" >> ./kindlehf.txt
echo "" >> ./kindlehf.txt
echo "[host_machine]" >> ./kindlehf.txt
echo "system = 'linux'" >> ./kindlehf.txt
echo "cpu_family = 'arm'" >> ./kindlehf.txt
echo "cpu = 'arm'" >> ./kindlehf.txt
echo "endian = 'little'" >> ./kindlehf.txt
echo "" >> ./kindlehf.txt
echo "[properties]" >> ./kindlehf.txt
echo "target='Kindle'" >> ./kindlehf.txt
echo "arch = 'armhf'" >> ./kindlehf.txt

echo "[binaries]" > ./kindlepw2.txt
echo "c = '/home/$USER/x-tools/arm-kindlepw2-linux-gnueabi/bin/arm-kindlepw2-linux-gnueabi-gcc'" >> ./kindlepw2.txt
echo "cpp = '/home/$USER/x-tools/arm-kindlepw2-linux-gnueabi/bin/arm-kindlepw2-linux-gnueabi-g++'" >> ./kindlepw2.txt
echo "ar = '/home/$USER/x-tools/arm-kindlepw2-linux-gnueabi/bin/arm-kindlepw2-linux-gnueabi-ar'" >> ./kindlepw2.txt
echo "strip = '/home/$USER/x-tools/arm-kindlepw2-linux-gnueabi/bin/arm-kindlepw2-linux-gnueabi-strip'" >> ./kindlepw2.txt
echo "" >> ./kindlepw2.txt
echo "[host_machine]" >> ./kindlepw2.txt
echo "system = 'linux'" >> ./kindlepw2.txt
echo "cpu_family = 'arm'" >> ./kindlepw2.txt
echo "cpu = 'arm'" >> ./kindlepw2.txt
echo "endian = 'little'" >> ./kindlepw2.txt
echo "" >> ./kindlepw2.txt
echo "[properties]" >> ./kindlepw2.txt
echo "target='Kindle'" >> ./kindlepw2.txt
echo "arch = 'armel'" >> ./kindlepw2.txt