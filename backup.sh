#/bin/bash

lpass_login() {
    /usr/bin/lpass status > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "$(/bin/date +'%Y/%m/%d %H:%M:%S') Logging in"
        /usr/bin/lpass login ${USER} <<< ${PASSWORD} > /dev/null 2>&1
    else
        echo "$(/bin/date +'%Y/%m/%d %H:%M:%S') Already logged in"
    fi
}

lpass_logout() {
    /usr/bin/lpass status > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        /usr/bin/lpass sync
        /usr/bin/lpass logout <<< Y > /dev/null 2>&1
        echo "$(/bin/date +'%Y/%m/%d %H:%M:%S') Logging out"
    fi
}

check() {
    FILE="$1"
    if [ -f "${FILE}" ]; then
        HASH=($(/usr/bin/md5sum $FILE))
        HASH_FILE="/conf/hashes/$(/usr/bin/basename $FILE).md5"
        /usr/bin/touch $HASH_FILE
        PREV_HASH=$(/bin/cat $HASH_FILE)
        if [ "$PREV_HASH" != "$HASH" ]; then
            TS=$(/bin/date +"%Y%m%d_%H%M%S")
            NAME="$FOLDER/$(/usr/bin/basename $FILE)_$TS"
            lpass_login;
            echo  "$(/bin/date +'%Y/%m/%d %H:%M:%S') Adding $NAME to lastpass"
            /usr/bin/lpass add --non-interactive --notes "$NAME" < $FILE
            echo  $HASH > $HASH_FILE;
        else
            echo  "$(/bin/date +'%Y/%m/%d %H:%M:%S') No changes in $FILE"
        fi
    fi
}

if [ -f /conf/lpass.env ]; then
    source /conf/lpass.env
else
    echo "$(/bin/date +'%Y/%m/%d %H:%M:%S') Mounted /conf directory must contain lpass.env"
    exit 1
fi

if [ -z "$USER" ] || [ -z "$PASSWORD" ]; then
    echo "$(/bin/date +'%Y/%m/%d %H:%M:%S') You must define USER, PASSWORD, and FOLDER (optional) /conf/lpass.env"
    exit 1
fi

if [ -z "$FOLDER" ]; then
    FOLDER='Backup'
fi

echo "$(/bin/date +'%Y/%m/%d %H:%M:%S') Starting backup"
/usr/bin/find /backup -mindepth 1 -type f | while read file; do check $file; done
lpass_logout;
echo "$(/bin/date +'%Y/%m/%d %H:%M:%S') Backup complete"
