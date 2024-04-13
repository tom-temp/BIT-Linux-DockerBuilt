#!/bin/bash

cd /opt/
if [[ -f /opt/r_client.jar ]]; then
    rm -rf /opt/*
    wget -O gz_client_bot.tar.gz  https://github.com/semicons/java_oci_manage/releases/latest/download/gz_client_bot.tar.gz && tar -zxvf gz_client_bot.tar.gz --exclude=client_config  && tar -zxvf gz_client_bot.tar.gz --skip-old-files client_config && chmod +x sh_client_bot.sh
fi

echo log start: $(date '+%Y-%m-%d %H:%m') >> /opt/log.log
/usr/sbin/sshd  -E /opt/log.log
/usr/sbin/crond -L /opt/log.log


while [[ ! -f client_config ]]; do
    sleep 30
done


bash /opt/sh_client_bot.sh


