#!/bin/sh

###
# I'm tired of useless logs
###

rm -rf /mnt/us/documents/kmc_log
mkdir /mnt/us/documents/kmc_log
cp -r /var/local/log /mnt/us/documents/kmc_log
LOG_PATH="/mnt/us/documents/kmc_log/kmc_log.txt"

echo "====================" > "$LOG_PATH"
echo "=   START KMC LOG  =" >> "$LOG_PATH"
echo "====================" >> "$LOG_PATH"
echo "Running Hotfix v2.3.2" >> "$LOG_PATH"

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

echo "====================" >> "$LOG_PATH"
echo "=    THANK YOU.    =" >> "$LOG_PATH"
echo "=   END KMC LOG  =" >> "$LOG_PATH"
echo "====================" >> "$LOG_PATH"

cp /etc/version.txt /mnt/us/documents/kmc_log/
cp /etc/prettyversion.txt /mnt/us/documents/kmc_log/

cp /var/log/messages /mnt/us/documents/kmc_log/var_log_messages
dmesg >> /mnt/us/documents/kmc_log/dmesg

cp /var/local/appreg.db /mnt/us/documents/kmc_log/
cp /var/local/cc.db /mnt/us/documents/kmc_log/
cp /var/local/deviceType.txt /mnt/us/documents/kmc_log/

tar czf /mnt/us/documents/kmc_log.tar.gz /mnt/us/documents/kmc_log
rm -rf /mnt/us/documents/kmc_log