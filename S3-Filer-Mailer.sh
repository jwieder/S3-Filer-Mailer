#!/bin/sh
# set -x
. ./S3-Filer-Mailer.conf

ROUTE=/tmp/$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)/
mkdir $ROUTE
FILE=`mktemp $PREFIX.XXXXXX -p ${ROUTE}`
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%b_%e_%k:%M:%S)
ATTACHMENT=notification.$(date +%s).tar.gz

mkdir "$ROUTE"copies/
mkdir "$ROUTE"press/

printf "%s %s UID:[%s] PID:[%s] Reading messages ...\n" $TIMESTAMP $HOSTNAME $EUID $$ >> "$LOG"
aws s3 ls $BUCKETURL$FOLDER | grep ${TODAY} > ${FILE}

while read -r fileDate fileTime fileSize fileName
do
        if [ "$fileDate" == "$TODAY" ]; then
                printf "Date Match! File Name: %s File Date: %s File Time: %s\n" $fileName $fileDate $fileTime >> "$LOG"
                aws s3 sync $BUCKETURL$FOLDER "$ROUTE"copies/ --exclude "*" --include "$fileName"
        fi
done < "$FILE"

TIMESTAMP=$(date +%b_%e_%k:%M:%S)

msgCount=$(ls -1 "$ROUTE"copies/ | wc -l)
if [ "$msgCount" -lt "1" ]; then
        printf "%s No daily contacts\n" $TIMESTAMP >> "$LOG"
        exit 0
else
        tar -czf "$ROUTE"press/${ATTACHMENT} "$ROUTE"copies/* --no-recursion
        echo "One or more files have been uploaded to your S3 bucket. Check this email's attachments to review a copy of those files." | mailx -a "$ROUTE"press/${ATTAC$
        printf "%s Contact email sent with attachment\n" $TIMESTAMP >> "$LOG"
fi

rm -rf $ROUTE
printf "S3 mailer exited with status code %s\n" $? >> "$LOG"
exit