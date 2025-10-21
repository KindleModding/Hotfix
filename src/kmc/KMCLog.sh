#!/bin/sh

###
# I'm tired of useless logs
###

LOG_PATH="/mnt/us/documents/kmc.log"

echo "====================" > "$LOG_PATH"
echo "=   START KMC LOG  =" >> "$LOG_PATH"
echo "====================" >> "$LOG_PATH"
cat /etc/version.txt >> "$LOG_PATH"
cat /etc/prettyversion.txt >> "$LOG_PATH"

# Dump the file list
echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo "===> /mnt/us contents" >> "$LOG_PATH"
find /mnt/us -exec md5sum {} \; >> "$LOG_PATH"

echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo "===> /var/local/kmc contents" >> "$LOG_PATH"
find /var/local/kmc -exec md5sum {} \; >> "$LOG_PATH"

echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo "===> /var/local/mkk contents" >> "$LOG_PATH"
find /var/local/mkk -exec md5sum {} \; >> "$LOG_PATH"

echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo "===> /var/log/messages" >> "$LOG_PATH"
cat /var/log/messages >> "$LOG_PATH"


echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo >> "$LOG_PATH"
echo "===> dmesg" >> "$LOG_PATH"
dmesg >> "$LOG_PATH"

echo "====================" >> "$LOG_PATH"
echo "=    THANK YOU.    =" >> "$LOG_PATH"
echo "=   END KMC LOG  =" >> "$LOG_PATH"
echo "====================" >> "$LOG_PATH"