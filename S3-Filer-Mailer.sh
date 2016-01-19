#!/bin/sh
####################################################
##
## S3 Notifification Mailer
##
##      Josh Wieder
##      contact@joshwieder.net
##
## Simple script checks for newly uploaded files to an Amazon S3 bucket. If files exist that were created on the day the scripts
## is run, the script downloads them, compresses them and then sends them as an email attachment to an address of your choice. 
## Very useful for S3-backed contact forms. Note that currently the script relies on several complex system architectures - 
## notably, the AWS CLI and functioning email capability that will allow mailx to work. 
##
## Don't forget to update the configuration file S3-Filer-Mailer.sh before running the script! By default, logs are written to 
## /var/log/s3contacts.log To execute, be sure to add the executable bit: chmod +x S3-Filer-Mailer.sh Once you are comfortable, 
## consider executing the script daily from your crontab: @daily /path/to/S3-Filer-Mailer.sh
## 
##
## dependencies: mailx-12.5
##               AWS Command Line Interface (see https://docs.aws.amazon.com/cli/latest/userguide/installing.html )
##               Python >= 2.6.5 OR >= 3.3
##
## Copyright (c) 2016, Josh Wieder
## All rights reserved.
####################################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
. $DIR/S3-Filer-Mailer.conf

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
        echo "One or more files have been uploaded to your S3 bucket. Check this email's attachments to review a copy of those files." | mailx -a "$ROUTE"press/${ATTACHMENT} -s "Contact Requests $TODAY" $EMAILADDY

        printf "%s Contact email sent with attachment\n" $TIMESTAMP >> "$LOG"
fi

rm -rf $ROUTE
printf "S3 mailer exited with status code %s\n" $? >> "$LOG"
exit