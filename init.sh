#!/usr/bin/with-contenv /bin/bash
echo 'Initializing lastpass backup'
if [ -z ${var+x} ]; then
    CRON_EXPRESSION="* * * * *"
fi
echo "$CRON_EXPRESSION /bin/bash /backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /backup_cron
crontab /backup_cron

mkdir -p /conf/hashes

